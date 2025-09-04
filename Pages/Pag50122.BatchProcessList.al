 

page 50122 "Batching Process List"
{
    ApplicationArea = All;
    Caption = 'Batching Process List';
    PageType = List;
    SourceTable = "Batching Process Table";
    UsageCategory = Lists;
    CardPageID = "Batching Process Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No field.';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                field(Batch; Rec.Batch)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch field.';
                }
                field(Town; Rec.Town)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Town field.';
                }
                field("Building Name"; Rec."Building Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Building Name field.';
                }
                field("Floor No."; Rec."Floor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Floor No. field.';
                }
                field("Created at"; Rec."Created at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created at field.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created By field.';
                }
            }
        }
    }
}
