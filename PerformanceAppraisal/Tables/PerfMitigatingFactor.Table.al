table 52193477 "Perf Mitigating Factor"
{
    Caption = 'Mitigating Factor';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Migating Factor List St.";
    DrillDownPageId = "Perf Migating Factor List St.";

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
        field(4; "Factor Type"; Enum "Perf Mitigating Factor Type")
        {
            Caption = 'Factor Type';
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description of Non-Performance Factor';
        }
        field(6; "Corrective Action"; Text[250])
        {
            Caption = 'Corrective Action / Support Plan';
        }
        field(7; "Recorded By"; Code[50])
        {
            Caption = 'Recorded By';
            Editable = false;
        }
        field(8; "Recorded Date"; Date)
        {
            Caption = 'Recorded Date';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Employee No.") { }
    }

    trigger OnInsert()
    var
        ReviewHeader: Record "Perf Review Header";
    begin
        if ("Employee No." = '') and ReviewHeader.Get("Review No.") then
            "Employee No." := ReviewHeader."Employee No.";
        "Recorded By" := CopyStr(UserId(), 1, MaxStrLen("Recorded By"));
        "Recorded Date" := Today;
    end;
}
