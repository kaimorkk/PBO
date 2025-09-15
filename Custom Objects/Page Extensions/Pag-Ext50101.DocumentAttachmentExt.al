namespace PBO.PBO;

using Microsoft.Foundation.Attachment;

pageextension 50101 """Document Attachment Ext """ extends "Document Attachment Details"
{
    layout
    {
        modify("File Type")
        {
            ApplicationArea = all;
            Visible = false;
        }
        addafter("File Extension")
        {
            field(Description; Description)
            {
                ApplicationArea = all;
            }
            field(Sponsor; Sponsor)
            {
                ApplicationArea = all;
            }
            field("Date Received"; "Date Received")
            {
                ApplicationArea = all;
            }

        }
    }
    trigger OnDeleteRecord(): Boolean
    var
        myInt: Integer;
    begin
        PBOMeetings.Reset();
        PBOMeetings.SetRange("Meeting Code", rec."No.");
        if PBOMeetings.FindFirst() then begin
            if PBOMeetings."Meeting Status" <> PBOMeetings."Meeting Status"::Open then
                Error('You cannot delete Document at this stage');
        end;
        Filestable.Reset();
        Filestable.SetRange("Entry No.", rec."No.");
        if Filestable.FindFirst() then begin
            if Filestable."Task Status" <> Filestable."Task Status"::Open then
                Error('You cannot delete Document at this stage');
        end;

    end;

    var
        PBOMeetings: Record "PBO Meetings";
        DocAttch: Record "Document Attachment";
        Filestable: Record "Files Table";
}
