namespace PBO.PBO;
using System.Utilities;
using System.IO;
using Microsoft.Foundation.Attachment;
using System.Text;

codeunit 50109 "Hr Portal"
{
    procedure ExportDoc(ShowFileDialog: Boolean; TAbleiD: Integer; RequistNo: Code[50]): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
        DocumentRec: Record "Document Attachment";
        TestDay: Integer;
        TestMOnth: Integer;
        TestYear: Integer;
        formatedtCode: Text;
        formartedYr: Text;
        DTest: Text;
        DmonthTest: Text;
        BaseImage: Text;
        InStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        RequistDate: Date;
        HrRequisitions: Record "HR Employee Requisitions";
    begin
        HrRequisitions.Reset();
        HrRequisitions.SetRange(HrRequisitions."Requisition No.", RequistNo);
        if HrRequisitions.FindFirst() then begin
            RequistDate := HrRequisitions."Requisition Date";
            if RequistDate <> 0D then begin
                TestDay := Date2DMY(RequistDate, 1);
                if TestDay < 10 then
                    DTest := '0' + Format(TestDay)
                else
                    DTest := Format(TestDay);
                TestMOnth := Date2DMY(RequistDate, 2);
                if TestMOnth < 10 then
                    DmonthTest := '0' + Format(TestMOnth)
                else
                    DmonthTest := Format(TestMOnth);
                TestYear := Date2DMY(RequistDate, 3);
                formartedYr := CopyStr(Format(TestYear), 3, 2);
                formatedtCode := FORMAT(DTest) + '/' + FORMAT(DmonthTest) + '/' + FORMAT(formartedYr);
                // Message(formatedtCode);
            end;
            DocumentRec.Reset();
            DocumentRec.SetRange("Table ID", TAbleiD);
            DocumentRec.SetRange("No.", formatedtCode);
            if DocumentRec.Find('-') then begin
                if DocumentRec.ID = 0 then
                    exit;
                // Ensure document has value in DB
                if not DocumentRec."Document Reference ID".HasValue() then
                    exit;
                //DocumentRec.OnBeforeExportAttachment(DocumentRec);
                FullFileName := DocumentRec."File Name" + '.' + DocumentRec."File Extension";
                TempBlob.CreateOutStream(DocumentStream);
                DocumentRec."Document Reference ID".ExportStream(DocumentStream);
                FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog);
                TempBlob.CreateInstream(InStr, TEXTENCODING::UTF8);
                BaseImage := Base64Convert.ToBase64(InStr);
                exit(BaseImage);
            end;
        end;
    end;

}
