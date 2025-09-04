 
   table 50100 "PBO Meetings"
{
    Caption = 'Meetings';
    DataClassification = ToBeClassified;
    LookupPageId="PBO Meeting List";
    DrillDownPageId="PBO Meeting List";

    fields
    {
        field(1; "Meeting Code"; Code[40])
        {
            Caption = 'Meeting Code';
            trigger OnValidate()
            var
                NewStr: Code[20];
            begin
                if "Meeting Code" <> xRec."Meeting Code" then begin
                    HrSetup.Get();
                    NoSeriesMgt.TestManual(HrSetup."Meeting Code");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Meeting Summary"; Text[700])
        {
            DataClassification = ToBeClassified;
            
        }
        field(3; "Meeting Date"; Date)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if rec."Meeting Date" < Today then
                    Error('meeting date cannot be backdated!');
            end;
        }
        field(4; "Meeting Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,Pending,proceeding,Successful,failled;
        }
        field(5; "Meeting Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "No. Series"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Date captured"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Captured By"; code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Document Comment"; Text[500])
        {
            DataClassification = ToBeClassified;
            Caption='Document Comment';
        }
    }
    keys
    {
        key(PK; "Meeting Code")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        rec."Date captured" := today;
        rec."Captured By" := UserId;
        if "Meeting Code" = '' then begin
            HrSetup.Get();
            HrSetup.TestField("Meeting Code");
            NoSeriesMgt.InitSeries(HrSetup."Meeting Code", xRec."No. Series", 0D, "Meeting Code", "No. Series");
        end;
    end;
    trigger OnDelete()
    var
        myInt: Integer;
    begin
        if rec."Meeting Status"<>rec."Meeting Status"::Open then
        Error('You cannot delete documents at this stage');
    end;

    var
        HrSetup: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
