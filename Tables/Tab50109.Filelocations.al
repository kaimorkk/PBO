 
   table 50109 "Task Locations"
{
    Caption = 'Task Locations';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Task Locations List";
    LookupPageId = "Task Locations List";


    fields
    {
        field(1; Location; Text[100])
        {
            Caption = 'Location';
            TableRelation = "HR Lookup Values".Code WHERE(Type = CONST("File Location"));
            trigger OnValidate()
            begin
                FileLocation.Reset;
                FileLocation.SetRange(FileLocation.Code, Location);
                if FileLocation.Find('-') then
                    Location := FileLocation.Description;
            end;
        }
        field(2; Building; Text[100])
        {
            Caption = 'Building';
            TableRelation = "Fixed Asset" WHERE("FA Class Code" = FILTER('Building'));
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                FA.Reset;
                FA.SetRange(FA."No.", Building);
                if FA.Find('-') then
                    Building := FA.Description;
            end;
        }
        field(3; Town; Text[100])
        {
            Caption = 'Town';
        }
        field(4; Floor; Text[100])
        {
            Caption = 'Floor';
            TableRelation = Floor."Floor Code";
        }
        field(5; "Location Entry"; Integer)
        {
            Caption = 'Floor Location';
            AutoIncrement = True;
        }
    }
    keys
    {
        // key(PK; Location, Building)
        // {
        //     Clustered = true;
        // }
        key(PK; "Location Entry")
        {
            Clustered = true;
        }
    }
    var
        FileLocation: Record "HR Lookup Values";
        FA: Record "Fixed Asset";
}
