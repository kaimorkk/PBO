pageextension 52193423 "Perf Employee Card Ext" extends "Employee Card"
{
    layout
    {
        addlast(content)
        {
            group(PerformanceAppraisal)
            {
                Caption = 'Performance Appraisal';
                field("Perf Supervisor No."; Rec."Perf Supervisor No.") { ApplicationArea = All; }
                field("Perf Directorate Code"; Rec."Perf Directorate Code") { ApplicationArea = All; }
                field("Perf Region Code"; Rec."Perf Region Code") { ApplicationArea = All; }
                field("Perf Grade"; Rec."Perf Grade") { ApplicationArea = All; }
                field("Perf Is HOD"; Rec."Perf Is HOD") { ApplicationArea = All; }
                field("Perf Is Head of Directorate"; Rec."Perf Is Head of Directorate") { ApplicationArea = All; }
                field("Perf Is CEO"; Rec."Perf Is CEO") { ApplicationArea = All; }
                field("Perf User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    ToolTip = 'The Business Central user who acts for this employee in appraisal approvals.';
                }
            }
        }
    }
}
