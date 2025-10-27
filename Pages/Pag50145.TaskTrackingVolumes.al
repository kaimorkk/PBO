namespace PBO.PBO;
using Microsoft.Foundation.Attachment;

page 50145 "Task Track VolumesCrd"
{
    ApplicationArea = All;
    Caption = 'Task Volume Tracking';
    PageType = Card;
    SourceTable = "Task Volumes";
    PromotedActionCategories = 'New,Process,Report,Attachments';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Document Type"; rec."Document Type")
                {
                    ApplicationArea = all;
                    Caption = 'Document Type';

                }
                field("Task Entry No."; Rec."File No.")
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
                        // if Rec."File Type" = Rec."File Type"::"Accounts File" then begin
                        //     VisibleBusinessLoansFileTypes := true;
                        //     VisiblePolicyFilesTypes := false
                        // end;
                        // if Rec."File Type" = Rec."File Type"::"Hr Tasks" then begin
                        //     VisiblePolicyFilesTypes := true;
                        //     VisibleBusinessLoansFileTypes := false;
                        // end;
                    end;
                }
                // field("File Sub Type"; Rec."File Sub Type")
                // {
                //     ToolTip = 'Specifies the value of the File Sub Type field.';
                // }

                field("Author"; Rec."Author")
                {
                    ToolTip = 'Specifies the value of the File/Member No. field.';
                    Caption = 'Author';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin

                    end;
                }
                field("Author Email"; "Author Mail")

                {
                    ApplicationArea = all;
                    Editable = false;
                }
                // field("File Name/Descrption"; Rec."File Name/Descrption")
                // {
                //     ToolTip = 'Specifies the value of the File Name/Descrption field.';
                //     Caption = 'Staff Name';
                // }

                field(Reference; Rec.Reference)
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    Caption = 'Reference';
                }


                field(Department; Rec.Department)
                {
                    ToolTip = 'Specifies the value of the File Custodian field.';
                    Caption = 'Department';
                }
                field("Department Name"; "Department Name")
                {
                    ApplicationArea = all;
                }
                field("Task Status"; "Task Status")
                {
                    ToolTip = 'Specifies the value of the Stage field.';
                    Editable = false;
                    Visible = false;
                }

                field("Incoming Date"; "Incoming Date")
                {
                    ApplicationArea = all;
                }
                field(Receiver; Receiver)
                {
                    ApplicationArea = all;
                }
                field("Reciever Mail"; "Reciever Mail")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Action; Action)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field(Feedback; Feedback)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field(Remarks; Remarks)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }

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
                Image = Documents;
                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                    filetable: Record "Files Table";
                // EmployeeRec: Record "HR Employee Requisitions";
                begin
                    filetable.Reset();
                    filetable.SetRange("Entry No.", rec."File No.");
                    if filetable.FindFirst() then begin
                        RecRef.GetTable(filetable);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                end;
            }

        }
    }

}
