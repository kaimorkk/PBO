 
   table 50121 "Batch Lines Table"
{
    Caption = 'Batch Lines Table';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Batch No."; Code[100])
        {
            Caption = 'Batch No.';
        }
        field(2; "File No."; Code[100])
        {
            Caption = 'File No.';
        }
        field(3; "Date Batched"; Date)
        {
            Caption = 'Date Batched';
        }
        field(4; "Folio No."; Code[100])
        {
            Caption = 'Folio No.';
        }
        field(5; "Volume No."; Code[100])
        {
            Caption = 'Volume No.';
        }
        field(6; "Member No."; Code[100])
        {
            Caption = 'Member No.';
        }
        field(7; "Member Name"; Text[100])
        {
            Caption = 'Member Name';
        }
        field(8; "Staff PF No."; Code[100])
        {
            Caption = 'Staff PF No.';
        }
        field(9; Archived; Boolean)
        {
            Caption = 'Archived';
        }
        field(10; "Header No."; Code[100])
        {
            Caption = 'Header No.';
        }
        field(11; "Date Archived"; Date)
        {
            Caption = 'Date Archived';
        }
        field(12; "Archived By"; Code[100])
        {
            Caption = 'Archived By';
        }
    }
    keys
    {
        key(PK; "Header No.", "Batch No.", "Volume No.")
        {
            Clustered = true;
        }
    }
}
