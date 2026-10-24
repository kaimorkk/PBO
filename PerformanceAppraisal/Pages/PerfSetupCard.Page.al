page 52193475 "Perf Setup Card"
{
    Caption = 'Performance Appraisal Setup';
    PageType = Card;
    SourceTable = "Perf Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Scoring)
            {
                Caption = 'Scoring Formula';
                field("Self Assessment Weight %"; Rec."Self Assessment Weight %") { ApplicationArea = All; }
                field("Supervisor Assessment Weight %"; Rec."Supervisor Assessment Weight %") { ApplicationArea = All; }
                field("Score Rounding Precision"; Rec."Score Rounding Precision") { ApplicationArea = All; }
            }
            group(Roles)
            {
                Caption = 'Roles';
                field("HR Manager No."; Rec."HR Manager No.") { ApplicationArea = All; }
                field("GM HR&A No."; Rec."GM HR&A No.") { ApplicationArea = All; }
                field("Enforce Approver Identity"; Rec."Enforce Approver Identity")
                {
                    ApplicationArea = All;
                    ToolTip = 'When on, each step can only be performed by the user linked (Employee User ID) to the staff member, HOD, next level supervisor, CEO (Is CEO), HR Manager or GM HR&A.';
                }
            }
            group(Letters)
            {
                Caption = 'Letters';
                field("Commendation Letter Threshold"; Rec."Commendation Letter Threshold") { ApplicationArea = All; }
                field("Warning Letter Threshold"; Rec."Warning Letter Threshold") { ApplicationArea = All; }
            }
            group(Numbering)
            {
                Caption = 'No. Series';
                field("Goal No. Series"; Rec."Goal No. Series") { ApplicationArea = All; }
                field("Review No. Series"; Rec."Review No. Series") { ApplicationArea = All; }
            }
            group(Notifications)
            {
                Caption = 'Notifications';
                field("Send Email Alerts"; Rec."Send Email Alerts") { ApplicationArea = All; }
                field("Reminder Days Before Deadline"; Rec."Reminder Days Before Deadline") { ApplicationArea = All; }
                field("Notify Supervisor on Submit"; Rec."Notify Supervisor on Submit") { ApplicationArea = All; }
                field("Notify Employee on Return"; Rec."Notify Employee on Return") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(RatingScale)
            {
                Caption = 'Rating Scale';
                ApplicationArea = All;
                Image = SetupList;
                RunObject = page "Perf Rating Scale";
            }
            action(AppraisalPeriods)
            {
                Caption = 'Appraisal Periods';
                ApplicationArea = All;
                Image = Period;
                RunObject = page "Perf Appraisal Period List";
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
