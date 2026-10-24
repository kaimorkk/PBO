table 52193480 "Perf Review Line"
{
    Caption = 'Performance Review Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Review No."; Code[20])
        {
            Caption = 'Review No.';
            TableRelation = "Perf Review Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Goal Line No."; Integer)
        {
            Caption = 'Source Goal Line No.';
            Editable = false;
        }
        field(4; "Key Result Area"; Text[250])
        {
            Caption = 'Key Result Area (KRA)';
            Editable = false;
        }
        field(5; "Target Description"; Text[250])
        {
            Caption = 'Target Description';
            Editable = false;
        }
        field(6; "Weightage %"; Decimal)
        {
            Caption = 'Weightage %';
            Editable = false;
        }
        field(7; "Self Rating"; Decimal)
        {
            Caption = 'Self Rating (1-5)';
            MinValue = 0;
            MaxValue = 5;
        }
        field(8; "Supervisor Rating"; Decimal)
        {
            Caption = 'Supervisor Rating (1-5)';
            MinValue = 0;
            MaxValue = 5;
        }
        field(9; "Final Score"; Decimal)
        {
            Caption = 'Weighted Final Score';
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(10; "Employee Comments"; Text[250])
        {
            Caption = 'Employee Comments';
        }
        field(11; "Supervisor Comments"; Text[250])
        {
            Caption = 'Supervisor Comments';
        }
        field(12; "Target Value"; Decimal)
        {
            Caption = 'Target Value';
            Editable = false;
        }
        field(13; "Actual Achievement"; Decimal)
        {
            Caption = 'Actual Achievement';

            trigger OnValidate()
            var
                ScoreCalc: Codeunit "Perf Score Calculation";
                SuggestedRating: Decimal;
            begin
                // FRD 3 NB: KPI results are calculated against predefined rules (Perf Rating Scale).
                if "Target Value" <> 0 then
                    "Achievement %" := Round("Actual Achievement" / "Target Value" * 100, 0.01)
                else
                    "Achievement %" := 0;
                SuggestedRating := ScoreCalc.GetRatingForAchievement("Achievement %");
                if SuggestedRating <> 0 then
                    "Self Rating" := SuggestedRating;
            end;
        }
        field(14; "Achievement %"; Decimal)
        {
            Caption = 'Achievement %';
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(15; "Measurement Criteria"; Text[250])
        {
            Caption = 'Measurement Criteria';
            Editable = false;
        }
        field(16; "Training Need"; Text[250])
        {
            Caption = 'Training Need Identified';
        }
    }

    keys
    {
        key(PK; "Review No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ReviewLine: Record "Perf Review Line";
    begin
        if "Line No." = 0 then begin
            ReviewLine.SetRange("Review No.", "Review No.");
            if ReviewLine.FindLast() then
                "Line No." := ReviewLine."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;
}
