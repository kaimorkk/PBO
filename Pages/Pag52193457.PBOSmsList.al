
page 52193457 "PBO Sms List"
{
    ApplicationArea = All;
    Caption = 'PBO sms List';
    PageType = List;
    SourceTable = "Sms Header";
    UsageCategory = Lists;
    CardPageId = "Bulk Sms";
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec.No)
                {
                    ToolTip = 'Specifies the value of the No field.', Comment = '%';
                }
                field("Entered By"; Rec."Entered By")
                {
                    ToolTip = 'Specifies the value of the Entered By field.', Comment = '%';
                }
                field("Managed By"; Rec."Managed By")
                {
                    ToolTip = 'Specifies the value of the Managed By field.', Comment = '%';
                }
                field("Date Entered"; Rec."Date Entered")
                {
                    ToolTip = 'Specifies the value of the Date Entered field.', Comment = '%';
                }
                field("SMS Type"; Rec."SMS Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the SMS Type field.', Comment = '%';
                }
                field("SMS Status"; Rec."SMS Status")
                {
                    ToolTip = 'Specifies the value of the SMS Status field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
            }
        }
    }
}
