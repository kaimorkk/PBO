 
    table 50122 "Floor Codes"
{
    DrillDownPageID = "Floor Codes";
    LookupPageID = "Floor Codes";

    fields
    {
        field(1; "Floor Code"; Code[10])
        {
        }
        field(2; Description; Text[30])
        {
        }
        field(3; Land; Boolean)
        {
            Description = 'check if option is land';
        }
    }

    keys
    {
        key(Key1; "Floor Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

