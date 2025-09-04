 
   table 50112 "Task Movement Remarks"
{
    LookupPageID = "Task MVT Remarks";
    DrillDownPageId = "Task MVT Remarks";

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; Description; CODE[50])
        {
        }
        field(3; Stage; option)
        {
            OptionMembers = "File Location",Archives;
        }
        field(4; "Responsibility Centre"; Code[20])
        {
            TableRelation = "Responsibility Center";
        }
         field(5; "Document Type"; Option)
        {
            OptionMembers = " ",Files,Mail;
            OptionCaption = '" ",File,Mail';
        }
    }

    keys
    {
        key(Key1; "No.", Description)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

