 
  
codeunit 50103 "HR Leave Jnl.-Post"
{
    TableNo = "HR Leave Journal Line";

    trigger OnRun()
    var
        EndFix: Integer;
        StartFix: Integer;
        FiscalYearEndPCode: Code[30];
        periodFix: Code[30];
    begin
        // EndFix := DATE2DMY(TODAY, 3);
        // StartFix := EndFix + 1;
        // periodFix := FORMAT(EndFix) + '/' + FORMAT(StartFix);
        // FiscalYearEndPCode := periodFix;
        // if rec."Document No." <> '' then begin
        //     rec."Document No." := FiscalYearEndPCode;
        // end;
        // HRJournalLine.Copy(Rec);
        // Code();
        // Rec.Copy(HRJournalLine);
    end;

    var
        Text000: Label 'Do you want to post the journal lines?';
        Text001: Label 'There is nothing to post.';
        Text002: Label 'The journal lines were successfully posted.';
        Text003: Label 'The journal lines were successfully posted. You are now in the %1 journal.';
        HRJournalLineTemplate: Record "HR Leave Journal Template";
        HRJournalLine: Record "HR Leave Journal Line";
        HRJournalPostBatch: Codeunit "HR Leave Jnl.- Post Batch";
        TempJnlBatchName: Code[10];
        Text004: Label 'Since you are making a Negative Adjustment, "Number of Days" Should be Less Than Zero and not %1';

    procedure "Code"(var LeavJousnals: Record "HR Leave Journal Line")
    begin
        HRJournalLine.Reset();
        EndFix := DATE2DMY(TODAY, 3);
        StartFix := EndFix + 1;
        periodFix := FORMAT(EndFix) + '/' + FORMAT(StartFix);
        FiscalYearEndPCode := periodFix;
        if LeavJousnals."Document No." <> '' then begin
            LeavJousnals."Document No." := FiscalYearEndPCode;
        end;
        HRJournalLine.Copy(LeavJousnals);
        // Message(HRJournalLine."Document No.");



        HRJournalLineTemplate.Get(HRJournalLine."Journal Template Name");
        HRJournalLineTemplate.TestField("Force Posting Report", false);

        /*
          IF NOT CONFIRM(Text000,FALSE) THEN
            EXIT;
        */

        TempJnlBatchName := HRJournalLine."Journal Batch Name";

        HRJournalPostBatch.Code(HRJournalLine);

        if HRJournalLine."Line No." = 0 then
            Message(Text001)
        else
            if TempJnlBatchName = HRJournalLine."Journal Batch Name" then begin
                Message(Text002);
                HRJournalLine.DeleteAll()
            end
            else
                Message(
                  Text003,
              HRJournalLine."Journal Batch Name");
        if not HRJournalLine.Find('=><') or (TempJnlBatchName <> HRJournalLine."Journal Batch Name") then begin
            //HRJournalLine.Reset();
            HRJournalLine.FilterGroup := 2;
            HRJournalLine.SetRange(HRJournalLine."Journal Template Name", HRJournalLine."Journal Template Name");
            HRJournalLine.SetRange(HRJournalLine."Journal Batch Name", HRJournalLine."Journal Batch Name");
            HRJournalLine.FilterGroup := 0;
            HRJournalLine."Line No." := 1;
            HRJournalLine."Document No." := FiscalYearEndPCode;
        end;
        LeavJousnals.Copy(HRJournalLine);

    end;

    var
        EndFix: Integer;
        StartFix: Integer;
        FiscalYearEndPCode: Code[30];
        periodFix: Code[30];
}
