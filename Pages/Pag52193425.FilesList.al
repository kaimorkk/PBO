
page 52193425 "Tasks List"
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
                field("Author"; Rec."Author")
                {
                    ToolTip = 'Specifies the value of the File/Member No. field.';
                }

                field(Department; Rec.Department)
                {
                    ToolTip = 'Specifies the value of the File Custodian field.';
                }
                field("Task Status"; Rec."Task Status")
                {
                    ToolTip = 'Specifies the value of the Stage field.';
                }
                field(DocNO; DocNO)
                {
                    ApplicationArea = all;
                    Visible = false;
                    Caption = 'Doc No';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = all;
                }
                field("Incoming Date"; "Incoming Date")
                {
                    ApplicationArea = all;
                }
                field("Sector/Category"; "Sector/Category")
                {
                    ApplicationArea = all;
                }
                field("Is Department Task"; "Is Department Task")
                {
                    ApplicationArea = all;
                }
                field("Captured By"; "Captured By")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        // UserSet.Reset();
        // UserSet.SetRange("User ID", UserId);
        // if UserSet.FindFirst() then begin
        //     rec.SetFilter(rec."Author Code", UserSet."Staff No");
        // end else
        //     Error('User setup not found!');

    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin

        // UserSet.Reset();
        // UserSet.SetRange("User ID", UserId);
        // if UserSet.FindFirst() then begin
        //     rec.SetFilter(rec."Author Code", UserSet."Staff No");
        // end else
        //     Error('User setup not found!');

    end;

    trigger OnOpenPage()
    var
        myInt: Integer;

    begin
        if UserSet.Get(UserId) then begin
            IF UserSet.HOD <> true then begin
                rec.FilterGroup(2);
                rec.SetFilter(rec."Author Code", UserSet."Staff No");
                rec.FilterGroup(0);
            END;
        end;

        //UserSet.Get(UserId);
        //rec.SetFilter(rec."Author Code", UserSet."Staff No");


    end;

    trigger OnNewRecord(exre: Boolean)
    var
        myInt: Integer;
        userSet: Record "User Setup";
    begin
        if userSet.Get(UserId) then begin
            IF userSet.HOD <> true then begin
                rec."Author Code" := userSet."Staff No";
                rec.Validate(rec."Author Code");
            END;
        end;

    end;

    var
        UserSet: Record "User Setup";
}
