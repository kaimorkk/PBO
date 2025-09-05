 
codeunit 50107 "HR Make Leave Ledg. Entry"
{



    procedure CopyFromJnlLine(var InsCoverageLedgEntry: Record "HR Leave Ledger Entries"; var InsuranceJnlLine: Record "HR Leave Journal Line")
    begin
        begin
            InsCoverageLedgEntry."Posted By" := UserId;
            InsCoverageLedgEntry."Leave Calendar Code" := InsuranceJnlLine."Leave Period";
            InsCoverageLedgEntry."Staff No." := InsuranceJnlLine."Staff No.";
            InsCoverageLedgEntry."Staff Name" := InsuranceJnlLine."Staff Name";
            InsCoverageLedgEntry."Posting Date" := InsuranceJnlLine."Posting Date";
            InsCoverageLedgEntry."Leave Recalled No." := InsuranceJnlLine."Leave Recalled No.";
            InsCoverageLedgEntry."Leave Entry Type" := InsuranceJnlLine."Leave Entry Type";
            InsCoverageLedgEntry."Leave Type" := InsuranceJnlLine."Leave Type";
            InsCoverageLedgEntry."Leave Approval Date" := InsuranceJnlLine."Leave Approval Date";
            InsCoverageLedgEntry."Leave Type" := InsuranceJnlLine."Leave Type";
            InsCoverageLedgEntry.Batched := InsuranceJnlLine.Batched;
            //"Leave Types":=InsuranceJnlLine."Leave Type Option";
            if InsCoverageLedgEntry."Leave Approval Date" = 0D then
                InsCoverageLedgEntry."Leave Approval Date" := InsCoverageLedgEntry."Posting Date";
            InsCoverageLedgEntry."Document No." := InsuranceJnlLine."Document No.";
            InsCoverageLedgEntry."External Document No." := InsuranceJnlLine."External Document No.";
            if InsuranceJnlLine."Leave Entry Type" = InsuranceJnlLine."Leave Entry Type"::Negative then
                InsCoverageLedgEntry."No. of days" := -InsuranceJnlLine."No. of Days"
            else
                InsCoverageLedgEntry."No. of days" := InsuranceJnlLine."No. of Days";
            InsCoverageLedgEntry."Leave Posting Description" := InsuranceJnlLine.Description;
            InsCoverageLedgEntry."Global Dimension 1 Code" := InsuranceJnlLine."Shortcut Dimension 1 Code";
            InsCoverageLedgEntry."Global Dimension 2 Code" := InsuranceJnlLine."Shortcut Dimension 2 Code";
            InsCoverageLedgEntry."Source Code" := InsuranceJnlLine."Source Code";
            InsCoverageLedgEntry."Journal Batch Name" := InsuranceJnlLine."Journal Batch Name";
            InsCoverageLedgEntry."Reason Code" := InsuranceJnlLine."Reason Code";
            InsCoverageLedgEntry.Closed := SetDisposedFA(InsCoverageLedgEntry."Staff No.");
            InsCoverageLedgEntry."No. Series" := InsuranceJnlLine."Posting No. Series";
        end;
    end;


    procedure CopyFromInsuranceCard(var InsCoverageLedgEntry: Record "HR Leave Ledger Entries"; var Insurance: Record "HR Leave Application")
    begin
        /*WITH InsCoverageLedgEntry DO BEGIN
          "FA Class Code" := Insurance."FA Class Code";
          "FA Subclass Code" := Insurance."FA Subclass Code";
          "FA Location Code" := Insurance."FA Location Code";
          "Location Code" := Insurance."Location Code";
        END;*/

    end;


    procedure SetDisposedFA(FANo: Code[20]): Boolean
    var
        FASetup: Record "HR Setup";
    begin
        /*FASetup.GET;
        FASetup.TESTFIELD("Insurance Depr. Book");
        IF FADeprBook.GET(FANo,FASetup."Insurance Depr. Book") THEN
          EXIT(FADeprBook."Disposal Date" > 0D)
        ELSE
          EXIT(FALSE);
         */

    end;


    procedure UpdateLeaveApp(LeaveCode: Code[20]; Status: Option)
    var
        LeaveApplication: Record "HR Leave Application";
    begin
    end;
}
