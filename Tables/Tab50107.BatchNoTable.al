 
  
   table 50107 "Batch No Table"
{
    Caption = 'Batch No Table';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Batch No List";
    LookupPageId = "Batch No List";

    fields
    {
        field(1; "Batch"; Code[100])
        {
        }
        field(2; "Batch Sequence"; CODE[50])
        {
            Caption = 'Batch Sequence';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                Rec."Batch Number" := Rec."Batch" + Rec."Batch Sequence";
            end;
        }
        field(3; "Batch Number"; Code[100])
        {
            Caption = 'Batch Number';
        }
        field(4; "Batch Entry No."; Integer)
        {
            Caption = 'Batch Entry No.';
            AutoIncrement = true;
        }
    }
    keys
    {
        // key(PK; "Batch Entry No.", "Batch Number")
        key(PK; "Batch Entry No.")
        //key(PK; "Batch Number")
        //key(PK; "Batch Entry No.", "Batch Number", "Batch", "Batch Sequence")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdown; "Batch Entry No.", "Batch Number")
        {
        }
    }
}
