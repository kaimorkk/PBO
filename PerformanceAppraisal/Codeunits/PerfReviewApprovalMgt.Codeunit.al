codeunit 52193436 "Perf Review Approval Mgt"
{
    // Implements FRD section 3 "Performance Reviews" and Figure 2 (Bi-annual/Annual Appraisal):
    // Employee self-assessment -> HOD evaluation (or return to employee with comment)
    // -> next level supervisor -> HR Manager consolidation -> GM HR&A -> HR Appraisal
    // Committee (EPMC) -> committee recommendation to ED -> closed.
    // Objection path: employee objects -> next level supervisor (uphold, send back to HOD,
    // or escalate) -> GM HR (uphold or send back to HOD for review).

    trigger OnRun()
    begin
    end;

    procedure SubmitSelfAssessment(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        ScoreCalc: Codeunit "Perf Score Calculation";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        if not (ReviewHeader.Status in [ReviewHeader.Status::Open, ReviewHeader.Status::"Returned to Employee"]) then
            ReviewHeader.FieldError(Status);
        EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Employee No.", EmployeeRoleTxt);
        ReviewHeader.TestField("Goal No.");
        ReviewHeader.TestField("Period Code");
        // FRD 3 precondition: the performance period is complete.
        if (ReviewHeader."Review End Date" <> 0D) and (Today < ReviewHeader."Review End Date") and GuiAllowed() then
            if not Confirm(PeriodNotCompleteQst, false, ReviewHeader."Review End Date") then
                Error('');
        ScoreCalc.CalculateSelfScores(ReviewHeader);

        ReviewHeader.Status := ReviewHeader.Status::"Self-Assessment Submitted";
        ReviewHeader."Self Assessment Date" := Today;
        ReviewHeader.Modify(true);

        NotificationMgt.NotifySupervisorSelfAssessmentSubmitted(ReviewHeader);
    end;

    /// <summary>
    /// FRD Figure 2 "Approvals - No": HOD returns the self-assessment to the employee with a comment.
    /// </summary>
    procedure ReturnToEmployee(var ReviewHeader: Record "Perf Review Header"; Comments: Text[250])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Self-Assessment Submitted");
        EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Supervisor No.", SupervisorRoleTxt);
        if Comments = '' then
            Error(CommentsRequiredErr);

        ReviewHeader."Supervisor Return Comments" := Comments;
        ReviewHeader.Status := ReviewHeader.Status::"Returned to Employee";
        ReviewHeader.Modify(true);

        NotificationMgt.NotifyEmployeeReviewReturned(ReviewHeader);
    end;

    /// <summary>
    /// FRD 3.ii-iii: supervisor conducts the review with the employee, records feedback and
    /// the review goes to the next level supervisor.
    /// </summary>
    procedure SubmitSupervisorReview(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        ScoreCalc: Codeunit "Perf Score Calculation";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Self-Assessment Submitted");
        EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Supervisor No.", SupervisorRoleTxt);
        ReviewHeader.TestField("Next Level Supervisor No.");
        ScoreCalc.CalculateFinalScores(ReviewHeader);

        ReviewHeader.Status := ReviewHeader.Status::"Supervisor Review Submitted";
        ReviewHeader."Supervisor Review Date" := Today;
        ReviewHeader."Supervisor Return Comments" := '';
        ReviewHeader.Modify(true);

        NotificationMgt.NotifyEmployeeReviewCompleted(ReviewHeader);
        NotificationMgt.NotifyNextLevelSupervisorForApproval(ReviewHeader);
    end;

    procedure ApproveByNextLevelSupervisor(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Supervisor Review Submitted");
        EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Next Level Supervisor No.", NextLevelRoleTxt);
        SetApprovedByNextLevel(ReviewHeader);
    end;

    /// <summary>
    /// FRD 3.iv: employee may object to results set by supervisor -> escalate to next level supervisor.
    /// </summary>
    procedure RaiseObjection(var ReviewHeader: Record "Perf Review Header"; Comments: Text[250])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Supervisor Review Submitted");
        EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Employee No.", EmployeeRoleTxt);
        if Comments = '' then
            Error(ObjectionRequiredErr);
        ReviewHeader."Employee Objection" := true;
        ReviewHeader."Objection Comments" := Comments;
        ReviewHeader.Status := ReviewHeader.Status::"Objected by Employee";
        ReviewHeader.Modify(true);

        EscalateToNextLevelSupervisor(ReviewHeader);
    end;

    local procedure EscalateToNextLevelSupervisor(var ReviewHeader: Record "Perf Review Header")
    var
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        ReviewHeader.TestField("Next Level Supervisor No.");
        ReviewHeader.Status := ReviewHeader.Status::"Escalated to Next Level Supervisor";
        ReviewHeader.Modify(true);

        NotificationMgt.NotifyNextLevelSupervisor(ReviewHeader);
    end;

    /// <summary>
    /// FRD Figure 2: "In case there is further disagreement, it should proceed to GM HR".
    /// </summary>
    procedure EscalateToGMHR(var ReviewHeader: Record "Perf Review Header"; Comments: Text[250])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Escalated to Next Level Supervisor");
        EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Next Level Supervisor No.", NextLevelRoleTxt);
        if Comments = '' then
            Error(ResolutionRequiredErr);
        ReviewHeader."Escalation Resolution" := Comments;
        ReviewHeader.Status := ReviewHeader.Status::"Escalated to GM HR";
        ReviewHeader.Modify(true);

        NotificationMgt.NotifyGMHREscalation(ReviewHeader);
    end;

    /// <summary>
    /// Resolves an objection at next level supervisor or GM HR level. Uphold keeps the
    /// supervisor's results; otherwise the review is resubmitted back to the HOD for review.
    /// </summary>
    procedure ResolveObjection(var ReviewHeader: Record "Perf Review Header"; Resolution: Text[250]; Uphold: Boolean)
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        case ReviewHeader.Status of
            ReviewHeader.Status::"Escalated to Next Level Supervisor":
                EmployeeMgt.CheckCurrentUserIs(ReviewHeader."Next Level Supervisor No.", NextLevelRoleTxt);
            ReviewHeader.Status::"Escalated to GM HR":
                EmployeeMgt.CheckCurrentUserIsGMHRA();
            else
                ReviewHeader.FieldError(Status);
        end;
        if Resolution = '' then
            Error(ResolutionRequiredErr);
        ReviewHeader."Escalation Resolution" := Resolution;

        if Uphold then
            SetApprovedByNextLevel(ReviewHeader)
        else begin
            ReviewHeader.Status := ReviewHeader.Status::"Self-Assessment Submitted";
            ReviewHeader.Modify(true);
            NotificationMgt.NotifySupervisorReReview(ReviewHeader);
        end;
    end;

    local procedure SetApprovedByNextLevel(var ReviewHeader: Record "Perf Review Header")
    var
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        ReviewHeader.Status := ReviewHeader.Status::"Approved by Next Level Supervisor";
        ReviewHeader."Next Level Approval Date" := Today;
        ReviewHeader.Modify(true);
        NotificationMgt.NotifyHRManagerForConsolidation(ReviewHeader);
    end;

    /// <summary>
    /// FRD 3.v: Forward to HR-Manager for consolidation of the assessments.
    /// </summary>
    procedure ForwardToHRManager(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        if ReviewHeader.Status <> ReviewHeader.Status::"Approved by Next Level Supervisor" then
            Error(WrongStatusErr);
        EmployeeMgt.CheckCurrentUserIsHRManager();

        ReviewHeader.Status := ReviewHeader.Status::"Consolidated by HR";
        ReviewHeader."HR Consolidation Date" := Today;
        ReviewHeader.Modify(true);
    end;

    /// <summary>
    /// FRD Figure 2: HR Manager submits to GM HR and Administration, who submits to the EPMC (HR Appraisal
    /// Committee); committee recommendations are finally submitted to the ED.
    /// </summary>
    procedure SubmitToGMHRandA(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Consolidated by HR");
        EmployeeMgt.CheckCurrentUserIsHRManager();
        ReviewHeader."Submitted to GM HR&A" := true;
        ReviewHeader."Submitted to GM HR&A Date" := Today;
        ReviewHeader.Status := ReviewHeader.Status::"Submitted to GM HR&A";
        ReviewHeader.Modify(true);
        NotificationMgt.NotifyGMHRASubmission(ReviewHeader);
    end;

    procedure SubmitToHRAC(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        // Reviews flagged under the earlier flow stay at "Consolidated by HR" with the flag set.
        if not ((ReviewHeader.Status = ReviewHeader.Status::"Submitted to GM HR&A") or
                ((ReviewHeader.Status = ReviewHeader.Status::"Consolidated by HR") and ReviewHeader."Submitted to GM HR&A"))
        then
            ReviewHeader.FieldError(Status);
        EmployeeMgt.CheckCurrentUserIsGMHRA();
        ReviewHeader.Status := ReviewHeader.Status::"Submitted to HRAC";
        ReviewHeader."Submitted to HRAC Date" := Today;
        ReviewHeader.Modify(true);
    end;

    procedure RecordHRACRecommendationAndSubmitToED(var ReviewHeader: Record "Perf Review Header"; Recommendation: Text[250])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Submitted to HRAC");
        EmployeeMgt.CheckCurrentUserIsHROfficial();
        if Recommendation = '' then
            Error(RecommendationRequiredErr);
        ReviewHeader."HRAC Recommendation" := Recommendation;
        ReviewHeader."Submitted to ED" := true;
        ReviewHeader.Status := ReviewHeader.Status::"Recommendation Submitted to ED";
        ReviewHeader.Modify(true);
    end;

    procedure CloseReview(var ReviewHeader: Record "Perf Review Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Recommendation Submitted to ED");
        EmployeeMgt.CheckCurrentUserIsHROfficial();
        ReviewHeader.Status := ReviewHeader.Status::Closed;
        ReviewHeader.Modify(true);
    end;

    var
        WrongStatusErr: Label 'The review must be approved by the next level supervisor before HR consolidation.';
        CommentsRequiredErr: Label 'Enter the supervisor comments explaining what the employee must amend.';
        ObjectionRequiredErr: Label 'Enter the objection comments before raising an objection.';
        ResolutionRequiredErr: Label 'Enter the objection resolution comments.';
        RecommendationRequiredErr: Label 'Enter the HR Appraisal Committee recommendation.';
        PeriodNotCompleteQst: Label 'The performance period ends on %1 and is not yet complete. Submit the self-assessment anyway?', Comment = '%1 = review end date';
        EmployeeRoleTxt: Label 'employee';
        SupervisorRoleTxt: Label 'supervisor (HOD)';
        NextLevelRoleTxt: Label 'next level supervisor';
}
