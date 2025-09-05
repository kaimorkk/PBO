 
report 50100 "HR Create Leave Year"
{
    Caption = 'Create Leave Year';
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset { }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PeriodCode; PeriodCode)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Period Code';
                        ToolTip = 'Specifies the value of the Period Code field.';
                    }
                    field(PeriodDescription; PeriodDescription)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Period Description';
                        ToolTip = 'Specifies the value of the Period Description field.';
                    }
                    field(LeaveYearStartDate; LeaveYearStartDate)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Period Starting Date';
                        ToolTip = 'Specifies the value of the Period Starting Date field.';
                    }
                    field(NoOfPeriods; NoOfPeriods)
                    {
                        ApplicationArea = Basic;
                        Caption = 'No. of Periods';
                        ToolTip = 'Specifies the value of the No. of Periods field.';
                    }
                    field(PeriodLength; PeriodLength)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Period Length';
                        ToolTip = 'Specifies the value of the Period Length field.';
                    }
                }
            }
        }

        actions { }

        trigger OnOpenPage()
        begin
            if NoOfPeriods = 0 then begin
                NoOfPeriods := 12;
                Evaluate(PeriodLength, '<1M>');
            end;
            if HRLeavePeriod.Find('+') then
                LeaveYearStartDate := HRLeavePeriod."Starting Date";
        end;
    }

    labels { }

    trigger OnPreReport()
    begin
        HRLeavePeriod."Starting Date" := LeaveYearStartDate;  //010114
        HRLeavePeriod.TestField("Starting Date");

        if HRLeavePeriod.Find('-') then begin
            FirstPeriodStartDate := HRLeavePeriod."Starting Date";
            FirstPeriodLocked := HRLeavePeriod."Date Locked";
            if (LeaveYearStartDate < FirstPeriodStartDate) and FirstPeriodLocked then
                if not
                   Confirm(
                     Text000 +
                     Text001)
                then
                    exit;
            if HRLeavePeriod.Find('+') then
                LastPeriodStartDate := HRLeavePeriod."Starting Date";
        end else
            if not
               Confirm(
                 Text002 +
                 Text003)
            then
                exit;

        LeaveYearStartDate2 := LeaveYearStartDate;


        for i := 1 to NoOfPeriods + 1 do begin
            //Exit if the fiscal year to be created is a date BELOW the current Leave year
            if (LeaveYearStartDate <= FirstPeriodStartDate) and (i = NoOfPeriods + 1) then
                exit;

            if (FirstPeriodStartDate <> 0D) then
                if (LeaveYearStartDate >= FirstPeriodStartDate) and (LeaveYearStartDate < LastPeriodStartDate) then
                    Error(Text004);

            HRLeavePeriod.Init();
            HRLeavePeriod."Period Code" := PeriodCode;
            HRLeavePeriod."Period Description" := PeriodDescription;
            HRLeavePeriod."Starting Date" := LeaveYearStartDate;
            HRLeavePeriod.Validate("Starting Date");
            HRLeavePeriod.Validate("Period Description");

            if (i = 1) or (i = NoOfPeriods + 1) then
                HRLeavePeriod."New Fiscal Year" := true;

            if (FirstPeriodStartDate = 0D) and (i = 1) then
                HRLeavePeriod."Date Locked" := true;

            if (HRLeavePeriod."Starting Date" < FirstPeriodStartDate) and FirstPeriodLocked then begin
                HRLeavePeriod.Closed := true;
                HRLeavePeriod."Date Locked" := true;
            end;

            if not HRLeavePeriod.Find('=') then
                HRLeavePeriod.Insert();
            LeaveYearStartDate := CalcDate(PeriodLength, LeaveYearStartDate);
        end;

        HRLeavePeriod.Get(LeaveYearStartDate2);
        //HRLeavePeriod.UpdateAvgItems(0);
    end;

    var
        Text000: Label 'The new fiscal year begins before an existing fiscal year, so the new year will be closed automatically.\\';
        Text001: Label 'Do you want to create and close the fiscal year?';
        Text002: Label 'Once you create the new fiscal year you cannot change its starting date.\\';
        Text003: Label 'Do you want to create the fiscal year?';
        Text004: Label 'It is only possible to create new fiscal years before or after the existing ones.';
        HRLeavePeriod: Record "HR Leave Periods";
        InvtSetup: Record "HR Setup";
        NoOfPeriods: Integer;
        PeriodLength: DateFormula;
        LeaveYearStartDate: Date;
        LeaveYearStartDate2: Date;
        FirstPeriodStartDate: Date;
        LastPeriodStartDate: Date;
        FirstPeriodLocked: Boolean;
        i: Integer;
        PeriodCode: Code[10];
        PeriodDescription: Text;
}
