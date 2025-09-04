table 50113 "File Sub Types"
{
    Caption = 'File Sub Types';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[100])
        {
            Caption = 'Code';
        }
        field(2; "Policy Files"; Option)
        {
            Caption = 'Policy Files';
            OptionMembers = "Administrative File",Financials;
            OptionCaption = 'Administrative File, Financials';
        }
        field(3; "Business Loans"; Option)
        {
            Caption = 'Policy Files';
            OptionMembers = "Individual","Group";
            OptionCaption = 'Individual, Group';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
