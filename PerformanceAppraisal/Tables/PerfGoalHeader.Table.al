table 52193475 "Perf Goal Header"
{
    Caption = 'Individual Performance Goal';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Goal Header List";
    DrillDownPageId = "Perf Goal Header List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee."No.";
            NotBlank = true;

            trigger OnValidate()
            var
                Employee: Record Employee;
            begin
                TestStatusOpen();
                if Employee.Get("Employee No.") then begin
                    "Employee Name" := Employee.FullName();
                    "Supervisor No." := Employee."Perf Supervisor No."; // extension field on Employee, see PageExtensions
                    "Directorate Code" := Employee."Perf Directorate Code";
                    "Department Code" := Employee."Global Dimension 1 Code";
                end;
                CheckDuplicate();
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            Caption = 'Employee Name';
            Editable = false;
        }
        field(4; "Supervisor No."; Code[20])
        {
            Caption = 'Supervisor (HOD) No.';
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(5; "Workplan No."; Code[20])
        {
            Caption = 'Corporate Workplan No.';
            TableRelation = "Perf Corporate Workplan"."No.";

            trigger OnValidate()
            var
                Workplan: Record "Perf Corporate Workplan";
            begin
                TestStatusOpen();
                if "Workplan No." = '' then
                    exit;
                // FRD 2.v: individual targets cascade from the approved workplan, which carries
                // the Performance Contract and Strategic Plan the targets must be linked to.
                Workplan.Get("Workplan No.");
                CheckWorkplanReady(Workplan);
                "Performance Contract Ref." := Workplan."Performance Contract Ref.";
                "Strategic Plan Reference" := Workplan."Strategic Plan Reference";
            end;
        }
        field(6; "Performance Contract Ref."; Code[20])
        {
            Caption = 'Performance Contract (PC) Ref.';
        }
        field(7; "Strategic Plan Reference"; Code[20])
        {
            Caption = 'Strategic Plan Reference';
        }
        field(8; "Period Code"; Code[20])
        {
            Caption = 'Appraisal Period Code';
            TableRelation = "Perf Appraisal Period".Code where(Closed = const(false));

            trigger OnValidate()
            var
                Period: Record "Perf Appraisal Period";
            begin
                TestStatusOpen();
                if Period.Get("Period Code") then begin
                    Period.TestField(Closed, false);
                    "Start Date" := Period."Start Date";
                    "End Date" := Period."End Date";
                end;
                CheckDuplicate();
            end;
        }
        field(9; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(10; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(11; Status; Enum "Perf Goal Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(12; "HOD Comments"; Text[250])
        {
            Caption = 'HOD Comments (if returned)';
        }
        field(13; "Staff Signed"; Boolean)
        {
            Caption = 'Staff Signed';
            Editable = false;
        }
        field(14; "Staff Signature Date"; Date)
        {
            Caption = 'Staff Signature Date';
            Editable = false;
        }
        field(15; "Supervisor Signed"; Boolean)
        {
            Caption = 'Supervisor (HOD) Signed';
            Editable = false;
        }
        field(16; "Supervisor Signature Date"; Date)
        {
            Caption = 'Supervisor Signature Date';
            Editable = false;
        }
        field(17; "CEO Approval Date"; Date)
        {
            Caption = 'CEO Approval Date';
            Editable = false;
        }
        field(18; "Total Weightage %"; Decimal)
        {
            Caption = 'Total Weightage %';
            FieldClass = FlowField;
            CalcFormula = sum("Perf Goal Line"."Weightage %" where("Goal No." = field("No.")));
            Editable = false;
        }
        field(19; "No. of Goal Lines"; Integer)
        {
            Caption = 'No. of Goal Lines';
            FieldClass = FlowField;
            CalcFormula = count("Perf Goal Line" where("Goal No." = field("No.")));
            Editable = false;
        }
        field(20; Level; Enum "Perf Goal Level")
        {
            Caption = 'Level';

            trigger OnValidate()
            var
                Workplan: Record "Perf Corporate Workplan";
            begin
                TestStatusOpen();
                if Level = xRec.Level then
                    exit;
                if HasLines() then
                    Error(LevelChangeWithLinesErr, FieldCaption(Level), "No.");
                if Workplan.Get("Workplan No.") then
                    CheckWorkplanReady(Workplan);
            end;
        }
        field(21; "Directorate Code"; Code[20])
        {
            Caption = 'Directorate Code';

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(22; "Department Code"; Code[20])
        {
            Caption = 'Department Code';

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
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
    }

    trigger OnInsert()
    var
        PerfSetup: Record "Perf Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            PerfSetup.Get();
            PerfSetup.TestField("Goal No. Series");
            "No." := NoSeries.GetNextNo(PerfSetup."Goal No. Series", WorkDate());
        end;
    end;

    trigger OnDelete()
    var
        GoalLine: Record "Perf Goal Line";
    begin
        TestStatusOpen();
        GoalLine.SetRange("Goal No.", "No.");
        GoalLine.DeleteAll();
    end;

    /// <summary>
    /// Targets can only be changed by staff while drafting or after the HOD returned them.
    /// </summary>
    procedure TestStatusOpen()
    begin
        if not IsEditable() then
            Error(NotEditableErr, "No.", Status);
    end;

    procedure IsEditable(): Boolean
    begin
        exit(Status in [Status::Open, Status::"Returned for Amendment"]);
    end;

    /// <summary>
    /// Directorate goals need the workplan cascaded to Directorates; Department goals need it
    /// cascaded to Departments.
    /// </summary>
    procedure CheckWorkplanReady(Workplan: Record "Perf Corporate Workplan")
    begin
        if Workplan.IsReadyForTargetSetting(Level) then
            exit;
        if Level = Level::Directorate then
            Error(WorkplanNotCascadedDirErr, Workplan."No.");
        Error(WorkplanNotCascadedErr, Workplan."No.");
    end;

    local procedure HasLines(): Boolean
    var
        GoalLine: Record "Perf Goal Line";
    begin
        GoalLine.SetRange("Goal No.", "No.");
        exit(not GoalLine.IsEmpty());
    end;

    local procedure CheckDuplicate()
    var
        GoalHeader: Record "Perf Goal Header";
    begin
        if ("Employee No." = '') or ("Period Code" = '') then
            exit;
        GoalHeader.SetRange("Employee No.", "Employee No.");
        GoalHeader.SetRange("Period Code", "Period Code");
        GoalHeader.SetFilter("No.", '<>%1', "No.");
        if GoalHeader.FindFirst() then
            Error(DuplicateErr, "Employee No.", "Period Code", GoalHeader."No.");
    end;

    var
        NotEditableErr: Label 'Targets %1 cannot be changed while the status is %2.', Comment = '%1 = goal no., %2 = status';
        WorkplanNotCascadedErr: Label 'Workplan %1 has not yet been approved by the CEO and cascaded to Departments.', Comment = '%1 = workplan no.';
        WorkplanNotCascadedDirErr: Label 'Workplan %1 has not yet been approved by the CEO and cascaded to Directorates.', Comment = '%1 = workplan no.';
        LevelChangeWithLinesErr: Label 'You cannot change %1 on %2 while it has target lines. Delete the lines first.', Comment = '%1 = field caption, %2 = goal no.';
        DuplicateErr: Label 'Employee %1 already has targets for period %2 (%3).', Comment = '%1 = employee no., %2 = period, %3 = goal no.';
}
