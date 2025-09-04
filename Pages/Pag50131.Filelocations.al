page 50131 "Task Locations"
{
    ApplicationArea = All;
    Caption = 'Task Locations';
    PageType = ListPart;
    SourceTable = "File Location";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Member No."; Rec."Member No.")
                {
                    ToolTip = 'Specifies the value of the Member No. field.';
                }
                field("Actioning Officer"; "Actioning Officer")
                {
                    ApplicationArea = all;

                }
                field("Officer Name"; "Officer Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approval Type"; Rec."Approval Type")
                {
                    ToolTip = 'Specifies the value of the Approval Type field.';
                    Visible = false;
                }
                field("Section Code"; Rec."Section Code")
                {
                    ToolTip = 'Specifies the value of the Section Code field.';
                }
                field("Responsibility Centre"; Rec."Responsibility Centre")
                {

                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Current Location"; Rec."Current Location")
                {
                    ToolTip = 'Specifies the value of the Current Location field.';
                }
                field("Date/Time In"; Rec."Date/Time In")
                {
                    ToolTip = 'Specifies the value of the Date/Time In field.';
                }
                field("Date/Time Out"; Rec."Date/Time Out")
                {
                    ToolTip = 'Specifies the value of the Date/Time Out field.';
                }
                field("USER ID"; Rec."USER ID")
                {
                    ToolTip = 'Specifies the value of the USER ID field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Station Name"; Rec."Station Name")
                {
                    ToolTip = 'Specifies the value of the Station Name field.';
                }
                field(Station; Rec.Station)
                {
                    ToolTip = 'Specifies the value of the Station field.';
                }
                field(Narration; Rec.Narration)
                {
                    ToolTip = 'Specifies the value of the Narration field.';
                }
                field(Folio; Rec.Folio)
                {
                    ToolTip = 'Specifies the value of the Volume No. field.';
                }
                field("Issued To"; Rec."Issued To")
                {
                    ToolTip = 'Specifies the value of the Issued To field.';
                }
            }
        }
    }
}
