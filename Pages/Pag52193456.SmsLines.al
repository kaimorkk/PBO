
page 52193456 "Sms Lines"
{
    ApplicationArea = All;
    Caption = 'GreenSms Lines';
    PageType = ListPart;
    SourceTable = "Sms Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Client No"; Rec."Client No")
                {
                    ToolTip = 'Specifies the value of the Client No field.', Comment = '%';
                }
                field("Client Name"; Rec."Client Name")
                {
                    ToolTip = 'Specifies the value of the Client Name field.', Comment = '%';
                }

                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = all;
                }
                field("Sms sent"; Rec."Sms sent")
                {
                    ToolTip = 'Specifies the value of the Sms sent field.', Comment = '%';
                    Editable = false;
                }
            }
        }
    }
}
