 
table 50125 "HR Leave Application"
{
    DrillDownPageId = "HR Leave Applications List";
    LinkedObject = false;
    LookupPageId = "HR Leave Applications List";
    Caption = 'HR Leave Application';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Application Code"; Code[20])
        {
            Caption = 'Application Code';
            trigger OnValidate()
            begin
                //TEST IF MANUAL NOs ARE ALLOWED
                if "Application Code" <> xRec."Application Code" then begin
                    HRSetup.Get();
                    NoSeriesMgt.TestManual(HRSetup."Leave Application Nos.");
                    "No series" := '';
                end;
            end;
        }
        field(3; "Leave Type"; Code[30])
        {
            TableRelation = "HR Leave Types".Code;
            Caption = 'Leave Type';
            trigger OnValidate()
            begin
                HREmp.RESET;
                HREmp.SETRANGE("No.", "Employee No");
                IF HREmp.FIND('-') THEN BEGIN
                    // Acting := HREmp.Acting;
                    // "Position Acting" := HREmp."Job Title5";
                    // "Department acting" := HREmp."Department acting";
                    // "DEpartment acting Name" := HREmp."Department acting Name";
                end;
                HRLeaveTypes.Reset();
                HRLeaveTypes.SetRange(HRLeaveTypes.Code, "Leave Type");
                if HRLeaveTypes.Find('-') then begin
                    HREmp.Reset();
                    HREmp.SetRange(HREmp."No.", "Employee No");
                    HREmp.SetRange(HREmp.Gender, HRLeaveTypes.Gender);
                    if HREmp.Find('-') then
                        exit
                    else
                        if HRLeaveTypes.Gender <> HRLeaveTypes.Gender::Both then
                            Error('This leave type is restricted to the ' + Format(HRLeaveTypes.Gender) + ' gender');
                end;

                FindMaturityDate();
                "Maturity Date" := MaturityDate;
                "Fiscal Start Date" := FiscalStart;

                GetLeaveStats("Leave Type");
            end;
        }
        field(4; "Days Applied"; Decimal)
        {
            DecimalPlaces = 0 : 0;
            Caption = 'Days Applied';
            trigger OnValidate()
            begin

                TestField("Leave Type");

                //Calc. Ret/End Dates
                if ("Days Applied" <> 0) and ("Start Date" <> 0D) then begin
                    "Return Date" := DetermineLeaveReturnDate("Start Date", "Days Applied");
                    "End Date" := DeterminethisLeaveEndDate("Return Date");
                    Modify();
                end;
                //   IF "Days Applied">=15 THEN "Request Leave Allowance":=TRUE;
            end;
        }
        field(5; "Start Date"; Date)
        {
            Caption = 'Start Date';
            trigger OnValidate()
            begin
                if "Start Date" = Today then
                    Error('Start Date cannot be same as Today');

                if "Start Date" = 0D then begin
                    "Return Date" := 0D;
                    "End Date" := 0D;
                end else
                    //    IF DetermineIfIsNonWorking("Start Date") = TRUE THEN
                    //    BEGIN
                    //        ERROR('The Start date must be a working day');
                    //    END;
                    Validate("Days Applied");


                FindMaturityDate();
                "Maturity Date" := MaturityDate;
                "Fiscal Start Date" := FiscalStart;

                //MESSAGE(FORMAT("Return Date"));

                if "Return Date" > "Maturity Date" then
                    Error('Return Date %1 is not within the Current Financial Year!!', "Return Date");
            end;
        }
        field(6; "Return Date"; Date)
        {
            Caption = 'Return Date';
            Editable = true;
        }
        field(7; "Application Date"; Date)
        {
            Caption = 'Application Date';
        }
        field(12; Status; Option)
        {
            Editable = true;
            OptionCaption = 'New,Pending Approval,Approved,Rejected,Canceled,Posted';
            OptionMembers = New,"Pending Approval",Approved,Rejected,Canceled,Posted;
            Caption = 'Status';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if rec.Status = rec.Status::Approved then begin
                    NotifyApprover();
                end;

            end;
        }
        field(15; "Applicant Comments"; Text[250])
        {
            Caption = 'Applicant Comments';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                HREmp.RESET;
                HREmp.SETRANGE("No.", "Employee No");
                IF HREmp.FIND('-') THEN BEGIN
                    // Acting := HREmp.Acting;
                    // "Position Acting" := HREmp."Job Title5";
                    // "Department acting" := HREmp."Department acting";
                    // "DEpartment acting Name" := HREmp."Department acting Name";
                    // rec.Modify();
                end;

            end;
        }
        field(17; "No series"; Code[30])
        {
            Caption = 'No series';
        }
        field(18; Gender; Option)
        {
            CalcFormula = lookup(Employee.Gender where("No." = field("Employee No")));
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Male,Female';
            OptionMembers = " ",Male,Female;
            Caption = 'Gender';
        }
        field(28; Selected; Boolean)
        {
            Caption = 'Selected';
        }
        field(31; "Current Balance"; Decimal)
        {
            FieldClass = Normal;
            Caption = 'Current Balance';
        }
        field(32; Posted; Boolean)
        {
            Caption = 'Posted';
        }
        field(33; "Posted By"; Text[250])
        {
            Caption = 'Posted By';
        }
        field(34; "Date Posted"; Date)
        {
            Caption = 'Date Posted';
        }
        field(35; "Time Posted"; Time)
        {
            Caption = 'Time Posted';

        }
        field(36; Reimbursed; Boolean)
        {
            Caption = 'Reimbursed';
        }
        field(37; "Days Reimbursed"; Decimal)
        {
            Caption = 'Days Reimbursed';
        }
        field(3900; "End Date"; Date)
        {
            Editable = false;
            Caption = 'End Date';
        }
        field(3901; "Total Taken"; Decimal)
        {
            DecimalPlaces = 2 : 2;
            Caption = 'Total Taken';
        }
        field(3921; "E-mail Address"; Text[60])
        {
            Editable = false;
            ExtendedDatatype = EMail;
            Caption = 'E-mail Address';
        }
        field(3924; "Entry No"; Integer)
        {
            Caption = 'Entry No';
        }
        field(3929; "Start Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Start Date Filter';
        }
        field(3936; "Cell Phone Number"; Text[50])
        {
            ExtendedDatatype = PhoneNo;
            Caption = 'Cell Phone Number';
        }
        field(3937; "Request Leave Allowance"; Boolean)
        {
            Caption = 'Request Leave Allowance';
        }
        field(3939; Picture; Blob)
        {
            Caption = 'Picture';
        }
        field(3940; Names; Text[100])
        {
            Caption = 'Names';
        }
        field(3942; "Leave Allowance Entittlement"; Boolean)
        {
            Caption = 'Leave Allowance Entittlement';
        }
        field(3943; "Leave Allowance Amount"; Decimal)
        {
            Caption = 'Leave Allowance Amount';
        }
        field(3945; "Details of Examination"; Text[200])
        {
            Caption = 'Details of Examination';
        }
        field(3947; "Date of Exam"; Date)
        {
            Caption = 'Date of Exam';
        }
        field(3949; Reliever; Code[50])
        {
            TableRelation = Employee."No.";
            Caption = 'Reliever';
            trigger OnValidate()
            begin
                if Reliever = "Employee No" then
                    Error('It is not possible for an Employee to relieve him/herself');

                if HREmp.Get(Reliever) then
                    "Reliever Name" := HREmp."Search Name"
                else
                    "Reliever Name" := '';
            end;
        }
        field(3950; "Reliever Name"; Text[100])
        {
            Caption = 'Reliever Name';
        }
        field(3952; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(3955; "Supervisor Email"; Text[50])
        {
            Caption = 'Supervisor Email';
        }
        field(3956; "Number of Previous Attempts"; Text[200])
        {
            Caption = 'Number of Previous Attempts';
        }
        field(3958; "Job Tittle"; Text[50])
        {
            Caption = 'Job Tittle';
        }
        field(3959; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(3961; "Employee No"; Code[20])
        {
            Caption = 'Employee No';
        }
        field(3962; Supervisor; Code[50])
        {
            TableRelation = "User Setup"."User ID";
            Caption = 'Supervisor';
        }
        field(3969; "Responsibility Center"; Code[20])
        {
            // TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            TableRelation = "Responsibility Center".Code;
            //TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            Caption = 'Department';
            // CaptionClass = '1,1,2';

            trigger OnValidate()
            var
                myInt: Integer;
                Responsblece: Record "Responsibility Center";
            begin
                Responsblece.Reset();
                Responsblece.SetRange(Code, Rec."Responsibility Center");
                if Responsblece.FindFirst() then
                    "Department Name" := Responsblece.Name;

            end;
        }
        field(3970; "Approved days"; Integer)
        {
            Caption = 'Approved days';
            trigger OnValidate()
            begin
                if "Approved days" > "Days Applied" then
                    Error(TEXT001);
            end;
        }
        field(3972; Emergency; Boolean)
        {
            Description = 'This is used to ensure one can apply annual leave which is emergency';
            Caption = 'Emergency';
        }
        field(3973; "Approver Comments"; Text[200])
        {
            Caption = 'Approver Comments';
        }
        field(3974; MyRecId; RecordId)
        {
            Caption = 'MyRecId';
        }
        field(3975; "Employee Name"; Text[100])
        {
            CalcFormula = lookup(Employee."Search Name" where("No." = field("Employee No")));
            Editable = false;
            FieldClass = FlowField;
            Caption = 'Employee Name';
        }
        field(3976; "On Leave"; Boolean)
        {
            Caption = 'On Leave';
        }
        field(3977; "Postedd By"; Code[40])
        {
            Caption = 'Postedd By';
        }
        field(3978; "Maturity Date"; Date)
        {
            Caption = 'Maturity Date';
        }
        field(3979; "Fiscal Start Date"; Date)
        {
            Caption = 'Fiscal Start Date';
        }
        field(4000; "Leave Plan"; Code[40])
        {
            // DataClassification = ToBeClassified;
            // TableRelation = "HR Leave Planner Lines"."Application Code" where("Employee No" = field("Employee No"));
            // trigger OnValidate()
            // var
            //     myInt: Integer;
            //     HrPlannerLines: Record "HR Leave Planner Lines";
            // begin
            //     HrPlannerLines.Reset();
            //     HrPlannerLines.SetRange("Application Code", Rec."Leave Plan");
            //     if HrPlannerLines.Find('-') then begin
            //         Rec."Start Date" := HrPlannerLines."Start Date";
            //         Rec."Return Date" := HrPlannerLines."Return Date";
            //     end;

            // end;
        }
        field(4001; LeaveLineNum; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4002; "PlannerHeaderNum"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(40003; "Department Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(40004; Acting; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(40005; "Position Acting"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(40006; "Department acting"; Code[10])
        {
            TableRelation = "Responsibility Center".Code;

            Caption = 'Department Acting';
            // CaptionClass = '1,1,2';

            trigger OnValidate()
            var
                myInt: Integer;
                Responsblece: record "Responsibility Center";

            begin
                Responsblece.Reset();
                Responsblece.SetRange(Code, Rec."Responsibility Center");
                if Responsblece.FindFirst() then
                    "DEpartment acting Name" := Responsblece.Name;
            end;
        }
        field(40007; "DEpartment acting Name"; Text[200])
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; "Application Code")
        {
            Clustered = true;
        }
    }

    fieldgroups { }


    trigger OnInsert()
    begin
        //No. Series
        if "Application Code" = '' then begin
            HRSetup.Get();
            HRSetup.TestField(HRSetup."Leave Application Nos.");
            NoSeriesMgt.InitSeries(HRSetup."Leave Application Nos.", xRec."No series", 0D, "Application Code", "No series");
        end;
        HREmp.RESET;
        HREmp.SETRANGE("No.", "Employee No");
        IF HREmp.FIND('-') THEN BEGIN
            // Acting := HREmp.Acting;
            // "Position Acting" := HREmp."Job Title5";
            // "Department acting" := HREmp."Department acting";
            // "DEpartment acting Name" := HREmp."Department acting Name";
        end;

        /*
   //check if user id is administrator and validate with employee no
    IF (USERID <>'LANDCOMMISSION\ADMINISTRATOR') AND (USERID<>'LANDCOMMISSION\fred.ogolla') THEN BEGIN
        //    HREmp.RESET;
        //    HREmp.SETRANGE(HREmp."User ID",USERID);
        //    IF HREmp.FIND('-') THEN BEGIN
        //        //Populate fields
        //        "Employee No":=HREmp."No.";
        //        Names:=HREmp."Full Name";
        //        Gender:=HREmp.Gender;
        //        "Application Date":=TODAY;
        //        "User ID":=USERID;
        //        "Job Tittle":=HREmp."Job Title";
        //        HREmp.CALCFIELDS(HREmp.Picture);
        //        Picture:=HREmp.Picture;
        //        "Responsibility Center":=HREmp."Responsibility Center";
        //        GetApplicantSupervisor(USERID);
        //    END;
    END ELSE BEGIN
             HREmp.RESET;
             HREmp.SETRANGE("No.","Employee No");
             IF HREmp.FIND('-') THEN BEGIN
                 //Populate fields
                 "Employee No":=HREmp."No.";
                 Names:=HREmp."Full Name";
                 Gender:=HREmp.Gender;
                 "Application Date":=TODAY;
                 "User ID":=HREmp."User ID";
                 "Job Tittle":=HREmp."Job Title";

                 HREmp.CALCFIELDS(HREmp.Picture);
                 Picture:=HREmp.Picture;
                 "Responsibility Center":=HREmp."Responsibility Center";
                 GetApplicantSupervisor(HREmp."User ID");
              END;
   END;
   */

        //to cater for document attachment
        //**Changes** To add a record id of the rec to enable flow field with the record links table
        MyRecRef.GetTable(Rec);
        MyRecId := MyRecRef.RecordId;

        /*
            //To make The OnLeave boolean field in Employee card False
            VALIDATE("Start Date") ;

           HREmp.RESET;
           HREmp.SETRANGE(HREmp."No.","Employee No") ;
           IF HREmp.FIND('-') THEN
           BEGIN
              IF "Return Date"<=TODAY  THEN
              MESSAGE (FORMAT("Return Date"));
              REPEAT
                HREmp."On Leave":= FALSE
               // HREmp.MODIFY
              UNTIL HREmp.NEXT=0;
              HREmp.MODIFY
           END
        */

        /*
        UserSetup.RESET;
        UserSetup.SETRANGE(UserSetup."User ID",USERID);
        IF UserSetup.FIND('-') THEN
        BEGIN
            IF (UserSetup."Approver ID"='') OR (UserSetup."Approver ID"=USERID) THEN
            BEGIN
                    ApprovalTemplates.RESET;
                    ApprovalTemplates.SETRANGE(ApprovalTemplates."Document Type",ApprovalTemplates."Document Type"::"Leave Application");
                    ApprovalTemplates.SETRANGE(ApprovalTemplates."Responsibility Center",HREmp."Responsibility Center");
                    ApprovalTemplates.SETRANGE(ApprovalTemplates.Enabled,TRUE);
                    IF ApprovalTemplates.FIND('-') THEN
                    BEGIN
                            AdditionalApprovers.RESET;
                            AdditionalApprovers.SETRANGE(AdditionalApprovers."Approval Code",ApprovalTemplates."Approval Code");
                            AdditionalApprovers.SETRANGE(AdditionalApprovers."Document Type",AdditionalApprovers."Document Type"::"Leave Application");
                            IF AdditionalApprovers.FIND('-') THEN
                            BEGIN
                                IF (AdditionalApprovers."Approver ID"='') OR (AdditionalApprovers."Approver ID"=USERID) THEN
                                  ERROR('You must have a Recommender in User Setup or an Approver in Additional Approvers')
                            END

                    END;
            END;
        END ;
        */

        FindMaturityDate();
        "Maturity Date" := MaturityDate;
        "Fiscal Start Date" := FiscalStart;

    end;

    trigger OnModify()
    var
        myInt: Integer;
    begin
        
    end;


    var
        HRSetup: Record "HR Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        HREmp: Record Employee;
        varDaysApplied: Integer;
        HRLeaveTypes: Record "HR Leave Types";
        ReturnDateLoop: Boolean;
        mSubject: Text[250];
        ApplicantsEmail: Text[30];
        //SMTP: Codeunit "SMTP Mail";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        // HRJournalLine: Record "HR Leave Journal Line";
        "LineNo.": Integer;
        HRJournalLine: Record "HR Leave Ledger Entries";
        ApprovalComments: Record "Approval Comment Line";
        URL: Text[500];
        sDate: Record Date;
        Customized: Record "HR Calendar List";
         HREmailParameters: Record "HR E-Mail Parameters";
        HRLeavePeriods: Record "HR Leave Periods";
        HRJournalBatch: Record "HR Leave Journal Batch";
        TEXT001: Label 'Days Approved cannot be more than applied days';
        HRLeaveEntries: Record "HR Leave Ledger Entries";
        intEntryNo: Integer;
        Calendar: Record Date;
        empMonths: Integer;
        HRLeaveApp: Record "HR Leave Application";
        mWeekDay: Integer;
        empGender: Option Female;
        mMinDays: Integer;
        Text002: Label 'You cannot apply for leave until your are over [%1] months old in the company';
        Text003: Label 'UserID [%1] does not exist in [%2]';
        //ApprovalSetup: Record "Approval Setup";
        MyRecRef: RecordRef;
        UserSetup: Record "User Setup";
        //ApprovalTemplates: Record "Approval Templates";
        //AdditionalApprovers: Record "Additional Approvers";
        HRCalendar: Record "HR Calendar";
        ApprovalEntry: Record "Approval Entry";
        MaturityDate: Date;
        FiscalStart: Date;
        FiscalyearError: Label 'Your resumption date #1#### is not within the current financial year!!';
        ReturnDate: Date;
        dAlloc: Decimal;
        dEarnd: Decimal;
        dTaken: Decimal;
        dLeft: Decimal;
        cReimbsd: Decimal;
        cPerDay: Decimal;
        cbf: Decimal;
        HRLeaveLedgerEntries: Record "HR Leave Ledger Entries";


    procedure DetermineLeaveReturnDate(var fBeginDate: Date; var fDays: Decimal) fReturnDate: Date
    begin
        varDaysApplied := fDays;
        fReturnDate := fBeginDate;
        repeat
            if DetermineIfIncludesNonWorking("Leave Type") = false then begin
                fReturnDate := CalcDate('1D', fReturnDate);
                if DetermineIfIsNonWorking(fReturnDate) then
                    varDaysApplied := varDaysApplied + 1
                else
                    varDaysApplied := varDaysApplied;
                varDaysApplied := varDaysApplied - 1
            end
            else begin
                fReturnDate := CalcDate('1D', fReturnDate);
                varDaysApplied := varDaysApplied - 1;
            end;
        until varDaysApplied = 0;
        exit(fReturnDate);
    end;


    procedure DetermineIfIncludesNonWorking(var fLeaveCode: Code[30]): Boolean
    begin
        if HRLeaveTypes.Get(fLeaveCode) then
            if HRLeaveTypes."Inclusive of Non Working Days" = true then
                exit(true)
            else
                exit(false);
    end;


    procedure DetermineIfIsNonWorking(var bcDate: Date) Isnonworking: Boolean
    begin

        Customized.Reset();
        Customized.SetRange(Customized.Date, bcDate);
        if Customized.Find('-') then
            if Customized."Non Working" = true then
                exit(true)
            else
                exit(false);
    end;


    procedure DeterminethisLeaveEndDate(var fDate: Date) fEndDate: Date
    begin
        ReturnDateLoop := true;
        fEndDate := fDate;
        if fEndDate <> 0D then begin
            fEndDate := CalcDate('-1D', fEndDate);
            while (ReturnDateLoop) do
                if DetermineIfIsNonWorking(fEndDate) then
                    fEndDate := CalcDate('-1D', fEndDate)
                else
                    ReturnDateLoop := false;
        end;
        exit(fEndDate);
    end;

    procedure CreateLeaveLedgerEntries()
    var
        EndFix: Integer;
        StartFix: Integer;
        PeriodFix: Code[30];
        FiscalYearEndPCode: code[40];
        HrEmplo: Record Employee;
    begin
        //GET OPEN LEAVE PERIOD
        FiscalYearEndPCode := '';
        HrEmplo.Reset();
        HrEmplo.SetRange(Status, HrEmplo.Status::Active);
        if HrEmplo.FindFirst() then
            FiscalYearEndPCode := HrEmplo."Leave Calendar";
        HRLeavePeriods.Reset();
        HRLeavePeriods.SetRange(HRLeavePeriods.Closed, false);
        HRLeavePeriods.Find('-');

        HRJournalBatch.Reset();
        HRSetup.Get();
        HRJournalBatch.Get(HRSetup."Default Leave Posting Template", HRSetup."Negative Leave Posting Batch");
        //leave code//HK
        HRCalendar.Reset();
        HRCalendar.SetRange(HRCalendar.Current, true);
        if HRCalendar.Find('-') then begin
            HRJournalLine.Reset();
            if HRJournalLine.FindLast() then begin
                HRJournalLine.Init();
                HRJournalLine."Journal Batch Name" := HRSetup."Default Leave Posting Template";
                HRJournalLine."Journal Batch Name" := HRSetup."Negative Leave Posting Batch";
                HRJournalLine."Entry No." := HRJournalLine."Entry No." + 1;
                //HRJournalLine."Leave Period":=HRLeavePeriods."Period Code";
                HRJournalLine."Leave Calendar Code" := FiscalYearEndPCode;
                HRJournalLine."Document No." := "Application Code";
                HRJournalLine."Staff No." := "Employee No";
                HRJournalLine.Validate(HRJournalLine."Staff No.");
                HRJournalLine."Posting Date" := Today;
                HRJournalLine."Leave Entry Type" := HRJournalLine."Leave Entry Type"::Negative;
                HRJournalLine."Leave Approval Date" := Today;
                HRJournalLine."Leave Posting Description" := 'Negative Leave Posting For %' + "Application Code";
                HRJournalLine."Leave Type" := "Leave Type";
                //HRJournalLine."Leave Period Start Date":=HRLeavePeriods."Start Date";
                //HRJournalLine."Leave Period End Date":=HRLeavePeriods."End Date";
                HRJournalLine."No. of Days" := ("Days Applied") * -1;
                HRJournalLine.Insert(true);
            end;
            //Post Journal
            // HRJournalLine.Reset();
            // HRJournalLine.SetRange("Journal Template Name", HRSetup."Default Leave Posting Template");
            // HRJournalLine.SetRange("Journal Batch Name", HRSetup."Negative Leave Posting Batch");
            // if HRJournalLine.Find('-') then begin
            //     Codeunit.Run(Codeunit::"HR Leave Jnl.-Post", HRJournalLine);
            NotifyApplicant();
            NotifyApprover();
            //  NotifyDirectors;

            //Mark document as posted
            Posted := true;
            "On Leave" := true;
            //"Posted By":=USERID;
            "Date Posted" := Today;
            "Time Posted" := Time;
            //Mark employee as on leave
            //Morris
            ApprovalEntry.Reset();
            ApprovalEntry.SetRange("Document No.", "Application Code");
            if ApprovalEntry.FindLast() then
                "Posted By" := ApprovalEntry."Approver ID"
        end;

    end;

    procedure NotifyApprover()
    var
        UserSetup: Record "User Setup";
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange("Document No.", rec."Application Code");
        // ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        // ApprovalEntry.SetFilter(ApprovalEntry."Sequence No.", '>%1', 1);
        if ApprovalEntry.FindFirst() then begin
            HREmp.Reset();
            HREmp.SetRange("User ID", ApprovalEntry."Approver ID");
            if HREmp.FindFirst() then begin
                HREmp.TestField(HREmp."Company E-Mail");
                HREmailParameters.Reset();
                HREmailParameters.Get(HREmailParameters."Associate With"::"Leave Notifications");
                EmailMessage.Create(
                                    HREmp."Company E-Mail",
                                    'Leave Approval Notification',
                                    'You have approved leave application No .' + '<br>' + "Application Code" +// ' Leave Type ' + "Leave Type" +
                                    'with the following parameters:' +
                                    '<br>Employee Name:' + UpperCase(Names) +
                                    '<br>Employee No. ' + "Employee No" + //' - '+ UPPERCASE(Names) +
                                    '<br>Application No - ' + "Application Code" +
                                    '<br>Start Date - ' + Format("Start Date") +
                                    '<br>End Date - ' + Format("End Date") +
                                    '<br>Return Date - ' + Format("Return Date") +
                                    '<br>Days Applied - ' + Format("Days Applied") +
                                    '<br> Leave Type- ' + "Leave Type",
                                    // '<br>Status-'+Status,
                                    true
                                  );
                Email.Send(EmailMessage);
            end;
        end;
    end;

    procedure NotifyApplicant()
    begin

        HREmp.Get("Employee No");
        HREmp.TestField(HREmp."Company E-Mail");

        HREmailParameters.Reset();
        HREmailParameters.Get(HREmailParameters."Associate With"::"Leave Notifications");
        ////HREmailParameters.TESTFIELD(HREmailParameters."Sender Name");
        //HREmailParameters.TESTFIELD(HREmailParameters."Sender Address");
        //HREmailParameters.TESTFIELD(HREmailParameters.Subject);

        EmailMessage.Create(

                            HREmp."Company E-Mail",
                            'Leave Approval Notification',
                            'Leave Application' + '<br>' + "Application Code" +// ' Leave Type ' + "Leave Type" +
                            ' has been approved with the following parameters:' +
                            '<br>Employee Name:' + UpperCase(Names) +
                            '<br>Employee No. ' + "Employee No" + //' - '+ UPPERCASE(Names) +
                            '<br>Application No - ' + "Application Code" +
                            '<br>Start Date - ' + Format("Start Date") +
                            '<br>End Date - ' + Format("End Date") +
                            '<br>Return Date - ' + Format("Return Date") +
                            '<br>Days Applied - ' + Format("Days Applied") +
                            '<br> Leave Type- ' + "Leave Type",
                            // '<br>Status-'+Status,
                            true
                          );

        Email.Send(EmailMessage);
    end;

    local procedure GetApplicantSupervisor(EmpUserID: Code[50]) SupervisorID: Code[10]
    var
        UserSetup: Record "User Setup";
        UserSetup2: Record "User Setup";
        HREmp2: Record Employee;
    begin
        SupervisorID := '';
        UserSetup.Reset();
        if UserSetup.Get(EmpUserID) then begin
            //UserSetup.TESTFIELD(UserSetup."Approver ID");
            //Get supervisor e-mail
            UserSetup2.Reset();
            if UserSetup2.Get(UserSetup."Approver ID") then
                //  UserSetup2.CALCFIELDS(UserSetup2."E-Mail");
                UserSetup2.TestField(UserSetup2."E-Mail");

        end else
            Error(Text003, EmpUserID, UserSetup.TableCaption);
    end;


    procedure NotifyDirectors()
    begin

        HREmailParameters.Reset();
        HREmailParameters.Get(HREmailParameters."Associate With"::"Leave Approval Notifications");

        //HREmailParameters.TESTFIELD(HREmailParameters."Sender Name");
        //HREmailParameters.TESTFIELD(HREmailParameters."Sender Address");
        //HREmailParameters.TESTFIELD(HREmailParameters."Recipient 1");
        //HREmailParameters.TESTFIELD(HREmailParameters.Subject);

        EmailMessage.Create(

                            HREmailParameters."Recipient 1",
                            'Approved Leave Notification',
                            'Leave Application' + '<br>' + "Application Code" +
                            ' has been approved with the following parameters:' +
                            '<br>Employee No. ' + "Employee No" + ' - ' + UpperCase(Names) +
                            '<br>Application No - ' + "Application Code" +
                            '<br>Start Date - ' + Format("Start Date") +
                            '<br>End Date - ' + Format("End Date") +
                            '<br>Return Date - ' + Format("Return Date") +
                            '<br>Days Applied - ' + Format("Days Applied") +
                            '<br>Status - ' + UpperCase(Format(Status)),
                            true
                          );

        //SMTP.AddRecipients(HREmailParameters."Recipient 2");
        Email.Send(EmailMessage);
    end;


    procedure DetermineLeaveReturnDate_Portal(var fBeginDate: Date; var fDays: Decimal; var LeaveType: Code[30]) fReturnDate: Date
    begin
        FindMaturityDate();
        "Maturity Date" := MaturityDate;

        varDaysApplied := fDays;
        fReturnDate := fBeginDate;
        repeat
            if DetermineIfIncludesNonWorking(LeaveType) = false then begin
                fReturnDate := CalcDate('1D', fReturnDate);
                if DetermineIfIsNonWorking(fReturnDate) then
                    varDaysApplied := varDaysApplied + 1
                else
                    varDaysApplied := varDaysApplied;
                varDaysApplied := varDaysApplied - 1
            end
            else begin
                fReturnDate := CalcDate('1D', fReturnDate);
                varDaysApplied := varDaysApplied - 1;
            end;
            if HRLeaveTypes.Code <> 'MATERNITY' then
                if fReturnDate > "Maturity Date" then
                    Error('Return Date %1 is not within the Current Financial Year!!', "Return Date");

        until varDaysApplied = 0;
        exit(fReturnDate);
    end;

    procedure FindMaturityDate()
    var
        AccPeriod: Record "HR Leave Periods";
    begin
        AccPeriod.Reset();
        AccPeriod.SetRange(AccPeriod."Starting Date", 0D, Today);
        AccPeriod.SetRange(AccPeriod."New Fiscal Year", true);
        if AccPeriod.Find('+') then begin
            FiscalStart := AccPeriod."Starting Date";
            MaturityDate := CalcDate('1Y', AccPeriod."Starting Date");
            MaturityDate := CalcDate('-1D', MaturityDate);
            //MESSAGE('New Maturity Date %1',FORMAT(MaturityDate));
        end;
    end;


    procedure GetLeaveStats(LeaveType: Text[50])
    begin
        FindMaturityDate();
        "Maturity Date" := MaturityDate;
        "Fiscal Start Date" := FiscalStart;

        //MESSAGE('%1%2',MaturityDate,FiscalStart);

        dAlloc := 0;
        dEarnd := 0;
        dTaken := 0;
        dLeft := 0;
        cReimbsd := 0;
        cPerDay := 0;
        cbf := 0;
        HREmp.Reset();
        if HREmp.Get("Employee No") then begin

            HRSetup.Get();
            //Filter by Leave Type Selected
            HREmp.SetFilter(HREmp."Leave Type Filter", LeaveType);
            //Filter by Leave Period from HR Setup
            //HREmp.SETFILTER(HREmp."Date Filter",'%1..%2',HRSetup."Leave Posting Period[FROM]",HRSetup."Leave Posting Period[TO]");
            HRLeaveLedgerEntries.Reset();
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Staff No.", "Employee No");
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Entry Type", HRLeaveLedgerEntries."Leave Entry Type"::Positive);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Type", LeaveType);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Posting Date", HRSetup."Leave Posting Period[FROM]", HRSetup."Leave Posting Period[TO]");
            if HRLeaveLedgerEntries.Find('-') then begin
                dAlloc := 0;
                repeat
                    dAlloc := HRLeaveLedgerEntries."No. of days" + dAlloc;
                until HRLeaveLedgerEntries.Next() = 0;
            end;

            HRLeaveLedgerEntries.Reset();
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Staff No.", "Employee No");
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Entry Type", HRLeaveLedgerEntries."Leave Entry Type"::Negative);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Type", LeaveType);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Posting Date", HRSetup."Leave Posting Period[FROM]", HRSetup."Leave Posting Period[TO]");

            if HRLeaveLedgerEntries.Find('-') then begin
                dTaken := 0;
                repeat
                    dTaken := HRLeaveLedgerEntries."No. of days" + dTaken;
                until HRLeaveLedgerEntries.Next() = 0;
            end;
            //Leave Balance
            dEarnd := dAlloc + dTaken;
            dLeft := dAlloc + dTaken;

            //Reimbursed Leave Days
            cbf := HREmp."Reimbursed Leave Days";
            cReimbsd := HREmp."Cash - Leave Earned";
            cPerDay := HREmp."Cash per Leave Day";

        end
    end;
}
