namespace PBO.PBO;
using Microsoft.Foundation.Company;
using Microsoft.FixedAssets.Depreciation;
using System.Environment.Configuration;
using System.Email;
using Microsoft.HumanResources.Employee;
using Microsoft.Foundation.Attachment;



page 50102 "PBO Meeting Card"
{
    ApplicationArea = All;
    Caption = 'Meeting Card';
    PageType = Card;
    PromotedActionCategories = 'New,report,Process,Meeting Details,Attachments';
    SourceTable = "PBO Meetings";

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
                    Editable = false;
                }
                field("Meeting Summary"; Rec."Meeting Summary")
                {
                    ToolTip = 'Specifies the value of the Meeting Summary field.', Comment = '%';
                    MultiLine = true;
                }
                field("Meeting Date"; Rec."Meeting Date")
                {
                    ToolTip = 'Specifies the value of the Meeting Date field.', Comment = '%';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        if rec."Meeting Date" < Today then
                            Error('Meeting date cannot be Backdated');

                    end;
                }
                field(Department; Department)
                {
                    ApplicationArea = all;
                }
                field("Department Name"; "Department Name")
                {
                    ApplicationArea = all;
                }
                field("Meeting Time"; Rec."Meeting Time")
                {
                    ToolTip = 'Specifies the value of the Meeting Time field.', Comment = '%';
                }
                field("Brown-Bag"; "Brown-Bag")
                {
                    ApplicationArea = all;
                }
                field("Captured By"; Rec."Captured By")
                {
                    ToolTip = 'Specifies the value of the Captured By field.', Comment = '%';
                    Editable = false;
                    Caption = 'Initiated By';
                }
                field("Date captured"; Rec."Date captured")
                {
                    ToolTip = 'Specifies the value of the Date captured field.', Comment = '%';
                    Editable = false;
                }
                field("Meeting Status"; Rec."Meeting Status")
                {
                    ToolTip = 'Specifies the value of the Meeting Status field.', Comment = '%';
                    Editable = false;
                }
            }
            group("Document Comments")
            {
                field("Document Comment"; Rec."Document Comment")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        if rec."Meeting Status" <> rec."Meeting Status"::Pending then
                            Error('You cannot have document comment this stage');

                    end;
                    // Editable = rec."Meeting Status" = rec."Meeting Status"::Pending;
                }
            }
            part("meeting Task"; "Meeting task")
            {
                ApplicationArea = all;
                SubPageLink = "Commitee Code" = field("Meeting Code");
            }

        }


    }

    actions
    {
        area(Navigation)
        {
            group("Meeting Details")
            {
                action(Committee)
                {
                    ApplicationArea = all;
                    Caption = 'Committee Cub';
                    Image = QualificationOverview;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = page "Commitee Cub Members";
                    RunPageLink = "Commitee Code" = field("Meeting Code");
                    ToolTip = 'Executes the Qualifications action.';
                }
                action("Submit Document")
                {
                    ApplicationArea = all;
                    Caption = 'Request Meeting Approval';
                    Image = SendElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = rec."Meeting Status" = rec."Meeting Status"::Open;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        if not Confirm('Do you want to submit this document?') then
                            exit;
                        rec."Meeting Status" := rec."Meeting Status"::Pending;
                        rec.Modify();
                        CurrPage.Close();

                    end;
                }
                action("Cancell Request")
                {
                    ApplicationArea = all;
                    Caption = 'Cancell Request';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = rec."Meeting Status" = rec."Meeting Status"::Pending;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        if not Confirm('Do you want to cancell this Request?') then
                            exit;
                        rec."Meeting Status" := rec."Meeting Status"::Open;
                        rec.Modify();
                        CurrPage.Close();
                    end;
                }
                action("Submit To proceed")
                {
                    ApplicationArea = all;
                    Caption = 'Approve to proceed';
                    Image = SendElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = rec."Meeting Status" = rec."Meeting Status"::Pending;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        rec.TestField("Document Comment");
                        if not Confirm('Do you want to submit this document to proceed?') then
                            exit;
                        rec."Meeting Status" := rec."Meeting Status"::proceeding;
                        rec.Modify();
                        CurrPage.Close();
                    end;
                }
                action("Mark as successfull")
                {
                    ApplicationArea = all;
                    Caption = 'Mark as successfull';
                    Image = MakeAgreement;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = rec."Meeting Status" = rec."Meeting Status"::proceeding;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        if not Confirm('Do you want to Close and mark this meeting as success?') then
                            exit;
                        rec."Meeting Status" := rec."Meeting Status"::Successful;
                        rec.Modify();
                        CurrPage.Close();
                    end;
                }
                action("Mark as Failled")
                {
                    ApplicationArea = all;
                    Caption = 'Mark as Failled';
                    Image = MakeAgreement;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = rec."Meeting Status" = rec."Meeting Status"::proceeding;
                    trigger OnAction()
                    var
                        myInt: Integer;
                        cALCdEP: Report "Calculate Depreciation";
                    begin
                        if not Confirm('Do you want to Close and mark this meeting as failled?') then
                            exit;
                        rec."Meeting Status" := rec."Meeting Status"::failled;
                        rec.Modify();
                        CurrPage.Close();
                    end;
                }
                action("Notify Committee")
                {
                    ApplicationArea = all;
                    Caption = 'Notify Committee';
                    Image = SendEmailPDFNoAttach;
                    Promoted = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        if Confirm('Do you want to notify the meeting commitee') then
                            NotifyCommittee() else
                            Message('Aborted!');

                    end;
                }
                action(Attachments)
                {
                    Promoted = true;
                    PromotedCategory = Category5;
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
                action(CreateTask)
                {
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = false;
                    trigger OnAction()
                    var
                        myInt: Integer;
                        Hrportal: Codeunit "Hr Portal";
                    begin
                        Hrportal.CreatFilesTask('EH', '4342', Today, 'ADM', 'EH', 'TRES', '43R3EW', 2);

                    end;
                }
            }
        }
    }
    procedure NotifyCommittee()
    var
        myInt: Integer;
        AccName: Text;
        CompanIn: Record "Company Information";
        msg: Text;
        EmailManager: Codeunit "Email Message";
        EmailTable: Record "Email Account";
        HRDiscipMemb: Record "Committee Cub Members";
        Employee: Record Employee;
        Email: Codeunit Email;
        aad: Record "AAD Application";
        AadP: Page "AAD Application Card";

    begin
        HRDiscipMemb.Reset();
        HRDiscipMemb.SetRange(HRDiscipMemb."Commitee Code", Rec."Meeting Code");
        if HRDiscipMemb.FindFirst() then
            repeat
                if Employee.Get(HRDiscipMemb."Employee No") then begin
                    AccName := '';
                    CompanIn.Get();
                    AccName := Employee."First Name";
                    if AccName = '' then
                        AccName := Employee."Middle Name";
                    msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + Rec."Meeting Code" + ' ' + 'and the meeting date is ' + Format(rec."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                    EmailManager.Create(HRDiscipMemb.Email, 'Commitee Notifications', msg, true);
                    Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                end;
            until HRDiscipMemb.Next() = 0;
        Message('Email sent successfully');

    end;

}
