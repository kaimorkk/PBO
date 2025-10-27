table 50143 "PBO Task Setup"
{
    Caption = 'PBO Task Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            AutoIncrement = true;
        }
        field(2; "Document Typ"; Text[200])
        {
            Caption = 'Document Typ';
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }
}
