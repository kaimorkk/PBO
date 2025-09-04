 
page 50120 "Property Details"
{
    PageType = Card;
    SourceTable = "Property Details";
    //SourceTableView = WHERE("Agreement Status" = FILTER(<> Active),
    //"Property Type" = FILTER(<> 'LAND'));
    PromotedActionCategories = 'Navigate, New, Process, Approval, Reports,  Home';

    layout
    {
        area(content)
        {
            group("Property Information")
            {
                Caption = 'Property Information';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("L.R. No."; Rec."L.R. No.")
                {
                    Caption = 'Land Reference No.';
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Property Name';
                }
                field("Building Location"; Rec."Building Location")
                {
                    ApplicationArea = Basic, Suite;
                    //Editable = false;
                }
                // field("Fixed Asset No."; Rec."Fixed Asset No.")
                // {
                //     Caption = 'Land Ref No.';
                //     ApplicationArea = Basic, Suite;
                // }
                field("Landlord No."; Rec."Landlord No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Landlord Name"; Rec."Landlord Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Property Type"; Rec."Property Type")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = "Property Category";

                    trigger OnValidate()
                    begin
                        if Rec."Property Type" = 'BUILDING' then begin
                            "Total Area sq ftVisible" := false;
                        end
                        else
                            if Rec."Property Type" = 'COMMERCIAL' then begin
                                "Total Area sq ftVisible" := true;
                            end;
                        if Rec."Property Type" = 'LAND' then begin
                            Error(PTypeErr);
                        end
                    end;
                }
                field("Property Code"; Rec."Property Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Department Code';
                }
                // field("Department name"; Rec."Department name")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Editable = false;
                // }
                field("Total Area sq ft"; Rec."Total Area sq ft")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                    Visible = "Total Area sq ftVisible";
                }
                field("total Units"; Rec."total Units")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Units';
                    Editable = false;
                    Importance = Promoted;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Agreement Status"; Rec."Agreement Status")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Property Status';
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = False;
                }
            }
            part("Property Lines"; Floor)
            {
                SubPageLink = "No." = FIELD("No.");
            }
            group("Other Details")
            {
                Caption = 'Other Details';
                field("File Ref No."; Rec."File Ref No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commence Date"; Rec."Commence Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contract Commence Date';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        /*
                        //is obsolete in 2015
                        FrmCalendar.SetDate("Commence Date");
                        FrmCalendar.RUNMODAL;
                        D := FrmCalendar.GetDate;
                        CLEAR(FrmCalendar);
                        IF D <> 0D THEN
                         "Commence Date":= D;
                         */

                    end;
                }
                field("Duration Type"; Rec."Duration Type")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Duration Value"; Rec."Duration Value")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contract Expiry Date';
                    Editable = false;
                    Visible = false;
                }
            }
            group("Management Fees")
            {
                Caption = 'Management Fees';
                Visible = false;
                field("Commission Rate"; Rec."Commission Rate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Management Fee Rate';
                }
                field("Commision Flat Amount"; Rec."Commision Flat Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Management Fee Amount';
                }
                field("Letting Fee Rate(%)"; Rec."Letting Fee Rate(%)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Letting Flat Amount"; Rec."Letting Flat Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reletting Fee Rate(%)"; Rec."Reletting Fee Rate(%)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reletting Flat Amount"; Rec."Reletting Flat Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Property)
            {
                Caption = 'Property';
                action(Caretakers)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Caretakers';
                    Image = EditCustomer;
                    // RunObject = Page "Caretaker List";
                    Visible = false;
                }
                separator(Action1102755032)
                {
                }
                action(Charges)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Charges';
                    // RunObject = Page 52186234;
                    Visible = false;
                    // RunPageLink = "Property Code" = FIELD("No.");

                }
                action("Activate Property")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Activate Property';
                    Image = Allocations;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        rec.TestField(Status, rec.Status::Approved);

                        if Confirm('Are you sure you what to Activate property') = true then begin
                            rec."Agreement Status" := rec."Agreement Status"::Active;
                            rec."Time Property Created" := Time;
                            rec."Property Created By" := UserId;
                            rec.Modify;
                        end
                        else begin
                            exit
                        end;
                    end;
                }
                action("Terminate Property")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Terminate Property';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        rec.TestField(Status, rec.Status::Approved);

                        if Confirm('Are you sure you what to Terminate property') = true then begin
                            rec."Agreement Status" := rec."Agreement Status"::Terminated;
                            rec."Time Property Created" := Time;
                            rec."Property Created By" := UserId;
                            rec.Modify;
                        end
                        else begin
                            exit
                        end;
                    end;
                }
                action("Archive Property")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Archive Property';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        rec.TestField(Status, rec.Status::Approved);

                        if Confirm('Are you sure you what to Archive property') = true then begin
                            rec."Agreement Status" := rec."Agreement Status"::Archived;
                            rec."Time Property Created" := Time;
                            rec."Property Created By" := UserId;
                            rec.Modify;
                        end
                        else begin
                            exit
                        end;
                    end;
                }
            }
            group(Action2)
            {
                action(Approvals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category4;


                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(rec.RecordId);
                    end;
                }
                action("Send A&pproval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;


                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        CustomApprovals: Codeunit "Custom Approvals Codeunit";
                        Floorlines: Record Floor;
                    begin

                        // if rec."Total Area sq ft" <> Floorlines."Floor Area sq ft" then
                        // Error('Area Sq must be equal.');
                        if rec.Status = rec.Status::Approved then begin
                            Error('Request Already Approved.');
                        end
                        else
                            if rec.Status = rec.Status::"Pending Approval" then begin
                                Error('Property Approval Request is Pending.');
                            end
                            else
                                //Rec.TestField("Building Location");

                                VarVariant := Rec;
                        if CustomApprovals.CheckApprovalsWorkflowEnabled(VarVariant) then
                            CustomApprovals.OnSendDocForApproval(VarVariant);
                    end;
                }
                action("Cancel Approval Re&quest")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        CustomApprovals: Codeunit "Custom Approvals Codeunit";
                    begin
                        VarVariant := Rec;
                        CustomApprovals.OnCancelDocApprovalRequest(VarVariant);
                    end;
                }
                action("Reopen Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reopen Approval Request';
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        If Rec.Status = Rec.Status::Approved then begin
                            Rec.Status := Rec.Status::Open;
                        end;

                    end;
                }
            }
        }
    }

    trigger OnInit()
    begin
        "Total Area sq ftVisible" := true;
    end;

    var
        // FrmCalendar: Page "Units Meter Rating";
        D: Date;
        "Total Area sq ftVisible": Boolean;
        PTypeErr: Label 'LAND Cannot be a Property Type for this Building';
        VarVariant: Variant;
}

