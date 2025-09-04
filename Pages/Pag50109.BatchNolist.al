namespace PBO.PBO;
page 50109 "Batch No List"
{
    ApplicationArea = All;
    Caption = 'Batch No List';
    PageType = List;
    SourceTable = "Batch No Table";
    UsageCategory = Lists;
    //SourceTableView = sorting("Batch Number") order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Batch Entry No."; Rec."Batch Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch Entry No. field.';
                    Editable = false;
                }
                Field("Batch No."; Rec.Batch)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch No. field.';
                    Caption = 'Batch';
                }
                field("Batch Sequence"; Rec."Batch Sequence")
                {
                    ToolTip = 'Specifies the value of the Batch Sequence field.';
                }
                field("Batch Number"; Rec."Batch Number")
                {
                    ToolTip = 'Specifies the value of the Batch Number field.';
                    Editable = false;
                }
            }
        }
    }
}
