report 52193428 "Perf Competency Analysis Rprt"
{
    Caption = 'Competency Analysis Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ReviewLine; "Perf Review Line")
        {
            RequestFilterFields = "Review No.";

            trigger OnAfterGetRecord()
            var
                ReviewHeader: Record "Perf Review Header";
                EmployeeMgt: Codeunit "Perf Employee Mgt";
                Category: Text[50];
            begin
                if not ReviewHeader.Get(ReviewLine."Review No.") then
                    exit;
                if ReviewLine."Supervisor Rating" = 0 then
                    exit; // not yet evaluated

                // Simple strength/gap classification on the 1-5 rating scale.
                if ReviewLine."Supervisor Rating" >= 4 then
                    Category := 'Strength'
                else
                    if ReviewLine."Supervisor Rating" <= 2 then
                        Category := 'Gap'
                    else
                        Category := 'Adequate';

                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, ReviewHeader."Employee No.");
                Buffer."Period Code" := ReviewHeader."Period Code";
                Buffer."Text Value 1" := ReviewLine."Key Result Area";
                Buffer."Text Value 2" := Category;
                Buffer."Decimal Value 1" := ReviewLine."Supervisor Rating";
                Buffer."Decimal Value 2" := ReviewLine."Achievement %";
                Buffer.Insert();
            end;
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Competence strengths and gaps identified in appraisals.
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        EntryNo: Integer;
}
