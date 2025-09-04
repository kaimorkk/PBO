 
    
   table 50123 "Unit Type"
{
    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; Description; Text[100])
        {
        }
        field(3; "Sub Types"; Integer)
        {
            CalcFormula = Count("Unit Sub Type" WHERE("Unit Type" = FIELD(Code)));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

