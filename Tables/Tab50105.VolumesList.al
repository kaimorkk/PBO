 
    table 50105 "Task Volumes"
{
    Caption = 'Task Volumes';
    DataClassification = ToBeClassified;
    LookupPageId = "Task Volumes List";
    DrillDownPageId = "Task Volumes List";

    fields
    {
        field(1; "File No."; Code[100])
        {
            Caption = 'File No.';
            //TableRelation = "Files Table"."Entry No.";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // FilesTable.Reset();
                // FilesTable.SetRange("Entry No.", Rec."File No.");
                // IF FilesTable.FindFirst() then begin
                //     Rec."File No." := FilesTable."No.";
                //     Rec."Member No." := FilesTable."File/Member No.";
                //     Rec."Member Name" := FilesTable."File Name/Descrption"
                // end;
            end;
        }
        field(2; "File Volume No."; Code[100])
        {
            Caption = 'File Volume No.';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if Rec."File Volume No." = ' ' then
                    Error('File Volume No. cannot be blank');
                // if rec."File Volume No." < '1' then
                //     Error('File Volume No. cannot be less than 1');
                // if rec."File Volume No." > '20' then
                //     Error('File Volume No. cannot be greater than 30');
            end;
        }
        field(3; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
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

            end;
        }
        field(4; Location; Text[100])
        {
            Caption = 'Location';
            TableRelation = "Task Stations"."Station Code";
        }
        
        
        field(7; "Closed By"; Code[100])
        {
            Caption = 'Closed By';
        }
        field(8; "Archived"; Boolean)
        {
            Caption = 'Archived ';
        }
        field(9; "Archived By"; Code[100])
        {
            Caption = 'Archived By';
        }
        field(10; "Date Archived"; Date)
        {
            Caption = 'Date Archived';
        }
        field(11; Batched; Boolean)
        {
            Caption = 'Batched';
        }
        field(12; "Batched By"; Code[100])
        {
            Caption = 'Batched By';
        }
        field(13; "Global Dimension 1 Code"; Code[50])
        {
            Caption = 'Global Dimension 1 Code';
        }
        field(14; "Global Dimension 2 Code"; Code[50])
        {
            Caption = 'Global Dimension 2 Code';
        }
        field(15; "Created By"; Code[50])
        {
            Caption = 'Created By';
        }
        field(16; "Created at"; Date)
        {
            Caption = 'Created at';
        }
        field(17; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(18; "Responsibility Center"; Code[50])
        {
            Caption = 'Responsibility Center';
        }
        field(19; "Date Batched"; Date)
        {
            Caption = 'Date Batched';
        }
        field(20; "Date Closed"; DateTime)
        {
            Caption = 'Date Closed';
        }
        field(21; Closed; Boolean)
        {
            Caption = 'Closed';
        }
        field(22; "File Type"; Code[200])
        {
            TableRelation = "Files Table"."File Type";
        }
        field(23; Description; Blob)
        {
            Caption = 'Descrption';
        }
        field(24; "Member No."; Code[20])
        {
            Caption = 'Member No.';
        }
        field(25; "Volume Entry No."; Code[20])
        {
            Caption = 'Volume Entry No.';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if "Volume Entry No." <> xRec."Volume Entry No." then begin
                    MembNoSeries.Get;
                    NoSeriesMgt.TestManual(MembNoSeries."File Entry No.");
                    "No. Series" := '';
                end;
            end;
        }
        field(26; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
        field(27; "Member Name"; Text[250])
        {
            Caption = 'Member No.';
        }
        field(28; "Volume Status"; Option)
        {
            OptionCaption = 'In Custody, Issued, Archived, Closed';
            OptionMembers = "In Custody","Issued","Archived","Closed";
        }
        field(29; Batch; Code[50])
        {
            Caption = 'Batch';
        }
         field(30;  "Task Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; Department; Code[100])
        {
            DataClassification = ToBeClassified;
           TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(32; "Description/Subject"; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(33; Reference; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Remarks"; Text[400])
        {
            DataClassification = ToBeClassified;
        }
        field(35; Feedback; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(36; Action; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(37;  "Date Received";  Date)
        {
            DataClassification = ToBeClassified;
        }
        field(38;  "Incoming Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Volume Entry No.", "File No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdown; "File No.", "Volume Entry No.")
        {
        }
    }
    trigger OnInsert()

    Var
        UserSetup: Record "User Setup";
        SeriesSetup: Record "HR setup";
    begin
        "Incoming Date" := Today;
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
        if "Volume Entry No." = '' then begin
            SeriesSetup.Get;
            SeriesSetup.TestField(SeriesSetup."Volume Entry No.");
            NoSeriesMgt.InitSeries(SeriesSetup."Volume Entry No.", xRec."No. Series", 0D, "Volume Entry No.", "No. Series");
        end;
    end;

    var
        FilesTable: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        BatchesTable: Record "Batch No Table";

}
