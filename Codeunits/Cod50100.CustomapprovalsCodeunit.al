 

Codeunit 50100 "Custom Approvals Codeunit"
{

    trigger OnRun()
    begin
        AddWorkflowEventsToLibrary
    end;

    var
        //changed
        WorkflowManagement: Codeunit "Workflow Management";
        UnsupportedRecordTypeErr: label 'Record type %1 is not supported by this workflow response.', Comment = 'Record type Customer is not supported by this workflow response.';
        NoWorkflowEnabledErr: label 'This record is not supported by related approval workflow.';
 
        //Property Details
        RunWorkflowOnsendPropertyDetailsForApprovalCode: label 'RUNWORKFLOWONSENDPropertyDetailsRFORAPPROVAL';
        RunWorkflowOnCancelPropertyDetailsForApprovalCode: label 'RUNWORKFLOWONCANCELPropertyDetailsFORAPPROVAL';
        OnCancelPropertyDetailsApprovalRequestTxt: label 'An Approval of Property Details  is cancelled';
        OnSendPropertyDetailsApprovalRequestTxt: label ' An Approval of Property Details is requested';

        //Asset Allocation
  


    procedure CheckApprovalsWorkflowEnabled(var Variant: Variant): Boolean
    var
        RecRef: RecordRef;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        HREmplQualification: Record "Property Details";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Property Details":
                exit(CheckApprovalsWorkflowEnabledCode(variant, RunWorkflowOnsendPropertyDetailsForApprovalCode));
            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end;
    end;


    procedure CheckApprovalsWorkflowEnabledCode(var Variant: Variant; CheckApprovalsWorkflowTxt: Text): Boolean
    var
        RecRef: RecordRef;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        begin
            if not WorkflowManagement.CanExecuteWorkflow(Variant, CheckApprovalsWorkflowTxt) then
                Error(NoWorkflowEnabledErr);
            exit(true);
        end;
    end;

    [IntegrationEvent(false, false)]

    procedure OnSendDocForApproval(var Variant: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]

    procedure OnCancelDocApprovalRequest(var Variant: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkFlowEventHandling: Codeunit "Workflow Event Handling";
    begin
        //Holding
        WorkFlowEventHandling.AddEventToLibrary(RunWorkflowOnsendPropertyDetailsForApprovalCode, Database::"Property Details", OnSendPropertyDetailsApprovalRequestTxt, 0, false);
        WorkFlowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPropertyDetailsForApprovalCode, Database::"Property Details", OnCancelPropertyDetailsApprovalRequestTxt, 0, false);
    end;

    local procedure RunWorkflowOnSendApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approvals Codeunit", 'OnSendDocForApproval', '', false, false)]

    procedure RunWorkflowOnSendApprovalRequest(var Variant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Property Details":
                WorkflowManagement.HandleEvent(RunWorkflowOnsendPropertyDetailsForApprovalCode, Variant);
            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approvals Codeunit", 'OnCancelDocApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelApprovalRequest(var Variant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Property Details":
                WorkflowManagement.HandleEvent(RunWorkflowOnCancelPropertyDetailsForApprovalCode, Variant);
            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end;
    end;

    //for approvals mgnt


    //Handle responses kkaimor

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpendocument', '', false, false)]
    local procedure OnOpendocument(RecRef: RecordRef; var Handled: Boolean)

    var
        PropertyDetails: Record "Property Details";
       
        Respo: Record "Responsibility Center";

    begin
        case RecRef.number of
            Database::"Property Details":
                begin
                    RecRef.SetTable(PropertyDetails);
                    PropertyDetails.Validate(PropertyDetails.Status, PropertyDetails.Status::Open);
                    PropertyDetails.Modify;
                    Handled := true;
                end;
            //added
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'onSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
 
        PropertyDetails: Record "Property Details";

    begin
        case RecRef.number of
            Database::"Property Details":
                begin
                    RecRef.SetTable(PropertyDetails);
                    PropertyDetails.Validate(PropertyDetails.Status, PropertyDetails.Status::"Pending Approval");
                    PropertyDetails.Modify(true);
                    Variant := PropertyDetails;
                    IsHandled := true;
                end;
  
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; workflowstepInstance: Record "Workflow Step Instance")
    var
       PropertyDetails: Record "Property Details";
  
    begin
        case RecRef.number of
            Database::"Property Details":
                begin
                    RecRef.SetTable(PropertyDetails);
                    ApprovalEntryArgument."Document No." := PropertyDetails."No.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: boolean)
    var
     
  PropertyDetails: Record "Property Details";
 

    begin
        case RecRef.Number of
            Database::"Property Details":
                begin
                    RecRef.SetTable(PropertyDetails);
                    PropertyDetails.Validate(PropertyDetails.Status, PropertyDetails.Status::Approved);
                    PropertyDetails.Status := PropertyDetails.Status::Approved;
                    PropertyDetails.Modify;
                    Handled := true;
                end;

        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]

    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
PropertyDetails: Record "Property Details";

    begin
        case ApprovalEntry."Table ID" of
            database::"Property Details":
                begin
                    if PropertyDetails.Get(ApprovalEntry."Document No.") then begin
                        PropertyDetails.validate(PropertyDetails.Status, PropertyDetails.Status::Rejected);
                        PropertyDetails.Status := PropertyDetails.Status::Rejected;
                        PropertyDetails.modify(true);
                    end;
                end;

        end;
    end;
    //approvals response


    procedure ReOpen(var Variant: Variant)
    var

        RecRef: RecordRef;
PropertyDetails: Record "Property Details";
     

    begin

        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Property Details":
                begin
                    RecRef.SetTable(PropertyDetails);
                    PropertyDetails.Validate(PropertyDetails.Status, PropertyDetails.Status::Open);
                    PropertyDetails.Modify;
                    Variant := PropertyDetails;
                end;

            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end

    end;

    procedure SetStatusToPending(var Variant: Variant)
    var
        RecRef: RecordRef;
PropertyDetails: Record "Property Details";

    begin

        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Property Details":
                begin
                    RecRef.SetTable(PropertyDetails);
                    PropertyDetails.Validate(PropertyDetails.Status, PropertyDetails.Status::"Pending Approval");
                    PropertyDetails.Modify;
                    Variant := PropertyDetails;
                end;
            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end
    end;

     
}
