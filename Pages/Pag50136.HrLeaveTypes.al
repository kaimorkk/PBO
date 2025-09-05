 
page 50136 "HR Leave Types"
{
    ApplicationArea = Basic;
    CardPageId = "HR Leave Types Card";
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "HR Leave Types";
    UsageCategory = Administration;
    Caption = 'HR Leave Types';
    layout
    {
        area(Content)
        {
            repeater(Control1000000000)
            {
                Editable = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic;
                    Style = StandardAccent;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Days field.';
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Gender field.';
                }
                field("Max Carry Forward Days"; Rec."Max Carry Forward Days")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Max Carry Forward Days field.';
                }
                field("Inclusive of Non Working Days"; Rec."Inclusive of Non Working Days")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Inclusive of Non Working Days field.';
                }
                field("Allow Edit No. of Days?"; Rec."Allow Edit No. of Days?")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Allow Edit No. of Days? field.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Control1102755003; Outlook) { }
            systempart(Control1102755004; Notes) { }
        }
    }

    actions { }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;
}
