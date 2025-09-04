page 50104 "Commitee Cub Members"
{
    ApplicationArea = All;
    Caption = '  Commitee Cub Members';
    PageType = List;
    SourceTable = "Committee Cub Members";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Staff No"; Rec."Employee No")
                {
                    ToolTip = 'Specifies the value of the Employee No. field.', Comment = '%';
                }
                field(Names; Rec.Names)
                {
                    ToolTip = 'Specifies the value of the Names field.';
                }
                field(Designation; Rec.Designation)
                {
                    ToolTip = 'Specifies the value of the Designation field.';
                }
                field(Role; Rec.Role)
                {
                    ToolTip = 'Specifies the value of the Role field.';
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the value of the Email field.', Comment = '%';
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ToolTip = 'Specifies the value of the Phone Number field.', Comment = '%';
                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.';
                }
            }
        }
    }
}
