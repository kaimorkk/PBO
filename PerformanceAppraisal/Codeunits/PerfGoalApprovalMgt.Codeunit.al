codeunit 52193433 "Perf Goal Approval Mgt"
{
    // Implements FRD section 2 "Target Setting Structure":
    // Staff creates goals linked to the cascaded workplan, PC and strategic plan -> signs and
    // submits to HOD -> HOD agrees (signs) or returns with comments (iterative until
    // agreement) -> submitted to CEO -> CEO approves -> Manager HR generates the
    // comprehensive Target Setting Report.

    trigger OnRun()
    begin
    end;

    procedure SubmitToSupervisor(var GoalHeader: Record "Perf Goal Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        GoalHeader.TestField(Status, GoalHeader.Status::Open);
        EmployeeMgt.CheckCurrentUserIs(GoalHeader."Employee No.", StaffRoleTxt);
        GoalHeader.TestField("Supervisor No.");
        GoalHeader.TestField("Period Code");
        // FRD 2.v: targets must be linked to the Annual Plan, PC commitments and Strategic Plan.
        GoalHeader.TestField("Workplan No.");
        GoalHeader.TestField("Performance Contract Ref.");
        GoalHeader.TestField("Strategic Plan Reference");
        CheckLinesLinkedToWorkplan(GoalHeader);
        CheckWeightageComplete(GoalHeader);

        GoalHeader.Status := GoalHeader.Status::"Pending Supervisor Review";
        GoalHeader."Staff Signed" := true;
        GoalHeader."Staff Signature Date" := Today;
        GoalHeader.Modify(true);

        NotificationMgt.NotifySupervisorGoalSubmitted(GoalHeader);
    end;

    procedure ApproveBySupervisor(var GoalHeader: Record "Perf Goal Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        GoalHeader.TestField(Status, GoalHeader.Status::"Pending Supervisor Review");
        EmployeeMgt.CheckCurrentUserIs(GoalHeader."Supervisor No.", HODRoleTxt);

        GoalHeader.Status := GoalHeader.Status::"Approved by Supervisor";
        GoalHeader."Supervisor Signed" := true;
        GoalHeader."Supervisor Signature Date" := Today;
        GoalHeader."HOD Comments" := '';
        GoalHeader.Modify(true);

        // FRD 2.vii: agreement between staff and HOD is reached; submit onward to the CEO.
        SubmitToCEO(GoalHeader);
        NotificationMgt.NotifyEmployeeGoalApproved(GoalHeader);
    end;

    procedure ReturnToStaff(var GoalHeader: Record "Perf Goal Header"; Comments: Text[250])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        GoalHeader.TestField(Status, GoalHeader.Status::"Pending Supervisor Review");
        EmployeeMgt.CheckCurrentUserIs(GoalHeader."Supervisor No.", HODRoleTxt);
        if Comments = '' then
            Error(CommentsRequiredErr);

        GoalHeader.Status := GoalHeader.Status::"Returned for Amendment";
        GoalHeader."HOD Comments" := Comments;
        // Staff signs again when the amended targets are resubmitted.
        GoalHeader."Staff Signed" := false;
        GoalHeader."Staff Signature Date" := 0D;
        GoalHeader.Modify(true);

        NotificationMgt.NotifyEmployeeGoalReturned(GoalHeader);
    end;

    procedure ResubmitAfterAmendment(var GoalHeader: Record "Perf Goal Header")
    begin
        GoalHeader.TestField(Status, GoalHeader.Status::"Returned for Amendment");
        GoalHeader.Status := GoalHeader.Status::Open;
        SubmitToSupervisor(GoalHeader);
        // Collaborative loop continues (Staff <-> HOD) until agreement, per FRD step vii.
    end;

    local procedure SubmitToCEO(var GoalHeader: Record "Perf Goal Header")
    var
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        GoalHeader.Status := GoalHeader.Status::"Submitted to CEO";
        GoalHeader.Modify(true);
        NotificationMgt.NotifyCEOGoalSubmitted(GoalHeader);
    end;

    /// <summary>
    /// CEO approval of the agreed targets; the targets become the basis for appraisal.
    /// </summary>
    procedure Finalize(var GoalHeader: Record "Perf Goal Header")
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
        NotificationMgt: Codeunit "Perf Notification Mgt";
    begin
        GoalHeader.TestField(Status, GoalHeader.Status::"Submitted to CEO");
        EmployeeMgt.CheckCurrentUserIsCEO();
        GoalHeader."CEO Approval Date" := Today;
        GoalHeader.Status := GoalHeader.Status::Finalized;
        GoalHeader.Modify(true);
        NotificationMgt.NotifyEmployeeGoalFinalized(GoalHeader);
    end;

    local procedure CheckLinesLinkedToWorkplan(GoalHeader: Record "Perf Goal Header")
    var
        GoalLine: Record "Perf Goal Line";
        Workplan: Record "Perf Corporate Workplan";
    begin
        GoalLine.SetRange("Goal No.", GoalHeader."No.");
        if GoalLine.IsEmpty() then
            Error(NoLinesErr, GoalHeader."No.");
        GoalLine.SetRange("Workplan Line No.", 0);
        if GoalLine.FindFirst() then
            Error(LineNotLinkedErr, GoalLine."Key Result Area");
        GoalLine.SetRange("Workplan Line No.");
        GoalLine.SetFilter("Workplan No.", '<>%1', GoalHeader."Workplan No.");
        if GoalLine.FindFirst() then
            Error(LineOtherWorkplanErr, GoalLine."Key Result Area", GoalHeader."Workplan No.");
        // The workplan may have been returned for revision since the goal was drafted.
        Workplan.Get(GoalHeader."Workplan No.");
        GoalHeader.CheckWorkplanReady(Workplan);
    end;

    local procedure CheckWeightageComplete(GoalHeader: Record "Perf Goal Header")
    var
        GoalLine: Record "Perf Goal Line";
        TotalWeight: Decimal;
    begin
        GoalLine.SetRange("Goal No.", GoalHeader."No.");
        if GoalLine.FindSet() then
            repeat
                TotalWeight += GoalLine."Weightage %";
            until GoalLine.Next() = 0;

        if TotalWeight <> 100 then
            Error(WeightageErr, TotalWeight);
    end;

    var
        WeightageErr: Label 'Total weightage of all Key Result Areas must equal 100%%. Current total is %1%%.', Comment = '%1 = current total weight';
        NoLinesErr: Label 'Targets %1 have no Key Result Areas.', Comment = '%1 = goal no.';
        LineNotLinkedErr: Label 'Key Result Area "%1" is not linked to a workplan objective. Every target must cascade from the Corporate Annual Workplan.', Comment = '%1 = KRA';
        LineOtherWorkplanErr: Label 'Key Result Area "%1" is linked to a different workplan than %2.', Comment = '%1 = KRA, %2 = workplan no.';
        CommentsRequiredErr: Label 'Enter the HOD comments explaining what must be amended before returning the targets.';
        StaffRoleTxt: Label 'staff member';
        HODRoleTxt: Label 'supervisor (HOD)';
}
