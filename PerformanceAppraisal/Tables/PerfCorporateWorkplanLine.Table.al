table 52193474 "Perf Corporate Workplan Line"
{
    Caption = 'Corporate Annual Workplan Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Workplan No."; Code[20])
        {
            Caption = 'Workplan No.';
            TableRelation = "Perf Corporate Workplan"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Objective Description"; Text[250])
        {
            Caption = 'Strategic Objective';
        }
        field(4; "KPI Description"; Text[250])
        {
            Caption = 'Key Performance Indicator';
        }
        field(5; "Target Value"; Decimal)
        {
            Caption = 'Target Value';
        }
        field(6; "Weightage %"; Decimal)
        {
            Caption = 'Weightage %';
            MinValue = 0;
            MaxValue = 100;
        }
        field(7; "Responsible Directorate"; Code[20])
        {
            Caption = 'Responsible Directorate';
        }
        field(8; "Responsible Department"; Code[20])
        {
            Caption = 'Responsible Department';
            // TableRelation = "Human Resources Unit".Code;
        }
        field(9; "Cascaded to Dept."; Boolean)
        {
            Caption = 'Cascaded to Department';
            Editable = false;
        }
        field(10; "Strategic Initiative"; Text[250])
        {
            Caption = 'Strategic Initiative';
        }
        field(11; "Cascaded to Directorate"; Boolean)
        {
            Caption = 'Cascaded to Directorate';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Workplan No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        TestWorkplanOpen();
    end;

    trigger OnModify()
    begin
        TestWorkplanOpen();
    end;

    trigger OnDelete()
    begin
        TestWorkplanOpen();
    end;

    local procedure TestWorkplanOpen()
    var
        Workplan: Record "Perf Corporate Workplan";
    begin
        // Cascade flags are set via ModifyAll without triggers, so this only guards user edits.
        if Workplan.Get("Workplan No.") then
            Workplan.TestField(Status, Workplan.Status::Open);
    end;
}
