table 52193476 "Perf Goal Line"
{
    Caption = 'Individual Performance Goal Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Goal No."; Code[20])
        {
            Caption = 'Goal No.';
            TableRelation = "Perf Goal Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Key Result Area"; Text[250])
        {
            Caption = 'Key Result Area (KRA)';
        }
        field(4; "Target Description"; Text[250])
        {
            Caption = 'Target / Goal Description';
        }
        field(5; "Measurement Criteria"; Text[250])
        {
            Caption = 'Measurement Criteria';
        }
        field(6; "Weightage %"; Decimal)
        {
            Caption = 'Weightage %';
            MinValue = 0;
            MaxValue = 100;
        }
        field(7; "Workplan No."; Code[20])
        {
            Caption = 'Cascaded from Workplan No.';
            TableRelation = "Perf Corporate Workplan"."No.";
            Editable = false;
        }
        field(8; "Workplan Line No."; Integer)
        {
            Caption = 'Cascaded from Workplan Line No.';
            TableRelation = "Perf Corporate Workplan Line"."Line No." where("Workplan No." = field("Workplan No."));

            trigger OnValidate()
            var
                WorkplanLine: Record "Perf Corporate Workplan Line";
            begin
                if "Workplan Line No." = 0 then
                    exit;
                if "Workplan No." = '' then
                    InitFromHeader();
                WorkplanLine.Get("Workplan No.", "Workplan Line No.");
                CheckObjectiveCascadedToLevel(WorkplanLine);
                // Prefill from the cascaded objective/KPI; staff refine the wording afterwards.
                if "Key Result Area" = '' then
                    "Key Result Area" := WorkplanLine."Objective Description";
                if "Measurement Criteria" = '' then
                    "Measurement Criteria" := WorkplanLine."KPI Description";
                if "Target Value" = 0 then
                    "Target Value" := WorkplanLine."Target Value";
            end;
        }
        field(9; "Target Value"; Decimal)
        {
            Caption = 'Target Value';
        }
    }

    keys
    {
        key(PK; "Goal No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        GoalLine: Record "Perf Goal Line";
    begin
        TestHeaderOpen();
        if "Line No." = 0 then begin
            GoalLine.SetRange("Goal No.", "Goal No.");
            if GoalLine.FindLast() then
                "Line No." := GoalLine."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;

    trigger OnModify()
    begin
        TestHeaderOpen();
    end;

    trigger OnDelete()
    begin
        TestHeaderOpen();
    end;

    /// <summary>
    /// Called from the subform on a new line so the workplan objective lookup is filtered
    /// to the header's workplan before the line is saved.
    /// </summary>
    procedure InitFromHeader()
    var
        GoalHeader: Record "Perf Goal Header";
    begin
        if GoalHeader.Get("Goal No.") then
            "Workplan No." := GoalHeader."Workplan No.";
    end;

    local procedure CheckObjectiveCascadedToLevel(WorkplanLine: Record "Perf Corporate Workplan Line")
    var
        GoalHeader: Record "Perf Goal Header";
    begin
        if not GoalHeader.Get("Goal No.") then
            exit;
        case GoalHeader.Level of
            GoalHeader.Level::Directorate:
                if not WorkplanLine."Cascaded to Directorate" then
                    Error(NotCascadedErr, WorkplanLine."Objective Description", GoalHeader.Level);
            else
                if not WorkplanLine."Cascaded to Dept." then
                    Error(NotCascadedErr, WorkplanLine."Objective Description", GoalHeader.Level);
        end;
    end;

    local procedure TestHeaderOpen()
    var
        GoalHeader: Record "Perf Goal Header";
    begin
        if not GoalHeader.Get("Goal No.") then
            exit;
        GoalHeader.TestStatusOpen();
        "Workplan No." := GoalHeader."Workplan No.";
    end;

    var
        NotCascadedErr: Label 'Objective "%1" has not been cascaded to %2 level.', Comment = '%1 = objective, %2 = goal level';
}
