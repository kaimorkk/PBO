 
page 50128 "Batching Lines List"
{
    ApplicationArea = All;
    Caption = 'Batching Lines List';
    PageType = List;
    SourceTable = "Batch Lines Table";
    UsageCategory = Lists;
    SourceTableView = where("Archived" = const(true));

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
                field("File No."; Rec."File No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File No. field.';
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member No. field.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Name field.';
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
                field("Date Archived"; Rec."Date Archived")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Archived field.';
                }
                field("Archived By"; Rec."Archived By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived By field.';
                }
                FIELD("Archived"; Rec.Archived)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived field.';
                }
            }
        }
    }
}
