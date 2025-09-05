 
page 50139 "HR Leave Period List"
{
    ApplicationArea = Basic;
    DeleteAllowed = true;
    // ModifyAllowed = false;
    PageType = List;
    SourceTable = "HR Leave Periods";
    UsageCategory = Lists;
    Caption = 'HR Leave Period List';
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Period Code"; Rec."Period Code")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Period Code field.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Period Description"; Rec."Period Description")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("New Fiscal Year"; Rec."New Fiscal Year")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    ToolTip = 'Specifies the value of the New Fiscal Year field.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    ToolTip = 'Specifies the value of the Closed field.';
                }
                field("Date Locked"; "Date Locked")
                {
                    ApplicationArea = all;
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Control1102755008; Outlook) { }
            systempart(Control1102755009; Notes) { }
        }
    }

    actions
    {
        area(Processing)
        {
            action("&Create Year")
            {
                ApplicationArea = Basic;
                Caption = '&Create Year';
                Ellipsis = true;
                Image = CreateYear;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "HR Create Leave Year";
                ToolTip = 'Executes the &Create Year action.';
            }
            action("C&lose Year")
            {
                ApplicationArea = Basic;
                Caption = 'C&lose Year';
                Image = CloseYear;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = codeunit "HR Leave Year - Close";
                ToolTip = 'Executes the C&lose Year action.';
            }
        }
    }
}
