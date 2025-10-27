page 50106 "Files Card"
{
    ApplicationArea = All;
    Caption = 'Task Card';
    PageType = Card;
    SourceTable = "Files Table";
    PromotedActionCategories = 'New,Process,Report,Document Attachment,Process';

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
                field("Author Email"; "Author Email")

                {
                    ApplicationArea = all;
                    Editable = false;
                }
                // field("File Name/Descrption"; Rec."File Name/Descrption")
                // {
                //     ToolTip = 'Specifies the value of the File Name/Descrption field.';
                //     Caption = 'Staff Name';
                // }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = all;
                }
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

                // field("File Volume No."; Rec."File Volume No.")
                // {
                //     ToolTip = 'Specifies the value of the File Volume No. field.';
                // }
            }
            part("Task Volumes"; "Task Volumes List")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Task Progress';
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
                Image = Documents;
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
            action("Send and Notify Receiver")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Image = SendAsPDF;
                trigger OnAction()
                var
                    TaskVolumes: Record "Task Volumes";
                    SeriesSetup: Record "HR setup";
                    DocNo: Code[30];
                    NoSeriesMgt: Codeunit NoSeriesManagement;
                begin
                    if Confirm('Do you want to send and notify receiver?') then begin
                        NotifyReceiver();
                        DocNo := '';
                        TaskVolumes.Reset();
                        TaskVolumes.Init();
                        SeriesSetup.Get;
                        SeriesSetup.TestField(SeriesSetup."Volume Entry No.");
                        DocNo := NoSeriesMgt.GetNextNo(SeriesSetup."Volume Entry No.", 0D, True);
                        TaskVolumes."File No." := rec."Entry No.";
                        TaskVolumes."Volume Entry No." := DocNo;
                        TaskVolumes."Author Code" := rec."Author Code";
                        TaskVolumes.Validate(TaskVolumes."Author Code");
                        TaskVolumes."Date Received" := Today;
                        TaskVolumes."Incoming Date" := rec."Incoming Date";
                        TaskVolumes.Reference := rec.Reference;
                        TaskVolumes."Task Date" := rec."Task Date";
                        TaskVolumes."Document Type" := rec."Document Type";
                        TaskVolumes."Receiver Code" := rec."Receiver Code";
                        TaskVolumes.Validate(TaskVolumes."Receiver Code");
                        TaskVolumes.Department := rec.Department;
                        TaskVolumes.Validate(TaskVolumes.Department);
                        TaskVolumes.Action := rec.Action;
                        TaskVolumes."Task Status" := TaskVolumes."Task Status"::Forwared;
                        TaskVolumes.Feedback := rec.Feedback;
                        TaskVolumes.Remarks := rec.Remarks;
                        if TaskVolumes.Insert() then begin
                            rec."Author Code" := rec."Receiver Code";

                            rec.Validate(rec."Author Code");
                            rec."Reciever Mail" := '';
                            rec.Receiver := '';
                            rec."Task Status" := rec."Task Status"::Forwared;
                            rec."Incoming Date" := Today;
                            rec.Action := '';
                            rec.Remarks := '';
                            rec.Feedback := '';
                            rec.Modify();
                        end;
                        Message('Email sent successfully');
                        CurrPage.Close();

                    end else
                        Message('Aborted!');
                    CurrPage.Close();

                end;
            }
            action("Close Task")
            {
                ApplicationArea = all;
                Caption = 'Close Task';
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    if Confirm('Do you want to close this Task') = true then begin
                        rec."Task Status" := rec."Task Status"::Archived;
                        rec."Date Closed" := Today;
                        rec."Closed By" := UserId;
                        Message('Closed!');
                    end else
                        Message('Aborted');

                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        if rec."Task Status" = rec."Task Status"::Archived then
            CurrPage.Editable := false;
        // UserSet.Reset();
        // UserSet.SetRange("User ID", UserId);
        // if UserSet.FindFirst() then begin
        //     rec.SetFilter("Author Code", UserSet."Staff No");
        // end else
        //     Error('User setup not found!');

    end;

    //local procedure PageControl()
    trigger OnOpenPage()
    begin
        if rec."Task Status" = rec."Task Status"::Archived then
            CurrPage.Editable := false;
        FileTypes();
        restrictfilescardesit();
        // UserSet.Reset();
        // UserSet.SetRange("User ID", UserId);
        // if UserSet.FindFirst() then begin
        //     rec.SetFilter("Author Code", UserSet."Staff No");
        // end else
        //     Error('User setup not found!');
    end;

    trigger OnAfterGetCurrRecord()
    begin
        restrictfilescardesit();
        if rec."Task Status" = rec."Task Status"::Archived then
            CurrPage.Editable := false;
        // UserSet.Reset();
        // UserSet.SetRange("User ID", UserId);
        // if UserSet.FindFirst() then begin
        //     rec.SetFilter("Author Code", UserSet."Staff No");
        // end else
        //     Error('User setup not found!');
    end;

    local procedure restrictfilescardesit()
    var
        UserStations: Record "User Stations";
    begin
        // UserStations.Reset();
        // UserStations.SetRange("User Id", UserId);
        // UserStations.SetRange("Can Edit File Card", true);
        // if not UserStations.Find('-') then begin
        //     CurrPage.Editable := false;
        // end else begin
        //     CurrPage.Editable := true;
        // end;
    end;

    local procedure FileTypes()
    begin
        // VisiblePolicyFilesTypes := false;
        // VisibleBusinessLoansFileTypes := false;

        // if Rec."File Type" = Rec."File Type"::"Accounts File" then begin
        //     VisibleBusinessLoansFileTypes := true;
        //     VisiblePolicyFilesTypes := false;
        // end;
        // if Rec."File Type" = Rec."File Type"::"Hr Tasks" then begin
        //     VisiblePolicyFilesTypes := true;
        //     VisibleBusinessLoansFileTypes := false;
        // end;
    end;

    procedure NotifyReceiver()
    var
        myInt: Integer;
        AccName: Text;
        CompanIn: Record "Company Information";
        msg: Text;
        Emailmessage: Codeunit "Email Message";
        EmailTable: Record "Email Account";
        HRDiscipMemb: Record "Files Table";
        Employee: Record Employee;
        EmailManager: Codeunit "Email Message";
        Email: Codeunit Email;

    begin
        HRDiscipMemb.Reset();
        HRDiscipMemb.SetRange(HRDiscipMemb."Entry No.", Rec."Entry No.");
        if HRDiscipMemb.FindFirst() then
            repeat
                if Employee.Get(HRDiscipMemb."Receiver Code") then begin
                    AccName := '';
                    CompanIn.Get();
                    AccName := Employee."First Name";
                    if AccName = '' then
                        AccName := Employee."Middle Name";
                    msg := 'Dear ' + AccName + ', you have  been assigned task no. ' + ' ' + Rec."Entry No." + ' ' + 'and the task assigned date is ' + Format(rec."Task Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                    EmailManager.Create(HRDiscipMemb."Reciever Mail", 'PBO Notifications', msg, true);
                    Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                end;
            until HRDiscipMemb.Next() = 0;


    end;
    //trigger OnAfterGetRecord()
    var
        VisiblePolicyFilesTypes: Boolean;
        VisibleBusinessLoansFileTypes: Boolean;
        UserSet: Record "User Setup";
}
