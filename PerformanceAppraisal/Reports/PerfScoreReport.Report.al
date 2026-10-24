report 52193432 "Perf Score Report"
{
    Caption = 'Performance Score Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ReviewHeader; "Perf Review Header")
        {
            RequestFilterFields = "Period Code", "Period Type", Status;

            trigger OnAfterGetRecord()
            var
                EmployeeMgt: Codeunit "Perf Employee Mgt";
            begin
                if ReviewHeader."Supervisor Review Date" = 0D then
                    exit; // no score yet

                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, ReviewHeader."Employee No.");
                Buffer."Period Code" := ReviewHeader."Period Code";
                Buffer."Decimal Value 1" := ReviewHeader."Overall Score";
                Buffer."Text Value 1" := ReviewHeader."Rating Category";
                Buffer.Insert();
            end;
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Scores per grade, department, or region (group/filter on those columns).
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        EntryNo: Integer;
}
