page 52193466 "Perf Goal Header List"
{
    Caption = 'Individual Performance Goals';
    PageType = List;
    SourceTable = "Perf Goal Header";
    CardPageId = "Perf Goal Header Card";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Employee Name"; Rec."Employee Name") { ApplicationArea = All; }
                field("Supervisor No."; Rec."Supervisor No.") { ApplicationArea = All; }
                field(Level; Rec.Level) { ApplicationArea = All; }
                field("Directorate Code"; Rec."Directorate Code") { ApplicationArea = All; }
                field("Department Code"; Rec."Department Code") { ApplicationArea = All; }
                field("Period Code"; Rec."Period Code") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Total Weightage %"; Rec."Total Weightage %") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(MyPendingApprovals)
            {
                Caption = 'My Pending Approvals (as Supervisor)';
                ApplicationArea = All;
                Image = FilterLines;

                trigger OnAction()
                var
                    EmployeeMgt: Codeunit "Perf Employee Mgt";
                    MyEmployeeNo: Code[20];
                begin
                    Rec.SetRange(Status, Rec.Status::"Pending Supervisor Review");
                    MyEmployeeNo := EmployeeMgt.GetEmployeeNoForCurrentUser();
                    if MyEmployeeNo <> '' then
                        Rec.SetRange("Supervisor No.", MyEmployeeNo);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
