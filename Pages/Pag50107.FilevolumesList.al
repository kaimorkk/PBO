namespace PBO.PBO;


page 50107 "Task Volumes List"
{
    ApplicationArea = All;
    Caption = 'Task Volumes List';
    PageType = Listpart;
    SourceTable = "Task Volumes";
    //CardPageId = "Task Volumes Card";
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("File No."; Rec."File No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the File No. field.';
                }
                field(Author; Author)
                {
                    ApplicationArea = all;
                }
                field(Receiver; Receiver)
                {
                    ApplicationArea = all;
                }
                // field("Volume Entry No."; Rec."Volume Entry No.")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Volume Entry No. field.';
                // }
                field("File Volume No."; Rec."File Volume No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the File Volume No. field.';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    Caption = 'Volume';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                // field("Archived By"; Rec."Archived By")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Archived By field.';
                // }
                field("Volume Status"; Rec."Volume Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Volume Status field.';
                }

                field(Department; Department)
                {
                    ApplicationArea = all;
                }
                field(Remarks; Remarks)
                {
                    ApplicationArea = all;
                }

                // field("Closed By"; Rec."Closed By")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Closed By field.';
                // }
                // field("Date Archived"; Rec."Date Archived")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Date Archived field.';
                // }

                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Location field.';
                }
                field("Archived "; Rec."Archived")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Archived  field.';
                }
                field(Action; Action)
                {
                    ApplicationArea = all;
                }


                field("Incoming Date"; "Incoming Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Year Opened field.';
                }
                field("Date Received"; "Date Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Year of Closure field.';
                }
            }
        }
    }
}
