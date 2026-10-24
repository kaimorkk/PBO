table 52193471 "Sector /Tags"
{
    Caption = 'Sector /Tags';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry no"; Integer)
        {
            Caption = 'Entry no';
            AutoIncrement = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(PK; "Entry no")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
        // if "Entry no" = 0 then begin
        //     rec.Reset();
        //     if rec.FindLast() then
        //         "Entry no" := rec."Entry no" + 1;
        // end;

    end;

}
