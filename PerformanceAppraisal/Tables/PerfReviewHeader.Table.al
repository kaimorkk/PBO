table 52193479 "Perf Review Header"
{
    Caption = 'Performance Review';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Review Header List";
    DrillDownPageId = "Perf Review Header List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Goal No."; Code[20])
        {
            Caption = 'Related Goal No.';
            TableRelation = "Perf Goal Header"."No." where(Status = const(Finalized));

            trigger OnValidate()
            var
                GoalHeader: Record "Perf Goal Header";
                EmployeeMgt: Codeunit "Perf Employee Mgt";
            begin
                TestField(Status, Status::Open);
                if GoalHeader.Get("Goal No.") then begin
                    // FRD 3.i: self-assessment is based on the approved performance targets.
                    GoalHeader.TestField(Status, GoalHeader.Status::Finalized);
                    "Employee No." := GoalHeader."Employee No.";
                    "Supervisor No." := GoalHeader."Supervisor No.";
                    "Next Level Supervisor No." := EmployeeMgt.GetSupervisorOf("Supervisor No.");
                    CheckDuplicate();
                    if "No." <> '' then
                        CreateLinesFromGoal();
                end;
            end;
        }
        field(3; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee."No.";
            Editable = false;
        }
        field(4; "Supervisor No."; Code[20])
        {
            Caption = 'Supervisor No.';
            TableRelation = Employee."No.";
        }
        field(5; "Next Level Supervisor No."; Code[20])
        {
            Caption = 'Next Level Supervisor No.';
            TableRelation = Employee."No.";
        }
        field(6; "Period Code"; Code[20])
        {
            Caption = 'Appraisal Period Code';
            TableRelation = "Perf Appraisal Period".Code where(Closed = const(false));

            trigger OnValidate()
            var
                Period: Record "Perf Appraisal Period";
            begin
                TestField(Status, Status::Open);
                if Period.Get("Period Code") then begin
                    Period.TestField(Closed, false);
                    "Period Type" := Period."Period Type";
                    "Review Start Date" := Period."Start Date";
                    "Review End Date" := Period."End Date";
                end;
                CheckDuplicate();
            end;
        }
        field(7; "Period Type"; Enum "Perf Period Type")
        {
            Caption = 'Period Type';
        }
        field(8; "Review Start Date"; Date)
        {
            Caption = 'Review Start Date';
        }
        field(9; "Review End Date"; Date)
        {
            Caption = 'Review End Date';
        }
        field(10; Status; Enum "Perf Review Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(11; "Self Assessment Date"; Date)
        {
            Caption = 'Self-Assessment Date';
            Editable = false;
        }
        field(12; "Supervisor Review Date"; Date)
        {
            Caption = 'Supervisor Review Date';
            Editable = false;
        }
        field(13; "Employee Objection"; Boolean)
        {
            Caption = 'Objected by Employee';
            Editable = false;
        }
        field(14; "Objection Comments"; Text[250])
        {
            Caption = 'Objection Comments';
        }
        field(15; "Overall Score"; Decimal)
        {
            Caption = 'Overall Performance Score';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(16; "HR Consolidation Date"; Date)
        {
            Caption = 'HR Consolidation Date';
            Editable = false;
        }
        field(17; "Submitted to GM HR&A"; Boolean)
        {
            Caption = 'Submitted to GM HR & Administration';
            Editable = false;
        }
        field(18; "Submitted to HRAC Date"; Date)
        {
            Caption = 'Submitted to HR Appraisal Committee Date';
            Editable = false;
        }
        field(19; "HRAC Recommendation"; Text[250])
        {
            Caption = 'HRAC Recommendation';
        }
        field(20; "Submitted to ED"; Boolean)
        {
            Caption = 'Committee Recommendation Submitted to ED';
            Editable = false;
        }
        field(21; "Rating Category"; Text[50])
        {
            Caption = 'Rating Category';
            Editable = false;
        }
        field(22; "Self Assessment Score"; Decimal)
        {
            Caption = 'Self-Assessment Score';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(23; "Supervisor Return Comments"; Text[250])
        {
            Caption = 'Supervisor Comments (if returned)';
        }
        field(24; "Escalation Resolution"; Text[250])
        {
            Caption = 'Objection Resolution Comments';
        }
        field(25; "Next Level Approval Date"; Date)
        {
            Caption = 'Next Level Supervisor Approval Date';
            Editable = false;
        }
        field(26; "Submitted to GM HR&A Date"; Date)
        {
            Caption = 'Submitted to GM HR & A Date';
            Editable = false;
        }
        field(27; "AI Feedback Draft"; Text[2048])
        {
            Caption = 'AI Draft Appraisal Feedback';
            // Drafted by Perf AI Mgt for the supervisor to edit; it is never submitted automatically.
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Employee No.", "Period Code") { }
        key(Key3; "Supervisor No.", Status) { }
        key(Key4; Status) { }
    }

    trigger OnInsert()
    var
        PerfSetup: Record "Perf Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            PerfSetup.Get();
            PerfSetup.TestField("Review No. Series");
            "No." := NoSeries.GetNextNo(PerfSetup."Review No. Series", WorkDate());
        end;
    end;

    trigger OnDelete()
    var
        ReviewLine: Record "Perf Review Line";
    begin
        TestField(Status, Status::Open);
        ReviewLine.SetRange("Review No.", "No.");
        ReviewLine.DeleteAll();
    end;

    /// <summary>
    /// Copies the CEO-approved Key Result Areas and targets into review lines.
    /// </summary>
    procedure CreateLinesFromGoal()
    var
        GoalLine: Record "Perf Goal Line";
        ReviewLine: Record "Perf Review Line";
    begin
        TestField(Status, Status::Open);
        TestField("Goal No.");
        ReviewLine.SetRange("Review No.", "No.");
        ReviewLine.DeleteAll();

        GoalLine.SetRange("Goal No.", "Goal No.");
        if GoalLine.FindSet() then
            repeat
                ReviewLine.Init();
                ReviewLine."Review No." := "No.";
                ReviewLine."Line No." := GoalLine."Line No.";
                ReviewLine."Goal Line No." := GoalLine."Line No.";
                ReviewLine."Key Result Area" := GoalLine."Key Result Area";
                ReviewLine."Target Description" := GoalLine."Target Description";
                ReviewLine."Measurement Criteria" := GoalLine."Measurement Criteria";
                ReviewLine."Weightage %" := GoalLine."Weightage %";
                ReviewLine."Target Value" := GoalLine."Target Value";
                ReviewLine.Insert();
            until GoalLine.Next() = 0;
    end;

    local procedure CheckDuplicate()
    var
        ReviewHeader: Record "Perf Review Header";
    begin
        if ("Employee No." = '') or ("Period Code" = '') then
            exit;
        ReviewHeader.SetRange("Employee No.", "Employee No.");
        ReviewHeader.SetRange("Period Code", "Period Code");
        ReviewHeader.SetFilter("No.", '<>%1', "No.");
        if ReviewHeader.FindFirst() then
            Error(DuplicateErr, "Employee No.", "Period Code", ReviewHeader."No.");
    end;

    var
        DuplicateErr: Label 'Employee %1 already has a performance review for period %2 (%3).', Comment = '%1 = employee no., %2 = period, %3 = review no.';
}
