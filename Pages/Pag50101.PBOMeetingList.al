page 50101 "PBO Meeting List"
{
    ApplicationArea = All;
    Caption = 'Executing Meeting List';
    PageType = List;
    SourceTable = "PBO Meetings";
    CardPageId = "PBO Meeting Card";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Meeting Code"; Rec."Meeting Code")
                {
                    ToolTip = 'Specifies the value of the Meeting Code field.', Comment = '%';
                }
                field("Meeting Summary"; Rec."Meeting Summary")
                {
                    ToolTip = 'Specifies the value of the Meeting Summary field.', Comment = '%';
                }
                field("Meeting Date"; Rec."Meeting Date")
                {
                    ToolTip = 'Specifies the value of the Meeting Date field.', Comment = '%';
                }
                field("Date captured"; Rec."Date captured")
                {
                    ToolTip = 'Specifies the value of the Date captured field.', Comment = '%';
                }
                field("Captured By"; Rec."Captured By")
                {
                    ToolTip = 'Specifies the value of the Captured By field.', Comment = '%';
                }
                field("Meeting Status"; Rec."Meeting Status")
                {
                    ToolTip = 'Specifies the value of the Meeting Status field.', Comment = '%';
                }
            }
        }
    }
}
