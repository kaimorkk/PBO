report 52193431 "Perf Rewards Sanctions Report"
{
    Caption = 'Rewards and Sanctions Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(RewardSanction; "Perf Reward Sanction")
        {
            RequestFilterFields = Type, "HRAC Status", "Proposed Date";

            trigger OnAfterGetRecord()
            var
                ReviewHeader: Record "Perf Review Header";
                EmployeeMgt: Codeunit "Perf Employee Mgt";
            begin
                Buffer.Init();
                EntryNo += 1;
                Buffer."Entry No." := EntryNo;
                EmployeeMgt.FillReportBuffer(Buffer, RewardSanction."Employee No.");
                if ReviewHeader.Get(RewardSanction."Review No.") then begin
                    Buffer."Period Code" := ReviewHeader."Period Code";
                    Buffer."Decimal Value 1" := ReviewHeader."Overall Score";
                end;
                Buffer."Text Value 1" := CopyStr(Format(RewardSanction.Type) + ' - ' + Format(RewardSanction."HRAC Status"), 1, MaxStrLen(Buffer."Text Value 1"));
                Buffer."Text Value 2" := RewardSanction.Description;
                Buffer."Boolean Value 1" := RewardSanction."Letter Generated";
                Buffer."Date Value 1" := RewardSanction."Proposed Date";
                Buffer.Insert();
            end;
        }
    }

    trigger OnPostReport()
    var
        BufferPage: Page "Perf Report Buffer List";
    begin
        // FRD 4: Rewards and sanctions proposed by supervisors and moderated by HRAC.
        BufferPage.LoadBuffer(Buffer);
        BufferPage.RunModal();
    end;

    var
        Buffer: Record "Perf Report Buffer" temporary;
        EntryNo: Integer;
}
