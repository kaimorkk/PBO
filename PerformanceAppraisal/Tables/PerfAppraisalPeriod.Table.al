table 52193472 "Perf Appraisal Period"
{
    Caption = 'Appraisal Period';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Appraisal Period List";
    DrillDownPageId = "Perf Appraisal Period List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Period Type"; Enum "Perf Period Type")
        {
            Caption = 'Period Type';
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(6; "Target Setting Deadline"; Date)
        {
            Caption = 'Target Setting Deadline';
        }
        field(7; "Self-Assessment Deadline"; Date)
        {
            Caption = 'Self-Assessment Deadline';
        }
        field(8; "Supervisor Review Deadline"; Date)
        {
            Caption = 'Supervisor Review Deadline';
        }
        field(9; Closed; Boolean)
        {
            Caption = 'Closed';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
