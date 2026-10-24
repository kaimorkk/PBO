table 52193478 "Perf Report Buffer"
{
    Caption = 'Performance Report Buffer';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Employee No."; Code[20]) { Caption = 'Employee No.'; TableRelation = Employee."No."; }
        field(3; "Employee Name"; Text[100]) { Caption = 'Employee Name'; }
        field(4; Designation; Text[100]) { Caption = 'Designation'; }
        field(5; Department; Text[100]) { Caption = 'Department'; }
        field(6; Directorate; Text[100]) { Caption = 'Directorate'; }
        field(7; Region; Text[100]) { Caption = 'Region'; }
        field(8; "Period Code"; Code[20]) { Caption = 'Period Code'; }
        field(9; "Text Value 1"; Text[250]) { Caption = 'Text Value 1'; }
        field(10; "Text Value 2"; Text[250]) { Caption = 'Text Value 2'; }
        field(11; "Decimal Value 1"; Decimal) { Caption = 'Decimal Value 1'; }
        field(12; "Decimal Value 2"; Decimal) { Caption = 'Decimal Value 2'; }
        field(13; "Boolean Value 1"; Boolean) { Caption = 'Boolean Value 1'; }
        field(14; "Date Value 1"; Date) { Caption = 'Date Value 1'; }
        field(15; Grade; Code[20]) { Caption = 'Grade'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
