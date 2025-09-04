 
page 50123 "Batching Process Card"
{
    Caption = 'Batching Process Card';
    PageType = Card;
    SourceTable = "Batching Process Table";
    PromotedActionCategories = 'Home, New, Report, Approval Workflow, Process, Archive, Batch';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No field.';
                    Editable = false;
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                field("Batch"; Rec.Batch)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch field.';
                    Editable = false;
                }
                field("File Location No."; Rec."File Location No.")
                {
                    ApplicationArea = All;
                    Caption = 'File Location No.';
                    ToolTip = 'Specifies the value of the File Location field.';
                }
                field(Town; Rec.Town)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Town field.';
                    Editable = false;
                }
                field("Building Name"; Rec."Building Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Location field.';
                    Editable = false;
                }
                field("Floor No."; Rec."Floor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Floor No. field.';
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created By field.';
                    Editable = false;
                }
                field("Created at"; Rec."Created at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created at field.';
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                    Editable = false;
                    Caption = 'Branch Code';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
                    Editable = false;
                    Caption = 'Activity Code';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsibility Center field.';
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                    Editable = false;

                }
            }
            part("Batch Files"; "Batching Lines")
            {
                ApplicationArea = All;
                Caption = 'Batch Files';
                //SubPageLink = "Batch No." = field("Batch No.");
                SubPageLink = "Header No." = field("No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Archive Files")
            {
                ApplicationArea = All;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Category6;
                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    //Rec.TestField(Status, Rec.Status::Approved);
                    if Not confirm('Are you sure you want to archive this batch?') then
                        exit;
                    BatchLines.RESET;
                    BatchLines.SetRange(Archived, false);
                    BatchLines.SETRANGE("Batch No.", Rec."Batch");
                    if BatchLines.FINDSET then
                        repeat
                            BatchLines.TESTFIELD("Archived", false);
                            BatchLines.Archived := True;
                            BatchLines."Date Archived" := Today;
                            BatchLines."Archived By" := UserId;
                            BatchLines.MODIFY;
                        until BatchLines.NEXT = 0;

                    FileVolumes.RESET;
                    FileVolumes.SetRange(Archived, false);
                    FileVolumes.SETRANGE("Batch", Rec."Batch");
                    if FileVolumes.FindSet() then
                        repeat
                            //FileVolumes.TESTFIELD(Archived, false);
                            //if FileVolumes.Archived = false then
                            FileVolumes.Archived := True;
                            FileVolumes."Date Archived" := Today;
                            FileVolumes."Archived By" := UserId;
                            FileVolumes."Volume Status" := FileVolumes."Volume Status"::Archived;
                            FileVolumes.MODIFY;
                        until FileVolumes.NEXT = 0;

                    Rec."Archived By" := UserId;
                    Rec."Date Archived" := Today;
                    Message('Files have been succesfully Archived.');
                end;
            }
            group("Approval Workflow")
            {
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = false;

                    trigger OnAction()

                    var
                        CustomApprovals: Codeunit "Custom Approvals Codeunit";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        Rec.TestField("Batch No.");

                        VarVariant := Rec;
                        if CustomApprovals.CheckApprovalsWorkflowEnabled(VarVariant) then
                            CustomApprovals.OnSendDocForApproval(VarVariant);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = OpenApprovalEntriesExist;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = false;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin

                        if Rec.Status <> Rec.Status::Pending then
                            Error(DocMustbePending);

                        VarVariant := Rec;
                        CustomApprovals.OnCancelDocApprovalRequest(VarVariant);
                    end;
                }
                action("Re-Open Document")
                {
                    ApplicationArea = Basic, Suite;
                    //Visible = true;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Image = ReOpen;
                    Visible = false;

                    trigger OnAction()
                    begin
                        if Rec.Status = Rec.Status::Open then
                            Error('Document is Open!');
                        if not Confirm('Are you sure you want to re-open this document?') then exit;
                        Rec.Status := Rec.Status::Open;
                        Rec.Modify;
                        Message('Document Reopened Sucessfully.');
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = false;


                    trigger OnAction()
                    var
                        ApprovalEntries: Page "Approval Entries";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(rec.RecordId);
                    end;
                }

            }
        }
    }
    var
        BatchLines: Record "Batch Lines Table";
        UserSetup: Record "User Setup";
        PageEdit: Boolean;
        VarVariant: Variant;
        OpenApprovalEntriesExist: boolean;
        DocMustbePending: Label 'This application request must be Pending';
        CustomApprovals: Codeunit "Custom Approvals Codeunit";
        VisibleSingleAsset: Boolean;
        VisibleCollectiveAsset: Boolean;
        FileVolumes: REcord "Task Volumes";
}
