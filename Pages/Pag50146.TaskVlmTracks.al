namespace PBO.PBO;
using System.Security.User;

page 50146 "Task Vlm Tracks"
{
    ApplicationArea = All;
    Caption = 'Task Volume Tracking';
    PageType = List;
    SourceTable = "Task Volumes";
    CardPageId = "Task Track VolumesCrd";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
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

                // field("Author"; Rec."Author")
                // {
                //     ToolTip = 'Specifies the value of the File/Member No. field.';
                //     Caption = 'Author';
                //     trigger OnValidate()
                //     var
                //         myInt: Integer;
                //     begin

                //     end;
                // }
                // field("Author Email"; "Author Mail")

                // {
                //     ApplicationArea = all;
                //     Editable = false;
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
                    // MultiLine = true;
                }
                field(Feedback; Feedback)
                {
                    ApplicationArea = all;
                    //MultiLine = true;
                }

            }
        }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
        UserSet: Record "User Setup";
    begin
        if UserSet.Get(UserId) then begin
            rec.FilterGroup(2);
            rec.SetFilter(rec."Author Code", UserSet."Staff No");
            rec.FilterGroup(0);
        end;
    end;
}
