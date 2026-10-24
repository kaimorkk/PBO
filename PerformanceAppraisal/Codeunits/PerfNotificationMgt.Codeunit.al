codeunit 52193435 "Perf Notification Mgt"
{
    // FRD 3.vi: "The system shall send alerts to supervisors and employees to perform
    // key actions such as setting targets, recording achievements, and completing
    // evaluations."
    // Alerts are e-mailed to the person who must act (Employee."Company E-Mail"), queued
    // so a mail failure never rolls back the approval step. Run this codeunit from the
    // Job Queue (daily) to send deadline reminders.

    trigger OnRun()
    begin
        SendDeadlineReminders();
    end;

    // ---------- Target setting (FRD 2) ----------

    procedure NotifySupervisorGoalSubmitted(GoalHeader: Record "Perf Goal Header")
    begin
        if not SetupFlag(1) then
            exit;
        SendAlert(GoalHeader."Supervisor No.", GoalSubmittedSubjTxt,
            StrSubstNo(GoalSubmittedTxt, GoalHeader."Employee Name", GoalHeader."No.", GoalHeader."Period Code"));
    end;

    procedure NotifyEmployeeGoalApproved(GoalHeader: Record "Perf Goal Header")
    begin
        SendAlert(GoalHeader."Employee No.", GoalApprovedSubjTxt, StrSubstNo(GoalApprovedTxt, GoalHeader."No."));
    end;

    procedure NotifyEmployeeGoalReturned(GoalHeader: Record "Perf Goal Header")
    begin
        if not SetupFlag(2) then
            exit;
        SendAlert(GoalHeader."Employee No.", GoalReturnedSubjTxt,
            StrSubstNo(GoalReturnedTxt, GoalHeader."No.", GoalHeader."HOD Comments"));
    end;

    procedure NotifyCEOGoalSubmitted(GoalHeader: Record "Perf Goal Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        SendAlert(EmployeeMgt.GetCEONo(), GoalToCEOSubjTxt,
            StrSubstNo(GoalToCEOTxt, GoalHeader."Employee Name", GoalHeader."No."));
    end;

    procedure NotifyEmployeeGoalFinalized(GoalHeader: Record "Perf Goal Header")
    begin
        SendAlert(GoalHeader."Employee No.", GoalFinalizedSubjTxt, StrSubstNo(GoalFinalizedTxt, GoalHeader."No."));
    end;

    // ---------- Performance review (FRD 3) ----------

    procedure NotifySupervisorSelfAssessmentSubmitted(ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        if not SetupFlag(1) then
            exit;
        SendAlert(ReviewHeader."Supervisor No.", SelfAssessSubjTxt,
            StrSubstNo(SelfAssessTxt, EmployeeMgt.GetName(ReviewHeader."Employee No."), ReviewHeader."No."));
    end;

    procedure NotifyEmployeeReviewReturned(ReviewHeader: Record "Perf Review Header")
    begin
        if not SetupFlag(2) then
            exit;
        SendAlert(ReviewHeader."Employee No.", ReviewReturnedSubjTxt,
            StrSubstNo(ReviewReturnedTxt, ReviewHeader."No.", ReviewHeader."Supervisor Return Comments"));
    end;

    procedure NotifyEmployeeReviewCompleted(ReviewHeader: Record "Perf Review Header")
    begin
        SendAlert(ReviewHeader."Employee No.", ReviewCompletedSubjTxt,
            StrSubstNo(ReviewCompletedTxt, ReviewHeader."No.", ReviewHeader."Overall Score", ReviewHeader."Rating Category"));
    end;

    procedure NotifyNextLevelSupervisorForApproval(ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        SendAlert(ReviewHeader."Next Level Supervisor No.", NextLevelApprovalSubjTxt,
            StrSubstNo(NextLevelApprovalTxt, EmployeeMgt.GetName(ReviewHeader."Employee No."), ReviewHeader."No."));
    end;

    procedure NotifyNextLevelSupervisor(ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        SendAlert(ReviewHeader."Next Level Supervisor No.", EscalatedSubjTxt,
            StrSubstNo(EscalatedTxt, EmployeeMgt.GetName(ReviewHeader."Employee No."), ReviewHeader."No.", ReviewHeader."Objection Comments"));
    end;

    procedure NotifyGMHREscalation(ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        SendAlert(EmployeeMgt.GetGMHRANo(), EscalatedSubjTxt,
            StrSubstNo(EscalatedTxt, EmployeeMgt.GetName(ReviewHeader."Employee No."), ReviewHeader."No.", ReviewHeader."Objection Comments"));
    end;

    procedure NotifySupervisorReReview(ReviewHeader: Record "Perf Review Header")
    begin
        SendAlert(ReviewHeader."Supervisor No.", ReReviewSubjTxt,
            StrSubstNo(ReReviewTxt, ReviewHeader."No.", ReviewHeader."Escalation Resolution"));
    end;

    procedure NotifyHRManagerForConsolidation(ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        SendAlert(EmployeeMgt.GetHRManagerNo(), ConsolidateSubjTxt, StrSubstNo(ConsolidateTxt, ReviewHeader."No."));
    end;

    procedure NotifyGMHRASubmission(ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        SendAlert(EmployeeMgt.GetGMHRANo(), GMHRASubjTxt, StrSubstNo(GMHRATxt, ReviewHeader."No."));
    end;

    // ---------- Deadline reminders ----------

    /// <summary>
    /// Job-queue callable routine to send deadline reminders ahead of target setting,
    /// self-assessment and supervisor review deadlines (FRD 3.vi).
    /// </summary>
    procedure SendDeadlineReminders()
    var
        Period: Record "Perf Appraisal Period";
        PerfSetup: Record "Perf Setup";
    begin
        if not PerfSetup.Get() then
            exit;

        Period.SetRange(Closed, false);
        if Period.FindSet() then
            repeat
                if IsReminderDay(Period."Target Setting Deadline", PerfSetup) then
                    SendTargetSettingReminders(Period);
                if IsReminderDay(Period."Self-Assessment Deadline", PerfSetup) then
                    SendSelfAssessmentReminders(Period);
                if IsReminderDay(Period."Supervisor Review Deadline", PerfSetup) then
                    SendSupervisorReviewReminders(Period);
            until Period.Next() = 0;
    end;

    local procedure SendTargetSettingReminders(Period: Record "Perf Appraisal Period")
    var
        Employee: Record Employee;
        GoalHeader: Record "Perf Goal Header";
    begin
        Employee.SetRange(Status, Employee.Status::Active);
        if Employee.FindSet() then
            repeat
                GoalHeader.SetRange("Employee No.", Employee."No.");
                GoalHeader.SetRange("Period Code", Period.Code);
                if not GoalHeader.FindFirst() then
                    SendAlert(Employee."No.", TargetReminderSubjTxt, StrSubstNo(TargetReminderTxt, Period.Description, Period."Target Setting Deadline"))
                else
                    case GoalHeader.Status of
                        GoalHeader.Status::Open, GoalHeader.Status::"Returned for Amendment":
                            SendAlert(Employee."No.", TargetReminderSubjTxt, StrSubstNo(TargetReminderTxt, Period.Description, Period."Target Setting Deadline"));
                        GoalHeader.Status::"Pending Supervisor Review":
                            SendAlert(GoalHeader."Supervisor No.", TargetReminderSubjTxt, StrSubstNo(TargetApprovalReminderTxt, GoalHeader."Employee Name", GoalHeader."No.", Period."Target Setting Deadline"));
                    end;
            until Employee.Next() = 0;
    end;

    local procedure SendSelfAssessmentReminders(Period: Record "Perf Appraisal Period")
    var
        ReviewHeader: Record "Perf Review Header";
    begin
        ReviewHeader.SetRange("Period Code", Period.Code);
        ReviewHeader.SetFilter(Status, '%1|%2', ReviewHeader.Status::Open, ReviewHeader.Status::"Returned to Employee");
        if ReviewHeader.FindSet() then
            repeat
                SendAlert(ReviewHeader."Employee No.", SelfAssessReminderSubjTxt,
                    StrSubstNo(SelfAssessReminderTxt, ReviewHeader."No.", Period."Self-Assessment Deadline"));
            until ReviewHeader.Next() = 0;
    end;

    local procedure SendSupervisorReviewReminders(Period: Record "Perf Appraisal Period")
    var
        ReviewHeader: Record "Perf Review Header";
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        ReviewHeader.SetRange("Period Code", Period.Code);
        ReviewHeader.SetRange(Status, ReviewHeader.Status::"Self-Assessment Submitted");
        if ReviewHeader.FindSet() then
            repeat
                SendAlert(ReviewHeader."Supervisor No.", SupReviewReminderSubjTxt,
                    StrSubstNo(SupReviewReminderTxt, EmployeeMgt.GetName(ReviewHeader."Employee No."), ReviewHeader."No.", Period."Supervisor Review Deadline"));
            until ReviewHeader.Next() = 0;
    end;

    local procedure IsReminderDay(Deadline: Date; PerfSetup: Record "Perf Setup"): Boolean
    begin
        if Deadline = 0D then
            exit(false);
        exit(Today = Deadline - PerfSetup."Reminder Days Before Deadline");
    end;

    local procedure SetupFlag(Which: Option ,NotifySupervisorOnSubmit,NotifyEmployeeOnReturn): Boolean
    var
        PerfSetup: Record "Perf Setup";
    begin
        if not PerfSetup.Get() then
            exit(false);
        case Which of
            Which::NotifySupervisorOnSubmit:
                exit(PerfSetup."Notify Supervisor on Submit");
            Which::NotifyEmployeeOnReturn:
                exit(PerfSetup."Notify Employee on Return");
        end;
    end;

    local procedure SendAlert(EmployeeNo: Code[20]; Subject: Text; Body: Text)
    var
        PerfSetup: Record "Perf Setup";
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Recipient: Text;
    begin
        if EmployeeNo = '' then
            exit;
        if not PerfSetup.Get() then
            exit;
        if not PerfSetup."Send Email Alerts" then
            exit;
        Recipient := EmployeeMgt.GetEmail(EmployeeNo);
        if Recipient = '' then
            exit;
        EmailMessage.Create(Recipient, Subject, Body, true);
        Email.Enqueue(EmailMessage);
    end;

    var
        GoalSubmittedSubjTxt: Label 'Performance targets submitted for your review';
        GoalSubmittedTxt: Label '%1 has submitted performance targets <b>%2</b> for period %3 for your review and agreement.', Comment = '%1 = employee name, %2 = goal no., %3 = period';
        GoalApprovedSubjTxt: Label 'Performance targets agreed by HOD';
        GoalApprovedTxt: Label 'Your performance targets <b>%1</b> have been agreed and signed by your HOD and submitted to the CEO.', Comment = '%1 = goal no.';
        GoalReturnedSubjTxt: Label 'Performance targets returned for amendment';
        GoalReturnedTxt: Label 'Your performance targets <b>%1</b> were returned for amendment.<br/>HOD comments: %2', Comment = '%1 = goal no., %2 = HOD comments';
        GoalToCEOSubjTxt: Label 'Performance targets awaiting CEO approval';
        GoalToCEOTxt: Label 'Performance targets for %1 (<b>%2</b>) have been agreed with the HOD and await your approval.', Comment = '%1 = employee name, %2 = goal no.';
        GoalFinalizedSubjTxt: Label 'Performance targets approved';
        GoalFinalizedTxt: Label 'Your performance targets <b>%1</b> have been approved by the CEO.', Comment = '%1 = goal no.';
        SelfAssessSubjTxt: Label 'Self-assessment submitted for your review';
        SelfAssessTxt: Label '%1 has submitted a self-assessment (<b>%2</b>). Please conduct the review with the employee.', Comment = '%1 = employee name, %2 = review no.';
        ReviewReturnedSubjTxt: Label 'Self-assessment returned for amendment';
        ReviewReturnedTxt: Label 'Your self-assessment <b>%1</b> was returned by your supervisor.<br/>Comments: %2', Comment = '%1 = review no., %2 = comments';
        ReviewCompletedSubjTxt: Label 'Supervisor review completed';
        ReviewCompletedTxt: Label 'Your supervisor has completed review <b>%1</b>. Overall score: %2 (%3). If you disagree with the results you may raise an objection.', Comment = '%1 = review no., %2 = score, %3 = rating category';
        NextLevelApprovalSubjTxt: Label 'Performance review awaiting your approval';
        NextLevelApprovalTxt: Label 'The performance review of %1 (<b>%2</b>) has been submitted to you as next level supervisor.', Comment = '%1 = employee name, %2 = review no.';
        EscalatedSubjTxt: Label 'Performance review objection escalated to you';
        EscalatedTxt: Label '%1 has objected to the results of review <b>%2</b>.<br/>Objection: %3', Comment = '%1 = employee name, %2 = review no., %3 = objection';
        ReReviewSubjTxt: Label 'Performance review returned for re-review';
        ReReviewTxt: Label 'Review <b>%1</b> has been returned to you for re-review following an objection.<br/>Resolution: %2', Comment = '%1 = review no., %2 = resolution';
        ConsolidateSubjTxt: Label 'Performance review ready for consolidation';
        ConsolidateTxt: Label 'Review <b>%1</b> has been approved by the next level supervisor and is ready for HR consolidation.', Comment = '%1 = review no.';
        GMHRASubjTxt: Label 'Consolidated performance review submitted';
        GMHRATxt: Label 'Consolidated review <b>%1</b> has been submitted to you for onward submission to the HR Appraisal Committee.', Comment = '%1 = review no.';
        TargetReminderSubjTxt: Label 'Reminder: performance target setting';
        TargetReminderTxt: Label 'Please complete and submit your performance targets for %1 by %2.', Comment = '%1 = period, %2 = deadline';
        TargetApprovalReminderTxt: Label 'Targets submitted by %1 (<b>%2</b>) await your review. Deadline: %3.', Comment = '%1 = employee name, %2 = goal no., %3 = deadline';
        SelfAssessReminderSubjTxt: Label 'Reminder: self-assessment';
        SelfAssessReminderTxt: Label 'Please record your achievements and submit your self-assessment <b>%1</b> by %2.', Comment = '%1 = review no., %2 = deadline';
        SupReviewReminderSubjTxt: Label 'Reminder: supervisor evaluation';
        SupReviewReminderTxt: Label 'Please complete the evaluation of %1 (<b>%2</b>) by %3.', Comment = '%1 = employee name, %2 = review no., %3 = deadline';
}
