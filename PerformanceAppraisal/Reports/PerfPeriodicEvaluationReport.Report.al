report 52193430 "Perf Periodic Evaluation Rprt"
{
    Caption = 'Periodic Evaluation Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ReviewHeader; "Perf Review Header")
        {
            RequestFilterFields = "Period Type", "Period Code";

            trigger OnAfterGetRecord()
            var
                EmployeeMgt: Codeunit "Perf Employee Mgt";
            begin
                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, ReviewHeader."Employee No.");
                Buffer."Period Code" := ReviewHeader."Period Code";
                Buffer."Text Value 1" := Format(ReviewHeader."Period Type");
                Buffer."Text Value 2" := Format(ReviewHeader.Status);
                Buffer."Decimal Value 1" := ReviewHeader."Overall Score";
                Buffer."Decimal Value 2" := ReviewHeader."Self Assessment Score";
                Buffer."Date Value 1" := ReviewHeader."Review End Date";
                Buffer.Insert();
            end;
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Quarterly, mid-year, and end-of-year performance evaluations.
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        EntryNo: Integer;
}
