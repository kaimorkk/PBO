namespace PBO.PBO;

page 50132 "Hr Setup"
{
    ApplicationArea = All;
    Caption = 'Hr Setup';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "HR setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Meeting Code"; Rec."Meeting Code")
                {
                    ToolTip = 'Specifies the value of the Meeting Code field.', Comment = '%';
                }
                field("Mail Request"; Rec."Mail Request")
                {
                    ToolTip = 'Specifies the value of the Mail Request field.', Comment = '%';
                }
                field("File Entry No."; Rec."File Entry No.")
                {
                    ToolTip = 'Specifies the value of the File Entry No. field.', Comment = '%';
                }
                field("File Batching No."; Rec."File Batching No.")
                {
                    ToolTip = 'Specifies the value of the File Batching No. field.', Comment = '%';
                }
                field("Task Request"; Rec."Task Request")
                {
                    ToolTip = 'Specifies the value of the Task Request field.', Comment = '%';
                }
                field("Mail Entry No"; Rec."Mail Entry No")
                {
                    ToolTip = 'Specifies the value of the Mail Entry No field.', Comment = '%';
                }
                field("Volume Entry No."; Rec."Volume Entry No.")
                {
                    ToolTip = 'Specifies the value of the Volume Entry No. field.', Comment = '%';
                }
                field("Leave Application Nos."; "Leave Application Nos.")
                {
                    ApplicationArea = ALL;
                }
                field("Leave Posting Period[FROM]"; "Leave Posting Period[FROM]")
                {
                    ApplicationArea = all;
                }
                field("Leave Posting Period[TO]"; "Leave Posting Period[TO]")
                {
                    ApplicationArea = all;
                }
                field("Leave Batch"; "Leave Batch")
                {
                    ApplicationArea = all;
                }
                field("Leave Template"; "Leave Template")
                {
                    ApplicationArea = all;
                }
                field("Bill Costing"; "Bill Costing")
                {
                    ApplicationArea = all;
                }
                field("Bill Determination"; "Bill Determination")
                {
                    ApplicationArea = all;
                }
                field("Outgoing Correspondence"; "Outgoing Correspondence")
                {
                    ApplicationArea = all;
                }
                field("Incoming Correspondence"; "Incoming Correspondence")
                {
                    ApplicationArea = all;
                }
                field("Outgoing Memos"; "Outgoing Memos")
                {
                    ApplicationArea = all;
                }
                field("Incoming Memos"; "Incoming Memos")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
