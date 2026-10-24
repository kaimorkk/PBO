report 52193436 "Perf Appraisal Coverage Rprt"
{
    Caption = 'Staff Appraisal Coverage Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = where(Status = const(Active));
            RequestFilterFields = "No.", "Global Dimension 1 Code", "Perf Directorate Code", "Perf Region Code", "Perf Grade";

            trigger OnAfterGetRecord()
            var
                ReviewHeader: Record "Perf Review Header";
                EmployeeMgt: Codeunit "Perf Employee Mgt";
            begin
                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, Employee."No.");
                Buffer."Period Code" := PeriodCode;

                ReviewHeader.SetRange("Employee No.", Employee."No.");
                ReviewHeader.SetRange("Period Code", PeriodCode);
                if ReviewHeader.FindFirst() then begin
                    // Appraised = the supervisor has evaluated the employee.
                    Buffer."Boolean Value 1" := ReviewHeader."Supervisor Review Date" <> 0D;
                    Buffer."Text Value 2" := Format(ReviewHeader.Status);
                    Buffer."Decimal Value 1" := ReviewHeader."Overall Score";
                    Buffer."Date Value 1" := ReviewHeader."Supervisor Review Date";
                end else
                    Buffer."Text Value 2" := NoReviewTxt;

                if Buffer."Boolean Value 1" then
                    Buffer."Text Value 1" := AppraisedTxt
                else
                    Buffer."Text Value 1" := NotAppraisedTxt;
                Buffer.Insert();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PeriodCodeField; PeriodCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Appraisal Period';
                        TableRelation = "Perf Appraisal Period".Code;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if PeriodCode = '' then
            Error(PeriodRequiredErr);
    end;

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Staff appraised/not appraised by designation, department, directorate and region.
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        PeriodCode: Code[20];
        EntryNo: Integer;
        AppraisedTxt: Label 'Appraised';
        NotAppraisedTxt: Label 'Not Appraised';
        NoReviewTxt: Label 'No review created';
        PeriodRequiredErr: Label 'Select the appraisal period.';
}
