namespace PBO.PBO;


page 50144 "Login Register List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Login Register";
    Caption = 'Login Register';
    // CardPageId = "Login Register Card";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user ID.';
                }
                field("Login Date"; Rec."Login Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the login date.';
                }
                field("Login Time"; Rec."Login Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the login time.';
                }
                field("Logout Time"; Rec."Logout Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the logout time.';
                }
                field("Duration (Hours)"; Rec."Duration (Hours)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the duration in hours.';
                    Style = Strong;
                }
                field("Work Summary"; Rec."Work Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the work summary for the day.';
                    Width = 50;
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("New Login Entry")
            {
                ApplicationArea = All;
                Caption = 'New Login Entry';
                Image = NewTimesheet;
                ToolTip = 'Create a new login register entry.';

                trigger OnAction()
                var
                    LoginRegister: Record "Login Register";
                begin
                    LoginRegister.Init();
                    LoginRegister."User ID" := UserId;
                    LoginRegister."Login Date" := Today;
                    LoginRegister."Login Time" := Time;
                    LoginRegister.Insert(true);

                    Rec := LoginRegister;
                    CurrPage.Update(false);
                end;
            }
            action("Set Logout Time")
            {
                ApplicationArea = All;
                Caption = 'Set Logout Time';
                Image = Clock;
                ToolTip = 'Set the logout time to current time.';

                trigger OnAction()
                begin
                    if Rec."Logout Time" <> 0T then
                        if not Confirm('Logout time is already set. Do you want to update it?') then
                            exit;

                    Rec."Logout Time" := Time;
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Reporting)
        {
            action("Print Report")
            {
                ApplicationArea = All;
                Caption = 'Print Report';
                Image = Print;
                Visible = false;
                ToolTip = 'Print the login register report.';

                trigger OnAction()
                begin
                    Message('Report functionality to be implemented.');
                end;
            }
        }
        area(Navigation)
        {
            action("User Statistics")
            {
                ApplicationArea = All;
                Caption = 'User Statistics';
                Image = Statistics;
                Visible = false;
                ToolTip = 'View statistics for the selected user.';

                trigger OnAction()
                begin
                    Message('Statistics functionality to be implemented.');
                end;
            }
        }
    }
}