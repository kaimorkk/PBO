table 52193484 "Perf AI Goal Suggestion"
{
    Caption = 'AI Suggested Target';
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; Select; Boolean)
        {
            Caption = 'Select';
            InitValue = true;
        }
        field(3; "Workplan Line No."; Integer)
        {
            Caption = 'Cascaded from Workplan Line No.';
        }
        field(4; "Key Result Area"; Text[250])
        {
            Caption = 'Key Result Area (KRA)';
        }
        field(5; "Target Description"; Text[250])
        {
            Caption = 'Target / Goal Description';
        }
        field(6; "Measurement Criteria"; Text[250])
        {
            Caption = 'Measurement Criteria';
        }
        field(7; "Target Value"; Decimal)
        {
            Caption = 'Target Value';
        }
        field(8; "Weightage %"; Decimal)
        {
            Caption = 'Weightage %';
            MinValue = 0;
            MaxValue = 100;
        }
        field(9; Rationale; Text[250])
        {
            Caption = 'Why this target';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
