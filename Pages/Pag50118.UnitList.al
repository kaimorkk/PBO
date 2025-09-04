 

page 50118 "Unit List"
{
    Editable = true;
    PageType = List;
    SourceTable = Unit;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                ShowCaption = false;
                field("Property No."; Rec."Property No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Property Name"; Rec."Property Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Floor Code"; Rec."Floor Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Code"; Rec."Unit Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Unit Name';
                }
                field("Unit Type"; Rec."Unit Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Status"; Rec."Unit Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Occupied"; Rec.Occupied)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                // field("Unit Type Name"; Rec."Unit Type Name")
                // {
                //     ApplicationArea = Basic, Suite;
                // }
                field("Area Square ft"; Rec."Area Square ft")
                {
                    ApplicationArea = Basic, Suite;
                }
                // field("Meter No."; Rec."Meter No.")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Water Meter No.';
                // }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;
}

