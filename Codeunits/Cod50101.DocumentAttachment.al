codeunit 50101 DocumentAttachment
{

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        PBOMeetings: Record "PBO Meetings";
        FilesTable: Record "Files Table";

    begin
        case DocumentAttachment."Table ID" of
            DATABASE::"Files Table":
                begin
                    RecRef.Open(DATABASE::"Files Table");
                    if FilesTable.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(FilesTable);
                end;
            DATABASE::"PBO Meetings":
                begin
                    RecRef.Open(DATABASE::"PBO Meetings");
                    if PBOMeetings.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(PBOMeetings);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        PBOMeetings: Record "PBO Meetings";
        FilesTable: Record "Files Table";



    begin
        case RecRef.Number of
            DATABASE::"Files Table":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
            DATABASE::"PBO Meetings":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];




    begin
        case RecRef.Number of
            DATABASE::"Files Table":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
            DATABASE::"PBO Meetings":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;
}

