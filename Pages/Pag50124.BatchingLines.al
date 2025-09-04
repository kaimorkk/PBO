 

page 50124 "Batching Lines"
{
    Caption = 'Batching Lines';
    PageType = ListPart;
    SourceTable = "Batch Lines Table";
    Editable = False;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batche No. field.';
                }
                field("Date Batched"; Rec."Date Batched")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Batched field.';
                }
                field("File No."; Rec."File No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File No. field.';
                }
                // field("Folio No."; Rec."Folio No.")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Folio No. field.';
                // }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Name field.';
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member No. field.';
                }
                field("Staff PF No."; Rec."Staff PF No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff PF No. field.';
                }
                field("Volume No."; Rec."Volume No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Volume No. field.';
                }
                field(Archived; Rec.Archived)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived field.';
                }
            }
        }
    }
}
