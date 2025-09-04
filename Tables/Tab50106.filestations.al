table 50106 "Task Stations"
{
    DrillDownPageID = "Task Stations";
    LookupPageID = "Task Stations";

    fields
    {
        field(1; "Station No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Station Code"; Code[50])
        {
        }
        field(4; "Duration (Hr)"; Decimal)
        {
        }
        field(5; "Responsibility Centre"; Code[20])
        {
            TableRelation = "Responsibility Center";

        }
        field(6; "Dest. Responsibility Centre"; Code[20])
        {
            TableRelation = "Responsibility Center";

        }
    }

    keys
    {
        key(Key1; "Station No.", "Station Code", Description)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

