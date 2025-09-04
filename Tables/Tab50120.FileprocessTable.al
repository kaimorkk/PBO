 
  table 50120 "Batching Process Table"
{
    Caption = 'Batching Process Table';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Batching Process List";
    LookupPageId = "Batching Process List";

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'No';
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    MembNoSeries.Get;
                    NoSeriesMgt.TestManual(MembNoSeries."File Batching No.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            // TableRelation = "Batch No Table"."Batch Entry No.";
            TableRelation = "Batch No Table";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                BatchesTable.RESET;
                BatchesTable.Setrange("Batch Entry No.", Rec."Batch No.");
                if BatchesTable.Find('-') then begin
                    Rec."Batch" := BatchesTable."Batch Number";
                end;

                BatchLines.Reset();
                BatchLines.Setrange("Header No.", Rec."No.");
                if BatchLines.FindSet() then
                    BatchLines.DeleteAll();

                FileVolumes.RESET;
                FileVolumes.SetRange("Batch", Rec."Batch");
                FileVolumes.SetRange(Archived, False);
                FileVolumes.SetRange(Batched, True);
                if FileVolumes.find('-') then begin
                    repeat
                        BatchLines.Init;
                        BatchLines."Header No." := Rec."No.";
                        BatchLines."Batch No." := FileVolumes."Batch";
                        BatchLines."File No." := FileVolumes."File No.";
                        BatchLines."Volume No." := FileVolumes."File Volume No.";
                        BatchLines.Archived := FileVolumes.Archived;
                        BatchLines."Date Batched" := FileVolumes."Date Batched";
                        FilesTable.Reset();
                        FilesTable.SetRange("No.", FileVolumes."File No.");
                        if FilesTable.FindFirst() then
                            BatchLines."Member No." := FilesTable."File/Member No.";
                        BatchLines."Staff PF No." := FilesTable."Staff PF No.";
                        BatchLines."Member Name" := FilesTable."File Name/Descrption";
                        BatchLines.Insert();
                    until FileVolumes.Next() = 0;
                end;
            end;
        }
        field(3; "Global Dimension 1 Code"; Code[50])
        {
            Caption = 'Global Dimension 1 Code';
        }
        field(4; "Global Dimension 2 Code"; Code[50])
        {
            Caption = 'Global Dimension 2 Code';
        }
        field(5; "Created By"; Code[50])
        {
            Caption = 'Created By';
        }
        field(6; "Created at"; Date)
        {
            Caption = 'Created at';
        }
        field(7; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(8; "Responsibility Center"; Code[50])
        {
            Caption = 'Responsibility Center';
        }
        field(9; "No. Series"; Code[20])
        {
            Caption = 'No Series';
        }
        field(10; "Date Archived"; Date)
        {
            Caption = 'Date Archived';
        }
        field(11; "Archived By"; Code[100])
        {
            Caption = 'Archived By';
        }
        field(12; Status; Enum "Workflow Status Main Flags")
        {
            Caption = 'Status';
        }
        field(13; "File Location No."; Integer)
        {
            Caption = 'Location';
            TableRelation = "Task Locations"."Location Entry";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                FileLocations.Reset;
                FileLocations.SetRange(FileLocations."Location Entry", Rec."File Location No.");
                if FileLocations.Find('-') then begin
                    Rec."Building Name" := FileLocations.Building;
                    Rec."Floor No." := FileLocations.Floor;
                    Rec.Town := FileLocations.Town;
                end;
            end;
        }
        field(14; "Building Name"; Text[100])
        {
            Caption = 'Building Name';
        }
        field(15; "Floor No."; Text[100])
        {
            Caption = 'Floor No.';
        }
        field(16; Town; Text[100])
        {
            Caption = 'Town';
        }
        field(17; Batch; Code[50])
        {
            Caption = 'Batch';
        }
    }
    keys
    {
        key(PK; "No.", "Batch No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()

    Var
        UserSetup: Record "User Setup";
        SeriesSetup: Record "HR setup";
    begin

        //end;
        "Created By" := userID;
        "Created at" := Today;

        "User ID" := UserId;
        "Created By" := UserId;

        if UserSetup.Get(UserId) then begin
            UserSetup.TestField(UserSetup."Global Dimension 1 Code");
            // UserSetup.TestField(UserSetup."Global Dimension 2 Code");
            "Global Dimension 1 Code" := UserSetup."Global Dimension 1 Code";
            // "Global Dimension 2 Code" := UserSetup."Global Dimension 2 Code";
            "Responsibility Center" := UserSetup."Responsibility Center";
        end;

        begin
            if "No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."File Batching No.");
                NoSeriesMgt.InitSeries(SeriesSetup."File Batching No.", xRec."No. Series", 0D, "No.", "No. Series");
            end;
        end;
    end;

    var
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        FileVolumes: Record "Task Volumes";
        BatchLines: Record "Batch Lines Table";
        FilesTable: Record "Files Table";
        Members: Record Employee;
        FileLocations: Record "Task Locations";
        BatchesTable: Record "Batch No Table";
}
