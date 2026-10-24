report 52193427 "Perf Appraisal Status Report"
{
    Caption = 'Appraisal Status Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        // Driven by Employee so staff who have not started goal setting are also listed.
        dataitem(Employee; Employee)
        {
            DataItemTableView = where(Status = const(Active));
            RequestFilterFields = "No.", "Perf Supervisor No.", "Global Dimension 1 Code", "Perf Directorate Code";

            trigger OnAfterGetRecord()
            var
                GoalHeader: Record "Perf Goal Header";
                ReviewHeader: Record "Perf Review Header";
                EmployeeMgt: Codeunit "Perf Employee Mgt";
                GoalSetStatus: Text;
                ReviewStatus: Text;
            begin
                GoalSetStatus := NotStartedTxt;
                GoalHeader.SetRange("Employee No.", Employee."No.");
                if GoalPeriodCode <> '' then
                    GoalHeader.SetRange("Period Code", GoalPeriodCode);
                if GoalHeader.FindLast() then
                    GoalSetStatus := Format(GoalHeader.Status);

                ReviewStatus := NotStartedTxt;
                ReviewHeader.SetRange("Employee No.", Employee."No.");
                if ReviewPeriodCode <> '' then
                    ReviewHeader.SetRange("Period Code", ReviewPeriodCode);
                if ReviewHeader.FindLast() then
                    ReviewStatus := Format(ReviewHeader.Status);

                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, Employee."No.");
                Buffer."Period Code" := ReviewHeader."Period Code";
                Buffer."Text Value 1" := CopyStr(StrSubstNo(GoalSetTxt, GoalSetStatus), 1, MaxStrLen(Buffer."Text Value 1"));
                Buffer."Text Value 2" := CopyStr(StrSubstNo(ReviewStatusTxt, ReviewStatus), 1, MaxStrLen(Buffer."Text Value 2"));
                Buffer."Boolean Value 1" := ReviewHeader."Self Assessment Date" <> 0D;
                Buffer."Date Value 1" := ReviewHeader."Supervisor Review Date";
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
                    field(GoalPeriodCodeField; GoalPeriodCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Target Setting Period';
                        TableRelation = "Perf Appraisal Period".Code;
                    }
                    field(ReviewPeriodCodeField; ReviewPeriodCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Review Period';
                        TableRelation = "Perf Appraisal Period".Code;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Status of goal setting, self-assessment (Flag), and manager review (Date).
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        GoalPeriodCode: Code[20];
        ReviewPeriodCode: Code[20];
        EntryNo: Integer;
        NotStartedTxt: Label 'Not Started';
        GoalSetTxt: Label 'Goal Setting: %1', Comment = '%1 = status';
        ReviewStatusTxt: Label 'Review: %1', Comment = '%1 = status';
}
