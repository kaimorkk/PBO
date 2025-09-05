 
table 50140 "HR Leave Reimbursement"
{
    // DrillDownPageId = "HR Employee In-laws";
    // LookupPageId = "HR Employee In-laws";
    Caption = 'HR Leave Reimbursement';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Application Code"; Code[20])
        {
            Caption = 'Application Code';
        }
        field(3; "Leave Type"; Code[20])
        {
            TableRelation = "HR Leave Types".Code;
            Caption = 'Leave Type';
        }
        field(4; "Days Applied"; Decimal)
        {
            DecimalPlaces = 0 : 0;
            Caption = 'Days Applied';
        }
        field(5; "Start Date"; Date)
        {
            Caption = 'Start Date';
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
            Editable = false;
            OptionCaption = 'New,Pending Approval,HOD Approval,HR Approval,Final Approval,Rejected,Canceled,Approved,On leave,Resumed,Posted';
            OptionMembers = New,"Pending Approval","HOD Approval","HR Approval",MDApproval,Rejected,Canceled,Approved,"On leave",Resumed,Posted;
            Caption = 'Status';
        }
        field(15; "Applicant Comments"; Text[250])
        {
            Caption = 'Applicant Comments';
        }
        field(17; "No series"; Code[30])
        {
            Caption = 'No series';
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
            TableRelation = "Responsibility Center".Code;
            Caption = 'Responsibility Center';
        }
        field(3970; "Leave Application No"; Code[20])
        {
            TableRelation = "HR Leave Application"."Application Code" where(Status = const(Approved),
                                                                             "Employee No" = field("Employee No"));
            Caption = 'Leave Application No';
            trigger OnValidate()
            begin
                HRLeaveApp.Reset();
                if HRLeaveApp.Get("Leave Application No") then begin
                    "Leave Type" := HRLeaveApp."Leave Type";
                    "Start Date" := HRLeaveApp."Start Date";
                    "Return Date" := HRLeaveApp."Return Date";
                    "Days Applied" := HRLeaveApp."Days Applied";
                end else begin
                    "Leave Type" := '';
                    "Start Date" := 0D;
                    "Return Date" := 0D;
                    "Days Applied" := 0;
                end;
            end;
        }
        field(3971; "Days to Reimburse"; Decimal)
        {
            Caption = 'Days to Reimburse';
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
        //GENERATE NEW NUMBER FOR THE DOCUMENT
        if "Application Code" = '' then begin
            HRSetup.Get();
            HRSetup.TestField(HRSetup."Leave Reimbursment Nos.");
            NoSeriesMgt.InitSeries(HRSetup."Leave Reimbursment Nos.", xRec."No series", 0D, "Application Code", "No series");
        end;

        //GET APPLICANT DETAILS FROM HR EMPLOYEES TABLE AND COPY THEM TO THE LEAVE APPLICATION TABLE
        HREmp.Reset();
        HREmp.SetRange(HREmp."User ID", UserId);
        if HREmp.Find('-') then begin
            "Employee No" := HREmp."No.";
            "Job Tittle" := HREmp."Job Title";
            "User ID" := UserId;
        end else
            Error('User id' + ' ' + '[' + UserId + ']' + ' has not been assigned to any employee. Please consult the HR officer for assistance');

        //POPULATE FIELDS
        "Application Date" := Today;
    end;

    var
        HRSetup: Record "HR Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        HREmp: Record Employee;
        TEXT001: Label 'Days Approved cannot be more than applied days';
        HRLeaveApp: Record "HR Leave Application";
        HRLeavePeriods: Record "HR Leave Periods";
        HRJournalLine: Record "HR Leave Journal Line";
        HRJournalBatch: Record "HR Leave Journal Batch";
        "LineNo.": Integer;


    procedure DetermineLeaveReturnDate(var fBeginDate: Date; var fDays: Decimal) fReturnDate: Date
    begin
    end;


    procedure DetermineIfIncludesNonWorking(var fLeaveCode: Code[10]): Boolean
    begin
    end;


    procedure DetermineIfIsNonWorking(var bcDate: Date) Isnonworking: Boolean
    begin
    end;


    procedure DeterminethisLeaveEndDate(var fDate: Date) fEndDate: Date
    begin
    end;


    procedure CreateLeaveLedgerEntries()
    begin

        //GET OPEN LEAVE PERIOD
        HRLeavePeriods.Reset();
        HRLeavePeriods.SetRange(HRLeavePeriods.Closed, false);
        HRLeavePeriods.Find('-');

        HRJournalBatch.Reset();
        HRSetup.Get();
        HRJournalBatch.Get(HRSetup."Default Leave Posting Template", HRSetup."Positive Leave Posting Batch");

        //POPULATE JOURNAL LINES
        HRJournalLine.Reset();
        HRJournalLine.SetRange(HRJournalLine."Journal Template Name", HRSetup."Default Leave Posting Template");
        HRJournalLine.SetRange(HRJournalLine."Journal Batch Name", HRSetup."Negative Leave Posting Batch");
        if not HRJournalLine.Find('-') then
            HRJournalLine."Line No." := 1000
        else
            HRJournalLine.DeleteAll();
        HRJournalLine."Line No." := HRJournalLine."Line No." + 1000;

        "LineNo." := HRJournalLine."Line No.";

        HRJournalLine.Init();
        HRJournalLine."Journal Template Name" := HRSetup."Default Leave Posting Template";
        HRJournalLine."Journal Batch Name" := HRSetup."Positive Leave Posting Batch";
        HRJournalLine."Line No." := "LineNo.";
        HRJournalLine."Leave Period" := HRLeavePeriods."Period Code";
        HRJournalLine."Document No." := "Application Code";
        HRJournalLine."Staff No." := "Employee No";
        HRJournalLine.Validate(HRJournalLine."Staff No.");
        HRJournalLine."Posting Date" := Today;
        HRJournalLine."Leave Entry Type" := HRJournalLine."Leave Entry Type"::Positive;
        HRJournalLine."Leave Approval Date" := Today;
        HRJournalLine.Description := 'Reimbursement for Leave Application: ' + "Leave Application No";
        HRJournalLine."Leave Type" := "Leave Type";
        HRJournalLine."Leave Period Start Date" := "Start Date";
        HRJournalLine."Leave Period End Date" := "End Date";
        HRJournalLine."No. of Days" := "Days to Reimburse";

        //Mark document as posted
        Posted := true;
        "Posted By" := UserId;
        "Date Posted" := Today;
        "Time Posted" := Time;

        HRJournalLine.Insert(true);

        //Post Journal
        HRJournalLine.Reset();
        HRJournalLine.SetRange("Journal Template Name", HRSetup."Default Leave Posting Template");
        HRJournalLine.SetRange("Journal Batch Name", HRSetup."Positive Leave Posting Batch");
        if HRJournalLine.Find('-') then
            Codeunit.Run(Codeunit::"HR Leave Jnl Management", HRJournalLine);
        //Notify Leave Applicant
        //NotifyApplicant;
    end;


    procedure NotifyApplicant()
    begin
    end;
}
