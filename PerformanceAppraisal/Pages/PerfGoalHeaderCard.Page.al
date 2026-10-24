page 52193465 "Perf Goal Header Card"
{
    Caption = 'Individual Performance Goal';
    PageType = Document;
    SourceTable = "Perf Goal Header";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = CanEdit;
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Employee Name"; Rec."Employee Name") { ApplicationArea = All; }
                field("Supervisor No."; Rec."Supervisor No.") { ApplicationArea = All; }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Directorate goals can be created once the workplan is cascaded to Directorates; Department goals once it is cascaded to Departments.';
                }
                field("Directorate Code"; Rec."Directorate Code") { ApplicationArea = All; }
                field("Department Code"; Rec."Department Code") { ApplicationArea = All; }
                field("Period Code"; Rec."Period Code") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Total Weightage %"; Rec."Total Weightage %") { ApplicationArea = All; }
            }
            group(Alignment)
            {
                Caption = 'Strategic Alignment';
                Editable = CanEdit;
                field("Workplan No."; Rec."Workplan No.") { ApplicationArea = All; }
                field("Performance Contract Ref."; Rec."Performance Contract Ref.") { ApplicationArea = All; }
                field("Strategic Plan Reference"; Rec."Strategic Plan Reference") { ApplicationArea = All; }
            }
            part(Lines; "Perf Goal Line Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Goal No." = field("No.");
                UpdatePropagation = Both;
                Editable = CanEdit;
            }
            group(ApprovalTrail)
            {
                Caption = 'Agreement && Approval Trail';
                field("Staff Signed"; Rec."Staff Signed") { ApplicationArea = All; }
                field("Staff Signature Date"; Rec."Staff Signature Date") { ApplicationArea = All; }
                field("Supervisor Signed"; Rec."Supervisor Signed") { ApplicationArea = All; }
                field("Supervisor Signature Date"; Rec."Supervisor Signature Date") { ApplicationArea = All; }
                field("HOD Comments"; Rec."HOD Comments")
                {
                    ApplicationArea = All;
                    Editable = IsPendingHOD;
                    MultiLine = true;
                    ToolTip = 'The HOD enters the required amendments here before choosing Return to Staff.';
                }
                field("CEO Approval Date"; Rec."CEO Approval Date") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SubmitToSupervisor)
            {
                Caption = 'Sign && Submit to Supervisor (HOD)';
                ApplicationArea = All;
                Image = SendTo;
                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                var
                    GoalApprovalMgt: Codeunit "Perf Goal Approval Mgt";
                begin
                    CurrPage.SaveRecord();
                    GoalApprovalMgt.SubmitToSupervisor(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ResubmitAfterAmendment)
            {
                Caption = 'Resubmit After Amendment';
                ApplicationArea = All;
                Image = SendTo;
                Enabled = Rec.Status = Rec.Status::"Returned for Amendment";

                trigger OnAction()
                var
                    GoalApprovalMgt: Codeunit "Perf Goal Approval Mgt";
                begin
                    CurrPage.SaveRecord();
                    GoalApprovalMgt.ResubmitAfterAmendment(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ApproveBySupervisor)
            {
                Caption = 'Agree && Sign (Supervisor/HOD)';
                ApplicationArea = All;
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::"Pending Supervisor Review";

                trigger OnAction()
                var
                    GoalApprovalMgt: Codeunit "Perf Goal Approval Mgt";
                begin
                    GoalApprovalMgt.ApproveBySupervisor(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ReturnToStaff)
            {
                Caption = 'Return to Staff with Comments';
                ApplicationArea = All;
                Image = Reject;
                Enabled = Rec.Status = Rec.Status::"Pending Supervisor Review";

                trigger OnAction()
                var
                    GoalApprovalMgt: Codeunit "Perf Goal Approval Mgt";
                begin
                    CurrPage.SaveRecord();
                    GoalApprovalMgt.ReturnToStaff(Rec, Rec."HOD Comments");
                    CurrPage.Update(false);
                end;
            }
            action(Finalize)
            {
                Caption = 'Approve (CEO)';
                ApplicationArea = All;
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::"Submitted to CEO";

                trigger OnAction()
                var
                    GoalApprovalMgt: Codeunit "Perf Goal Approval Mgt";
                begin
                    GoalApprovalMgt.Finalize(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Reporting)
        {
            action(TargetSettingReport)
            {
                Caption = 'Target Setting Report';
                ApplicationArea = All;
                Image = Report;
                RunObject = report "Perf Target Setting Report";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SubmitToSupervisor_Promoted; SubmitToSupervisor) { }
                actionref(ResubmitAfterAmendment_Promoted; ResubmitAfterAmendment) { }
                actionref(ApproveBySupervisor_Promoted; ApproveBySupervisor) { }
                actionref(ReturnToStaff_Promoted; ReturnToStaff) { }
                actionref(Finalize_Promoted; Finalize) { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CanEdit := Rec.IsEditable();
        IsPendingHOD := Rec.Status = Rec.Status::"Pending Supervisor Review";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CanEdit := true;
        IsPendingHOD := false;
    end;

    var
        CanEdit: Boolean; // drafting or returned for amendment
        IsPendingHOD: Boolean;
}
