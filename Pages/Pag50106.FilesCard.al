namespace PBO.PBO;
using Microsoft.Foundation.Attachment;


page 50106 "Files Card"
{
    ApplicationArea = All;
    Caption = 'Task Card';
    PageType = Card;
    SourceTable = "Files Table";
    PromotedActionCategories = 'New,Process,Report,Document Attachment';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document Type"; rec."Document Type")
                {
                    ApplicationArea = all;
                    Caption = 'Document Type';

                }
                field("Task Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Editable = false;

                }
                field("File Type"; Rec."File Type")
                {
                    ToolTip = 'Specifies the value of the File Type field.';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        if Rec."File Type" = Rec."File Type"::"Accounts File" then begin
                            VisibleBusinessLoansFileTypes := true;
                            VisiblePolicyFilesTypes := false
                        end;
                        if Rec."File Type" = Rec."File Type"::"Hr Tasks" then begin
                            VisiblePolicyFilesTypes := true;
                            VisibleBusinessLoansFileTypes := false;
                        end;
                    end;
                }
                // field("File Sub Type"; Rec."File Sub Type")
                // {
                //     ToolTip = 'Specifies the value of the File Sub Type field.';
                // }
                field("Business Loans File Types"; Rec."Business Loan Types")
                {
                    ToolTip = 'Specifies the value of the Business Loan Type field.';
                    Visible = false;
                }
                field("Policy Files Types"; Rec."Policy Files Types")
                {
                    ToolTip = 'Specifies the value of the Policy Files Types field.';
                    Visible = false;
                }
                field("File/Member No."; Rec."File/Member No.")
                {
                    ToolTip = 'Specifies the value of the File/Member No. field.';
                    Caption = 'Staff No.';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin

                    end;
                }
                field("File Name/Descrption"; Rec."File Name/Descrption")
                {
                    ToolTip = 'Specifies the value of the File Name/Descrption field.';
                    Caption = 'Staff Name';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    Caption = 'Reference No.';
                }

                field("Staff PF No."; Rec."Staff PF No.")
                {
                    ToolTip = 'Specifies the value of the Staff PF No. field.';
                    //Editable = false;
                    Visible = false;
                }
                field("File Custodian"; Rec."File Custodian")
                {
                    ToolTip = 'Specifies the value of the File Custodian field.';
                    Caption = 'Department';
                }
                field("Task Status"; Rec."File Status")
                {
                    ToolTip = 'Specifies the value of the Stage field.';
                    Editable = false;
                }
                // field("Member Status"; Rec."Member Status")
                // {
                //     Editable = false;
                // }
                //HR Files
                // field("Staff No."; Rec."Staff No.")
                // {
                //     ToolTip = 'Specifies the value of the Staff No. field.';
                //     //Visible = false;
                // }
                field("ID No."; Rec."ID No.")
                {
                    ToolTip = 'Specifies the value of the ID No. field.';
                    //Visible = false;
                }
                // field("File Volume No."; Rec."File Volume No.")
                // {
                //     ToolTip = 'Specifies the value of the File Volume No. field.';
                // }
            }
            part("Task Volumes"; "Task Volumes List")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Task Volumes';
                SubPageLink = "File No." = field("Entry No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Attachments)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                // EmployeeRec: Record "HR Employee Requisitions";
                begin

                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
    }

    //local procedure PageControl()
    trigger OnOpenPage()
    begin
        FileTypes();
        restrictfilescardesit()
    end;

    trigger OnAfterGetCurrRecord()
    begin
        restrictfilescardesit();
    end;

    local procedure restrictfilescardesit()
    var
        UserStations: Record "User Stations";
    begin
        UserStations.Reset();
        UserStations.SetRange("User Id", UserId);
        UserStations.SetRange("Can Edit File Card", true);
        if not UserStations.Find('-') then begin
            CurrPage.Editable := false;
        end else begin
            CurrPage.Editable := true;
        end;
    end;

    local procedure FileTypes()
    begin
        VisiblePolicyFilesTypes := false;
        VisibleBusinessLoansFileTypes := false;

        if Rec."File Type" = Rec."File Type"::"Accounts File" then begin
            VisibleBusinessLoansFileTypes := true;
            VisiblePolicyFilesTypes := false;
        end;
        if Rec."File Type" = Rec."File Type"::"Hr Tasks" then begin
            VisiblePolicyFilesTypes := true;
            VisibleBusinessLoansFileTypes := false;
        end;
    end;
    //trigger OnAfterGetRecord()
    var
        VisiblePolicyFilesTypes: Boolean;
        VisibleBusinessLoansFileTypes: Boolean;
}
