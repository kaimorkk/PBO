 
   
report 50101 "HR Leave Adjustment"
{
    ProcessingOnly = true;
    ApplicationArea = All;
    Caption = 'HR Leave Adjustment';
    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = where(Status = const(Active));
            RequestFilterFields = "No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Gender;
            column(ReportForNavId_1; 1) { }

            trigger OnAfterGetRecord()
            var
                HrEmplo: Record Employee;
                FiscalYearEndPCode: Text;
                HRSetup: Record "HR Setup";
            begin
                FiscalYearEndPCode := '';
                HRSetup.Get();
                //Employee.TESTFIELD(Employee.Gender);
                HrEmplo.Reset();
                HrEmplo.SetRange(Status, HrEmplo.Status::Active);
                if HrEmplo.FindFirst() then
                    FiscalYearEndPCode := HrEmplo."Leave Calendar";

                //Get current leave period
                HRLeavePeriods.Reset();
                HRLeavePeriods.SetRange(HRLeavePeriods."New Fiscal Year", true);
                HRLeavePeriods.SetRange(HRLeavePeriods.Closed, false);
                HRLeavePeriods.SetRange(HRLeavePeriods."Date Locked", false);
                if HRLeavePeriods.Find('-') then begin
                    HRLeaveTypes.Reset();
                    if LeaveTypeFilter <> '' then
                        HRLeaveTypes.SetRange(HRLeaveTypes.Code, LeaveTypeFilter);

                    if HRLeaveTypes.Find('-') then
                        repeat
                            //          HRLeaveLedger.SETRANGE(HRLeaveLedger."Staff No.",Employee."No.");
                            //        HRLeaveLedger.SETRANGE(HRLeaveLedger."Leave Type",HRLeaveTypes.Code);
                            //      HRLeaveLedger.SETRANGE(HRLeaveLedger."Leave Entry Type",LeaveEntryType);
                            //    HRLeaveLedger.SETRANGE(HRLeaveLedger."Leave Period",HRLeavePeriods."Period Code");
                            //  IF NOT HRLeaveLedger.FIND('-') THEN
                            //BEGIN
                            OK := CheckGender(Employee, HRLeaveTypes);
                            if OK then begin
                                HRJournalLine.Init();
                                HRJournalLine."Journal Template Name" := Text0001;
                                HRJournalLine.Validate(HRJournalLine."Journal Template Name");

                                HRJournalLine."Journal Batch Name" := Format(BatchName);
                                //VALIDATE("Journal Batch Name");

                                HRJournalLine."Line No." := HRJournalLine."Line No." + 1000;

                                HRJournalLine."Leave Period" := Employee."Leave Calendar";
                                HRJournalLine.Validate(HRJournalLine."Leave Period");

                                HRJournalLine."Leave Period Start Date" := HRSetup."Leave Posting Period[FROM]";
                                HRJournalLine.Validate(HRJournalLine."Leave Period Start Date");

                                HRJournalLine."Staff No." := Employee."No.";
                                HRJournalLine.Validate(HRJournalLine."Staff No.");

                                HRJournalLine."Posting Date" := Today;
                                HRJournalLine.Description := PostingDescription;
                                HRJournalLine."Leave Entry Type" := LeaveEntryType;
                                HRJournalLine."Leave Type" := HRLeaveTypes.Code;
                                // Grade := Employee.Grade;
                                HRJournalLine."Document No." := FiscalYearEndPCode;
                                "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
                                "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
                                HRJournalLine."No. of Days" := HRLeaveTypes.Days;
                                HRJournalLine.Batched := true;
                                HRJournalLine.Insert();

                            end;
                        //               END ELSE
                        //             BEGIN
                        //              ERROR('Allocation has already been done');
                        //               END;
                        until HRLeaveTypes.Next() = 0
                    else
                        Error('No Leave Type found within the applied filters [%1]', Employee."Leave Type Filter");
                end else
                    Error('No Leave Period have been created');
            end;
        }
        dataitem("HR Leave Types"; "HR Leave Types")
        {
            RequestFilterFields = "Code";
            column(ReportForNavId_2; 2) { }
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                field(LeaveEntryType; LeaveEntryType)
                {
                    ApplicationArea = Basic;
                    Caption = 'Leave Entry Type';
                    ToolTip = 'Specifies the value of the Leave Entry Type field.';
                }
                field(PostingDescription; PostingDescription)
                {
                    ApplicationArea = Basic;
                    Caption = 'Posting Description';
                    ToolTip = 'Specifies the value of the Posting Description field.';
                }
                field(BatchName; BatchName)
                {
                    ApplicationArea = Basic;
                    Caption = 'Batch Name';
                    ToolTip = 'Specifies the value of the Batch Name field.';
                }
            }
        }

        actions { }

        trigger OnOpenPage()
        begin
            PostingDescription := 'Leave Allocation on ' + Format(Today);
        end;
    }

    labels { }

    trigger OnPostReport()
    begin
        Message('Process complete');
    end;

    trigger OnPreReport()
    begin
        if PostingDescription = '' then
            Error('Please enter posting description');



        if not HRJournalLine.IsEmpty then
            if Confirm(Text0002 + Text0003, false, HRJournalLine.Count, UpperCase(HRJournalLine.TableCaption), Text0001, BatchName) = true then
                HRJournalLine.DeleteAll()
            else
                Error('Process aborted');

        //Get Leave type filter
        LeaveTypeFilter := "HR Leave Types".GetFilter("HR Leave Types".Code);
    end;

    var
        HRLeavePeriods: Record "HR Leave Periods";
        AllocationDone: Boolean;
        HRLeaveTypes: Record "HR Leave Types";
        HRLeaveLedger: Record "HR Leave Ledger Entries";
        LeaveEntryType: Option Postive,Negative,Reimbursement;
        OK: Boolean;
        HRJournalLine: Record "HR Leave Journal Line";
        PostingDescription: Text;
        BatchName: Option POSITIVE,NEGATIVE;
        JournalTemplate: Code[20];
        Text0001: Label 'LEAVE';
        Text0002: Label 'There are [%1] entries in [%2  TABLE], Journal Template Name - [%3], Journal Batch Name [%4]';
        Text0003: Label '\\Do you want to proceed and overwite these entries?';
        LeaveTypeFilter: Text;
        i: Integer;


    procedure CheckGender(Emp: Record Employee; LeaveType: Record "HR Leave Types") Allocate: Boolean
    begin
        if Emp.Gender = Emp.Gender::Male then
            if LeaveType.Gender = LeaveType.Gender::Male then
                Allocate := true;

        if Emp.Gender = Emp.Gender::Female then
            if LeaveType.Gender = LeaveType.Gender::Female then
                Allocate := true;

        if LeaveType.Gender = LeaveType.Gender::Both then
            Allocate := true;
        exit(Allocate);

        if Emp.Gender <> LeaveType.Gender then
            Allocate := false;

        exit(Allocate);
    end;
}
