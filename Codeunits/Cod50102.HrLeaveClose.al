 
codeunit 50102 "HR Leave Year - Close"
{
    TableNo = "HR Leave Periods";

    trigger OnRun()
    begin
        AccountingPeriod.Copy(Rec);
        Code();
        Clearpendingleaves();
        Rec := AccountingPeriod;
        Message('Leave period Closed Successfully');
    end;

    var
        Text001: Label 'You must create a new fiscal year before you can close the old year.';
        Text002: Label 'This function closes the fiscal year from %1 to %2. ';
        Text003: Label 'Once the fiscal year is closed it cannot be opened again, and the periods in the fiscal year cannot be changed.\\';
        Text004: Label 'Do you want to close the fiscal year?';
        AccountingPeriod: Record "HR Leave Periods";
        AccountingPeriod2: Record "HR Leave Periods";
        AccountingPeriod3: Record "HR Leave Periods";
        FiscalYearStartDate: Date;
        FiscalYearEndDate: Date;
        dAlloc: Decimal;
        dEarnd: Decimal;
        dTaken: Decimal;
        dLeft: Decimal;
        cReimbsd: Decimal;
        cPerDay: Decimal;
        cbf: Decimal;
        HRLeaveLedgerEntries: Record "HR Leave Ledger Entries";
        HREmp: Record Employee;
        HRSetup: Record "HR Setup";
        LeaveType: Record "HR Leave Types";
        LeaveJournalLine: Record "HR Leave Ledger Entries";
        FiscalYearEndPCode: Code[20];
        CarryForward: Decimal;

    procedure "Code"()
    var
        EndFix: Integer;
        StartFix: Integer;
        PeriodFix: Code[30];
    begin

        begin
            EndFix := 0;
            StartFix := 0;
            PeriodFix := '';
            EndFix := DATE2DMY(TODAY, 3);
            StartFix := EndFix + 1;
            periodFix := FORMAT(EndFix) + '/' + FORMAT(StartFix);
            FiscalYearEndPCode := periodFix;
            HREmp.Reset();
            HREmp.SetRange(Status, HREmp.Status::Active);
            // HREmp.SetRange(HREmp."No.", 'NLC20150215');
            if HREmp.FindFirst() then begin
                repeat
                    HREmp."Leave Calendar" := PeriodFix;
                    HREmp.Modify();
                until HREmp.Next() = 0;
            end;
            AccountingPeriod2.Reset();
            AccountingPeriod2.SetRange(Closed, false);
            AccountingPeriod2.Find('-');
            FiscalYearStartDate := AccountingPeriod2."Starting Date";
            AccountingPeriod := AccountingPeriod2;
            AccountingPeriod.TestField(AccountingPeriod."New Fiscal Year", true);
            AccountingPeriod2.SetRange("New Fiscal Year", true);
            if AccountingPeriod2.Find('>') then begin
                //error(format(AccountingPeriod2."Starting Date"));
                //Set the fiscal year end date to be the 1st Day of the Next Month
                FiscalYearEndDate := CalcDate('<-1D>', AccountingPeriod2."Starting Date");
                //FiscalYearEndPCode:=AccountingPeriod2."Period Code";
                EndFix := DATE2DMY(TODAY, 3);
                StartFix := EndFix + 1;
                periodFix := FORMAT(EndFix) + '/' + FORMAT(StartFix);
                FiscalYearEndPCode := periodFix;
                //error(format(FiscalYearEndDate));
                //MESSAGE(FORMAT(FiscalYearEndPCode));
                AccountingPeriod3 := AccountingPeriod2;
                AccountingPeriod2.SetRange("New Fiscal Year");
                AccountingPeriod2.Find('<');
            end else
                Error(Text001);
            if not
               Confirm(
                 Text002 +
                 Text003 +
                 Text004, false,
                 FiscalYearStartDate, FiscalYearEndDate)
            then
                exit;
            AccountingPeriod.Reset();
            AccountingPeriod.SetRange(AccountingPeriod."Starting Date", FiscalYearStartDate, AccountingPeriod2."Starting Date");
            AccountingPeriod.ModifyAll(AccountingPeriod.Closed, true);
            AccountingPeriod.SetRange(AccountingPeriod."Starting Date", FiscalYearStartDate, AccountingPeriod3."Starting Date");
            AccountingPeriod.ModifyAll(AccountingPeriod."Date Locked", true);
            //MESSAGE(FORMAT(FiscalYearEndPCode));
            fnCreateLeaveEntitlement(AccountingPeriod);
            fnCreateCarryForwardLeaveBal(AccountingPeriod);
        end;
    end;


    procedure fnCreateLeaveEntitlement(var PayrollPeriod: Record "HR Leave Periods")
    var
        AccPeriod: Record "HR Leave Periods";
        NextDate: Date;
        EndOfYear: Boolean;
        Empleave: Record "HR Leave Ledger Entries";
        LeaveType: Record "HR Leave Types";
        MaturityDate: Date;
        NextMaturityDate: Date;
        Emp: Record Employee;
        StartFix: Integer;
        periodFix: Code[30];
        EndFix: Integer;
        CarryForwardDays: Decimal;
        EmpleaveCpy: Record "HR Leave Ledger Entries";
        JounarnalPost: Codeunit "HR Leave Jnl.-Post";
    begin

        HRSetup.Get();
        LeaveType.Reset();
        LeaveType.SetRange(LeaveType.Code, 'ANNUAL');
        if LeaveType.Find('-') then begin
            HREmp.Reset();
            HREmp.SetRange(HREmp.Status, HREmp.Status::Active);
            // HREmp.SetRange(HREmp."No.", 'NLC20150178');
            if HREmp.Find('-') then begin
                repeat
                    LeaveJournalLine.Reset();
                    if LeaveJournalLine.FindLast() then begin
                        LeaveJournalLine.Init();
                        LeaveJournalLine."Journal Batch Name" := 'POSITIVE';
                        LeaveJournalLine."Entry No." := LeaveJournalLine."Entry No." + 1;
                        LeaveJournalLine."Leave Calendar Code" := FiscalYearEndPCode;
                        LeaveJournalLine."Leave Approval Date" := Today;
                        LeaveJournalLine."Staff No." := HREmp."No.";
                        LeaveJournalLine."Staff Name" := HREmp."Search Name";
                        LeaveJournalLine."Posting Date" := Today;
                        LeaveJournalLine."Posted By" := UserId;
                        LeaveJournalLine."Leave Posting Description" := 'Leave Allocation on' + Format(Today);
                        LeaveJournalLine."Leave Entry Type" := LeaveJournalLine."Leave Entry Type"::Positive;
                        LeaveJournalLine."Leave Type" := 'ANNUAL';
                        LeaveJournalLine."No. of Days" := LeaveType.Days;
                        LeaveJournalLine."Document No." := 'LV' + FiscalYearEndPCode;
                        LeaveJournalLine.Insert();
                    end;
                    Commit();
                until HREmp.Next() = 0;
                // JounarnalPost.Code(LeaveJournalLine);
                //Codeunit.Run(Codeunit::"HR Leave Jnl.-Post", LeaveJournalLine);
            end;
        end;
    end;


    procedure fnCreateCarryForwardLeaveBal(var PayrollPeriod: Record "HR Leave Periods")
    var
        AccPeriod: Record "HR Leave Periods";
        NextDate: Date;
        EndOfYear: Boolean;
        Empleave: Record "HR Leave Ledger Entries";
        LeaveType: Record "HR Leave Types";
        MaturityDate: Date;
        NextMaturityDate: Date;
        Emp: Record Employee;
        CarryForwardDays: Decimal;
        EmpleaveCpy: Record "HR Leave Ledger Entries";
    begin

        dAlloc := 0;
        dEarnd := 0;
        dTaken := 0;
        dLeft := 0;
        cReimbsd := 0;
        cPerDay := 0;
        cbf := 0;
        CarryForward := 0;

        HRSetup.Get();

        LeaveType.Reset();
        LeaveType.SetRange(LeaveType.Code, 'ANNUAL');
        if LeaveType.Find('-') then begin
            HREmp.Reset();
            HREmp.SetRange(HREmp.Status, HREmp.Status::Active);
            //HREmp.SetRange(HREmp."No.", 'NLC20150178');
            if HREmp.Find('-') then begin
                repeat
                    HRLeaveLedgerEntries.Reset();
                    HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Staff No.", HREmp."No.");
                    HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Type", 'ANNUAL');
                    HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Posting Date", HRSetup."Leave Posting Period[FROM]", HRSetup."Leave Posting Period[TO]");
                    if HRLeaveLedgerEntries.Find('-') then begin
                        dAlloc := 0;
                        repeat
                            dAlloc := HRLeaveLedgerEntries."No. of days" + dAlloc;
                        until HRLeaveLedgerEntries.Next() = 0;
                    end;

                    if dAlloc > LeaveType."Max Carry Forward Days" then
                        dAlloc := 15;

                    //MESSAGE('%1',dAlloc);
                    LeaveJournalLine.Reset();
                    if LeaveJournalLine.FindLast() then begin
                        LeaveJournalLine.Init();
                        LeaveJournalLine."Journal Batch Name" := 'POSITIVE';
                        LeaveJournalLine."Entry No." := LeaveJournalLine."Entry No." + 1;
                        LeaveJournalLine."Leave Calendar Code" := FiscalYearEndPCode;
                        LeaveJournalLine."Leave Approval Date" := PayrollPeriod."Starting Date";
                        LeaveJournalLine."Staff No." := HREmp."No.";
                        LeaveJournalLine."Staff Name" := HREmp."Search Name";
                        LeaveJournalLine."Posting Date" := Today;
                        LeaveJournalLine."Leave Posting Description" := 'Carry Forward Days on' + Format(Today);
                        LeaveJournalLine."Leave Entry Type" := LeaveJournalLine."Leave Entry Type"::Positive;
                        LeaveJournalLine."Leave Type" := 'ANNUAL';
                        LeaveJournalLine."Leave Posting Type" := LeaveJournalLine."Leave Posting Type"::"Carry Forward";
                        LeaveJournalLine."No. of Days" := dAlloc;
                        LeaveJournalLine."Posted By" := UserId;
                        LeaveJournalLine."Document No." := 'LV' + FiscalYearEndPCode;
                        if LeaveJournalLine."No. of Days" > 0 then
                            LeaveJournalLine.Insert();
                    end;
                until HREmp.Next() = 0;
                //Codeunit.Run(Codeunit::"HR Leave Jnl.-Post", LeaveJournalLine);
            end;
        end;
    end;

    procedure Clearpendingleaves()
    var
        myInt: Integer;
        LeaveApp: Record "HR Leave Application";
        ApprovalEntry: Record "Approval Entry";
    begin
        LeaveApp.Reset();
        LeaveApp.SetRange(LeaveApp.Status, LeaveApp.Status::"Pending Approval");
        LeaveApp.SetFilter(LeaveApp."Application Date", '<%1', Today);
        if LeaveApp.FindFirst() then begin
            repeat
                ApprovalEntry.Reset();
                ApprovalEntry.SetRange("Document No.", LeaveApp."Application Code");
                if ApprovalEntry.FindFirst() then begin
                    repeat
                        ApprovalEntry.Status := ApprovalEntry.Status::Approved;
                        ApprovalEntry.Modify();
                    until ApprovalEntry.Next() = 0
                end;
                LeaveApp.Status := LeaveApp.Status::Approved;
                LeaveApp.Modify();
            until LeaveApp.Next() = 0;
        end;

    end;
}
