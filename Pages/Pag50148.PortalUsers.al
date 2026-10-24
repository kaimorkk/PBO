namespace PBO.PBO;

page 50016 "Portal Users"
{
    ApplicationArea = All;
    Caption = 'Portal Users';
    PageType = List;
    SourceTable = "portal User";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Id Number"; Rec."Id Number")
                {
                    ToolTip = 'Specifies the value of the Id Number field.', Comment = '%';
                }
                field("Full Name"; Rec."Full Name")
                {
                    ToolTip = 'Specifies the value of the Full Name field.', Comment = '%';
                }
                field(Notified; Rec.Notified)
                {
                    ToolTip = 'Specifies the value of the Notified field.', Comment = '%';
                }
                field("Authentication Email"; Rec."Authentication Email")
                {
                    ToolTip = 'Specifies the value of the Authentication Email field.', Comment = '%';
                }
                field(Emailsent; Rec.Emailsent)
                {
                    ToolTip = 'Specifies the value of the Emailsent field.', Comment = '%';
                }
                field("Password Value"; Rec."Password Value")
                {
                    ToolTip = 'Specifies the value of the Password Value field.', Comment = '%';
                }
                field(PasswordChanged; Rec.PasswordChanged)
                {
                    ToolTip = 'Specifies the value of the PasswordChanged field.', Comment = '%';
                }
            }
        }
    }
}
