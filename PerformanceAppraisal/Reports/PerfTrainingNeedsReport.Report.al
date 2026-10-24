report 52193434 "Perf Training Needs Report"
{
    Caption = 'Training Needs Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(MitigatingFactor; "Perf Mitigating Factor")
        {
            DataItemTableView = sorting("Entry No.") where("Factor Type" = const(Training));
            RequestFilterFields = "Employee No.";

            trigger OnAfterGetRecord()
            begin
                AddLine(MitigatingFactor."Employee No.", MitigatingFactor."Review No.", MitigatingFactor.Description, MitigatingFactor."Corrective Action", 0, MitigatingFactor."Recorded Date");
            end;
        }
        dataitem(ReviewLineNeed; "Perf Review Line")
        {
            DataItemTableView = sorting("Review No.", "Line No.") where("Training Need" = filter(<>''));

            trigger OnAfterGetRecord()
            var
                ReviewHeader: Record "Perf Review Header";
            begin
                if not ReviewHeader.Get(ReviewLineNeed."Review No.") then
                    exit;
                AddLine(ReviewHeader."Employee No.", ReviewHeader."No.", ReviewLineNeed."Training Need", ReviewLineNeed."Key Result Area", ReviewLineNeed."Supervisor Rating", ReviewHeader."Supervisor Review Date");
            end;
        }
        dataitem(ReviewLineGap; "Perf Review Line")
        {
            DataItemTableView = sorting("Review No.", "Line No.") where("Supervisor Rating" = filter(>0 & <=2), "Training Need" = filter(''));

            trigger OnAfterGetRecord()
            var
                ReviewHeader: Record "Perf Review Header";
            begin
                if not ReviewHeader.Get(ReviewLineGap."Review No.") then
                    exit;
                AddLine(ReviewHeader."Employee No.", ReviewHeader."No.", StrSubstNo(TrainingGapTxt, ReviewLineGap."Key Result Area"), '', ReviewLineGap."Supervisor Rating", ReviewHeader."Supervisor Review Date");
            end;
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 3.vii / 4: Training requirements captured during appraisals (training needs
        // recorded on review lines, mitigating factors of type Training, and low-rated KRAs).
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    local procedure AddLine(EmployeeNo: Code[20]; ReviewNo: Code[20]; Need: Text; Detail: Text; Rating: Decimal; EntryDate: Date)
    var
        ReviewHeader: Record "Perf Review Header";
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        Buffer.Init();
        EntryNo += 1;
        Buffer."Entry No." := EntryNo;
        EmployeeMgt.FillReportBuffer(Buffer, EmployeeNo);
        if ReviewHeader.Get(ReviewNo) then
            Buffer."Period Code" := ReviewHeader."Period Code";
        Buffer."Text Value 1" := CopyStr(Need, 1, MaxStrLen(Buffer."Text Value 1"));
        Buffer."Text Value 2" := CopyStr(Detail, 1, MaxStrLen(Buffer."Text Value 2"));
        Buffer."Decimal Value 1" := Rating;
        Buffer."Date Value 1" := EntryDate;
        Buffer.Insert();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        EntryNo: Integer;
        TrainingGapTxt: Label 'Training need identified in KRA: %1', Comment = '%1 = Key Result Area';
}
