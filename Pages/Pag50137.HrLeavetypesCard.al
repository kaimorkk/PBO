 
page 50137 "HR Leave Types Card"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "HR Leave Types";
    ApplicationArea = All;
    Caption = 'HR Leave Types Card';
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic;
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
                field("Acrue Days"; Rec."Acrue Days")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Acrue Days field.';
                }
                field("Unlimited Days"; Rec."Unlimited Days")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Unlimited Days field.';
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Gender field.';
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Balance field.';
                }
                field("Max Carry Forward Days"; Rec."Max Carry Forward Days")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Max Carry Forward Days field.';
                }
                field("Carry Forward Allowed"; Rec."Carry Forward Allowed")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Carry Forward Allowed field.';
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
                field("Apply Once Per FY?"; Rec."Apply Once Per FY?")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Apply Once Per FY? field.';
                }
            }
        }
    }

    actions { }
}
