 
   table 50124 "Unit Sub Type"
{

    fields
    {
        field(1; "Unit Type"; Code[20])
        {
        }
        field(2; "Code"; Code[20])
        {
        }
        field(3; Description; Text[100])
        {
        }
    }

    keys
    {
        key(Key1; "Unit Type", "Code", Description)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

