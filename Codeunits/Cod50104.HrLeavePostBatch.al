 
codeunit 50104 "HR Leave Jnl.- Post Batch"
{
    // Permissions = tabledata "Ampath Data Source Forms" = imd;
    TableNo = "HR Leave Journal Line";

    trigger OnRun()
    begin
        // InsuranceJnlLine.Copy(Rec);
        // Code();
        // Rec := InsuranceJnlLine;
    end;

    var
        Text000: Label 'cannot exceed %1 characters';
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
        Text004: Label 'A maximum of %1 posting number series can be used in each journal.';
        InsuranceJnlLine: Record "HR Leave Journal Line";
        InsuranceJnlTempl: Record "HR Leave Journal Template";
        InsuranceJnlBatch: Record "HR Leave Journal Batch";
        InsuranceReg: Record "HR Leave Register";
        InsCoverageLedgEntry: Record "HR Leave Ledger Entries";
        InsuranceJnlLine2: Record "HR Leave Journal Line";
        InsuranceJnlLine3: Record "HR Leave Journal Line";
        NoSeries: Record "No. Series" temporary;
        FAJnlSetup: Record "HR Setup";
        InsuranceJnlPostLine: Codeunit "HR Leave Jnl.- Post Line";
        InsuranceJnlCheckLine: Codeunit "HR Leave Jnl.- Check Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Window: Dialog;
        LineCount: Integer;
        StartLineNo: Integer;
        NoOfRecords: Integer;
        InsuranceRegNo: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;


    procedure "Code"(var JournalsRec: Record "HR Leave Journal Line")
    var
        JnlLineDim: Record "Journal Line Dimension";
        TempJnlLineDim: Record "Journal Line Dimension" temporary;
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        begin
            if JournalsRec."Document No." = '' then
                JournalsRec."Document No." := '2024/2025';
            InsuranceJnlLine.Copy(JournalsRec);
            InsuranceJnlLine.SetRange(InsuranceJnlLine."Journal Template Name", InsuranceJnlLine."Journal Template Name");
            InsuranceJnlLine.SetRange(InsuranceJnlLine."Journal Batch Name", InsuranceJnlLine."Journal Batch Name");
            if InsuranceJnlLine.RecordLevelLocking then
                InsuranceJnlLine.LockTable();

            InsuranceJnlTempl.Get(InsuranceJnlLine."Journal Template Name");
            InsuranceJnlBatch.Get(InsuranceJnlLine."Journal Template Name", InsuranceJnlLine."Journal Batch Name");
            if StrLen(IncStr(InsuranceJnlBatch.Name)) > MaxStrLen(InsuranceJnlBatch.Name) then
                InsuranceJnlBatch.FieldError(
                  Name,
                  StrSubstNo(
                    Text000,
                    MaxStrLen(InsuranceJnlBatch.Name)));

            if not InsuranceJnlLine.Find('=><') then begin
                Commit();
                InsuranceJnlLine."Line No." := 0;
                exit;
            end;

            Window.Open(
              Text001 +
              Text002 +
              Text003);
            Window.Update(1, InsuranceJnlLine."Journal Batch Name");

            // Check lines
            LineCount := 0;
            StartLineNo := InsuranceJnlLine."Line No.";
            repeat
                LineCount := LineCount + 1;
                Window.Update(2, LineCount);
                JnlLineDim.SetRange("Table ID", Database::"Insurance Journal Line");
                JnlLineDim.SetRange("Journal Template Name", InsuranceJnlLine."Journal Template Name");
                JnlLineDim.SetRange("Journal Batch Name", InsuranceJnlLine."Journal Batch Name");
                JnlLineDim.SetRange("Journal Line No.", InsuranceJnlLine."Line No.");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                TempJnlLineDim.DeleteAll();
                // DimMgt.CopyJnlLineDimToJnlLineDim(JnlLineDim,TempJnlLineDim);
                InsuranceJnlCheckLine.RunCheck(InsuranceJnlLine, TempJnlLineDim);
                if InsuranceJnlLine.Next() = 0 then
                    InsuranceJnlLine.Find('-');
            until InsuranceJnlLine."Line No." = StartLineNo;
            NoOfRecords := LineCount;

            //LedgEntryDim.LOCKTABLE;
            InsCoverageLedgEntry.LockTable();
            if InsuranceJnlLine.RecordLevelLocking then
                if InsCoverageLedgEntry.Find('+') then;
            InsuranceReg.LockTable();
            if InsuranceReg.Find('+') then
                InsuranceRegNo := InsuranceReg."No." + 1
            else
                InsuranceRegNo := 1;

            // Post lines
            LineCount := 0;
            LastDocNo := '';
            LastDocNo2 := '';
            LastPostedDocNo := '';
            InsuranceJnlLine.Find('-');
            repeat
                LineCount := LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                if not (InsuranceJnlLine."Leave Period" = '') and
                   (InsuranceJnlBatch."No. Series" <> '') and
                   (InsuranceJnlLine."Document No." <> LastDocNo2)
                then
                    InsuranceJnlLine.TestField(InsuranceJnlLine."Document No.", NoSeriesMgt.GetNextNo(InsuranceJnlBatch."No. Series", InsuranceJnlLine."Posting Date", false));
                LastDocNo2 := InsuranceJnlLine."Document No.";
                if InsuranceJnlLine."Posting No. Series" = '' then
                    InsuranceJnlLine."Posting No. Series" := InsuranceJnlBatch."No. Series"
                else
                    if not (InsuranceJnlLine."Leave Period" = '') then
                        if InsuranceJnlLine."Document No." = LastDocNo then
                            InsuranceJnlLine."Document No." := LastPostedDocNo
                        else begin
                            if not NoSeries.Get(InsuranceJnlLine."Posting No. Series") then begin
                                NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                                if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                                    Error(
                                      Text004,
                                      ArrayLen(NoSeriesMgt2));
                                NoSeries.Code := InsuranceJnlLine."Posting No. Series";
                                NoSeries.Description := Format(NoOfPostingNoSeries);
                                NoSeries.Insert();
                            end;
                            LastDocNo := InsuranceJnlLine."Document No.";
                            Evaluate(PostingNoSeriesNo, NoSeries.Description);
                            InsuranceJnlLine."Document No." := NoSeriesMgt2[PostingNoSeriesNo].GetNextNo(InsuranceJnlLine."Posting No. Series", InsuranceJnlLine."Posting Date", false);
                            LastPostedDocNo := InsuranceJnlLine."Document No.";
                        end;
                JnlLineDim.SetRange("Table ID", Database::"Insurance Journal Line");
                JnlLineDim.SetRange("Journal Template Name", InsuranceJnlLine."Journal Template Name");
                JnlLineDim.SetRange("Journal Batch Name", InsuranceJnlLine."Journal Batch Name");
                JnlLineDim.SetRange("Journal Line No.", InsuranceJnlLine."Line No.");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                TempJnlLineDim.DeleteAll();
                // DimMgt.CopyJnlLineDimToJnlLineDim(JnlLineDim,TempJnlLineDim);
                InsuranceJnlPostLine.RunWithOutCheck(InsuranceJnlLine, TempJnlLineDim);
            until InsuranceJnlLine.Next() = 0;

            if InsuranceReg.Find('+') then;
            if InsuranceReg."No." <> InsuranceRegNo then
                InsuranceRegNo := 0;

            InsuranceJnlLine.Init();
            InsuranceJnlLine."Line No." := InsuranceRegNo;

            // Update/delete lines
            if InsuranceRegNo <> 0 then begin
                if not InsuranceJnlLine.RecordLevelLocking then begin
                    JnlLineDim.LockTable(true, true);
                    InsuranceJnlLine.LockTable(true, true);
                end;
                InsuranceJnlLine2.CopyFilters(InsuranceJnlLine);
                InsuranceJnlLine2.SetFilter("Leave Period", '<>%1', '');
                if InsuranceJnlLine2.Find('+') then; // Remember the last line
                JnlLineDim.SetRange("Table ID", Database::"Insurance Journal Line");
                JnlLineDim.CopyFilter("Journal Template Name", InsuranceJnlLine."Journal Template Name");
                JnlLineDim.CopyFilter("Journal Batch Name", InsuranceJnlLine."Journal Batch Name");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                InsuranceJnlLine3.Copy(InsuranceJnlLine);
                if InsuranceJnlLine3.Find('-') then
                    repeat
                        JnlLineDim.SetRange("Journal Line No.", InsuranceJnlLine3."Line No.");
                        JnlLineDim.DeleteAll();
                        InsuranceJnlLine3.Delete();
                    until InsuranceJnlLine3.Next() = 0;
                InsuranceJnlLine3.Reset();
                InsuranceJnlLine3.SetRange("Journal Template Name", InsuranceJnlLine."Journal Template Name");
                InsuranceJnlLine3.SetRange("Journal Batch Name", InsuranceJnlLine."Journal Batch Name");
                if not InsuranceJnlLine3.Find('+') then
                    if IncStr(InsuranceJnlLine."Journal Batch Name") <> '' then begin
                        InsuranceJnlBatch.Get(InsuranceJnlLine."Journal Template Name", InsuranceJnlLine."Journal Batch Name");
                        InsuranceJnlBatch.Delete();
                        //FAJnlSetup.IncInsuranceJnlBatchName(InsuranceJnlBatch);
                        InsuranceJnlBatch.Name := IncStr(InsuranceJnlLine."Journal Batch Name");
                        if InsuranceJnlBatch.Insert() then;
                        InsuranceJnlLine."Journal Batch Name" := InsuranceJnlBatch.Name;
                    end;

                InsuranceJnlLine3.SetRange("Journal Batch Name", InsuranceJnlLine."Journal Batch Name");
                if (InsuranceJnlBatch."No. Series" = '') and not InsuranceJnlLine3.Find('+') then begin
                    InsuranceJnlLine3.Init();
                    InsuranceJnlLine3."Journal Template Name" := InsuranceJnlLine."Journal Template Name";
                    InsuranceJnlLine3."Journal Batch Name" := InsuranceJnlLine."Journal Batch Name";
                    InsuranceJnlLine3."Line No." := 10000;
                    InsuranceJnlLine3.Insert();
                    InsuranceJnlLine3.SetUpNewLine(InsuranceJnlLine2);
                    InsuranceJnlLine3.Modify();
                end;
            end;
            if InsuranceJnlBatch."No. Series" <> '' then
                NoSeriesMgt.SaveNoSeries();
            if NoSeries.Find('-') then
                repeat
                    Evaluate(PostingNoSeriesNo, NoSeries.Description);
                    NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries();
                until NoSeries.Next() = 0;

            Commit();
            Clear(InsuranceJnlCheckLine);
            Clear(InsuranceJnlPostLine);
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        Commit();
        JournalsRec := InsuranceJnlLine;
    end;
}
