report 52193429 "Perf Employee Performance Rprt"
{
    Caption = 'Employee Performance Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Employee; Employee)
        {
            RequestFilterFields = "No.", "Global Dimension 1 Code", "Perf Directorate Code", "Perf Region Code", "Perf Grade";

            trigger OnAfterGetRecord()
            var
                ReviewHeader: Record "Perf Review Header";
                EmployeeMgt: Codeunit "Perf Employee Mgt";
                AvgScore: Decimal;
                Count: Integer;
            begin
                ReviewHeader.SetRange("Employee No.", Employee."No.");
                ReviewHeader.SetFilter(Status, '%1', ReviewHeader.Status::Closed);
                if ReviewHeader.FindSet() then
                    repeat
                        AvgScore += ReviewHeader."Overall Score";
                        Count += 1;
                    until ReviewHeader.Next() = 0;

                if Count = 0 then
                    exit;

                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, Employee."No.");
                Buffer."Decimal Value 1" := Round(AvgScore / Count, 0.01);
                Buffer."Decimal Value 2" := Count;
                Buffer.Insert();
            end;
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Consolidated employee performance results across closed review cycles.
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        EntryNo: Integer;
}
