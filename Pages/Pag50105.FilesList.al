 
page 50105 "Tasks List"
{
    ApplicationArea = All;
    Caption = 'Files/mails List ';
    PageType = List;
    SourceTable = "Files Table";
    UsageCategory = Lists;
    CardPageId = "Files Card";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document Type"; rec."Document Type")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("File Type"; Rec."File Type")
                {
                    ToolTip = 'Specifies the value of the File Type field.';
                    Visible = false;
                }
                // field("Business Loan Types";Rec."Business Loan Types")
                // {
                //     ToolTip = 'Specifies the value of the Business Loan Type field.';
                // }
                // field("Policy Files Types"; Rec."Policy Files Types")
                // {
                //     ToolTip = 'Specifies the value of the Policy Files Types field.';
                // }
                field("File/Member No."; Rec."File/Member No.")
                {
                    ToolTip = 'Specifies the value of the File/Member No. field.';
                }
                field("File Name/Descrption"; Rec."File Name/Descrption")
                {
                    ToolTip = 'Specifies the value of the File Name/Descrption field.';
                }
                field("File Custodian"; Rec."File Custodian")
                {
                    ToolTip = 'Specifies the value of the File Custodian field.';
                }
                field("File Status"; Rec."File Status")
                {
                    ToolTip = 'Specifies the value of the Stage field.';
                }
            }
        }
    }
}
