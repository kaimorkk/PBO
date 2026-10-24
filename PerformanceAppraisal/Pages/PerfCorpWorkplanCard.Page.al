page 52193462 "Perf Corp. Workplan Card"
{
    Caption = 'Corporate Annual Workplan';
    PageType = Document;
    SourceTable = "Perf Corporate Workplan";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = IsOpen;
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Fiscal Year"; Rec."Fiscal Year") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Strategic Plan Reference"; Rec."Strategic Plan Reference") { ApplicationArea = All; }
                field("Performance Contract Ref."; Rec."Performance Contract Ref.") { ApplicationArea = All; }
                field("Uploaded File Name"; Rec."Uploaded File Name") { ApplicationArea = All; }
                field("No. of Objectives"; Rec."No. of Objectives") { ApplicationArea = All; }
            }
            group(Approval)
            {
                Caption = 'CEO Approval && Cascading';
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Approved by CEO"; Rec."Approved by CEO") { ApplicationArea = All; }
                field("CEO Approval Date"; Rec."CEO Approval Date") { ApplicationArea = All; }
                field("CEO User ID"; Rec."CEO User ID") { ApplicationArea = All; }
            }
            part(Lines; "Perf Corp. Workplan Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Workplan No." = field("No.");
                UpdatePropagation = Both;
                Editable = IsOpen;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadDocument)
            {
                Caption = 'Upload Workplan Document';
                ApplicationArea = All;
                Image = Import;
                Enabled = IsOpen;

                trigger OnAction()
                begin
                    Rec.UploadDocument();
                end;
            }
            action(DownloadDocument)
            {
                Caption = 'Download Workplan Document';
                ApplicationArea = All;
                Image = Export;

                trigger OnAction()
                begin
                    Rec.DownloadDocument();
                end;
            }
            action(ApproveByCEO)
            {
                Caption = 'Approve (CEO)';
                ApplicationArea = All;
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    Rec.ApproveByCEO();
                end;
            }
            action(CascadeToDirectorates)
            {
                Caption = 'Cascade to Directorates';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Enabled = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    Message(CascadedDirMsg, Rec.CascadeToDirectorates());
                end;
            }
            action(CascadeToDepartments)
            {
                Caption = 'Cascade to Departments';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Enabled = Rec.Status = Rec.Status::"Cascaded to Directorates";

                trigger OnAction()
                begin
                    Message(CascadedDeptMsg, Rec.CascadeToDepartments());
                end;
            }
            action(ReturnForRevision)
            {
                Caption = 'Return to CEO for Revision';
                ApplicationArea = All;
                Image = Reject;
                Enabled = not IsOpen;

                trigger OnAction()
                begin
                    Rec.ReturnForRevision();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ApproveByCEO_Promoted; ApproveByCEO) { }
                actionref(CascadeToDirectorates_Promoted; CascadeToDirectorates) { }
                actionref(CascadeToDepartments_Promoted; CascadeToDepartments) { }
                actionref(ReturnForRevision_Promoted; ReturnForRevision) { }
            }
            group(Category_Document)
            {
                Caption = 'Document';
                actionref(UploadDocument_Promoted; UploadDocument) { }
                actionref(DownloadDocument_Promoted; DownloadDocument) { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsOpen := Rec.Status = Rec.Status::Open;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsOpen := true;
    end;

    var
        IsOpen: Boolean;
        CascadedDirMsg: Label 'Workplan objectives have been cascaded to Heads of Directorates and %1 directorate goal document(s) were created. Directorate-level targets can now be linked to this workplan.', Comment = '%1 = number of documents';
        CascadedDeptMsg: Label 'Workplan objectives have been cascaded to Heads of Departments and %1 department goal document(s) were created. Staff can now link individual targets to this workplan.', Comment = '%1 = number of documents';
}
