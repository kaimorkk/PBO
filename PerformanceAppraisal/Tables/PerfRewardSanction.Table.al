table 52193481 "Perf Reward Sanction"
{
    Caption = 'Reward / Sanction Proposal';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Reward Sanction List St.";
    DrillDownPageId = "Perf Reward Sanction List St.";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Review No."; Code[20])
        {
            Caption = 'Review No.';
            TableRelation = "Perf Review Header"."No.";
        }
        field(3; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee."No.";
        }
        field(4; Type; Enum "Perf Reward Sanction Type")
        {
            Caption = 'Type';
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(6; "Proposed by (Supervisor)"; Code[20])
        {
            Caption = 'Proposed by (Supervisor)';
            TableRelation = Employee."No.";
        }
        field(7; "Proposed Date"; Date)
        {
            Caption = 'Proposed Date';
        }
        field(8; "HRAC Status"; Enum "Perf HRAC Status")
        {
            Caption = 'HR Appraisal Committee Status';
        }
        field(9; "HRAC Comments"; Text[250])
        {
            Caption = 'HRAC Comments';
        }
        field(10; "Recommended To"; Text[100])
        {
            Caption = 'Recommended to Authority';
        }
        field(11; "Final Decision By"; Code[50])
        {
            Caption = 'Final Decision By';
            Editable = false;
        }
        field(12; "Decision Date"; Date)
        {
            Caption = 'Decision Date';
            Editable = false;
        }
        field(13; "Letter Generated"; Boolean)
        {
            Caption = 'Standard Letter Generated';
            Editable = false;
        }
        field(14; "Auto-Generated"; Boolean)
        {
            Caption = 'Generated from Score Threshold';
            Editable = false;
        }
        field(15; "Final Decision"; Text[250])
        {
            Caption = 'Final Decision (Appropriate Authority)';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Employee No.", Type) { }
        key(Key3; "Review No.", Type) { }
    }

    trigger OnInsert()
    var
        ReviewHeader: Record "Perf Review Header";
    begin
        // FRD 3.ix: proposals are raised by the supervisor against a completed review.
        if ReviewHeader.Get("Review No.") then begin
            if "Employee No." = '' then
                "Employee No." := ReviewHeader."Employee No.";
            if "Proposed by (Supervisor)" = '' then
                "Proposed by (Supervisor)" := ReviewHeader."Supervisor No.";
        end;
        if "Proposed Date" = 0D then
            "Proposed Date" := Today;
    end;
}
