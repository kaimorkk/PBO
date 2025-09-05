 
    
table 50130 "HR Calendar List"
{
    DrillDownPageId = "HR Calendar Lines";
    LookupPageId = "HR Calendar Lines";
    Caption = 'HR Calendar List';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Day; Text[40])
        {
            Editable = false;
            Caption = 'Day';
        }
        field(3; Date; Date)
        {
            Caption = 'Date';
        }
        field(4; "Non Working"; Boolean)
        {
            Caption = 'Non Working';
        }
        field(5; Reason; Text[40])
        {
            Caption = 'Reason';
        }
    }

    keys
    {
        key(Key1; Date, "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups { }
}
