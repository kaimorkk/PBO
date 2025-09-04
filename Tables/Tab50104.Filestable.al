 
   table 50104 "Files Table"
{
    Caption = 'Task Movement Files';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Tasks List";
    LookupPageId = "Tasks List";

    fields
    {
        field(1; "No."; Code[100])
        {
            Caption = 'File No.';
            // AutoIncrement = true;
            // Editable = false;
        }
        field(2; "File Type"; Enum "File Types")
        {
            Caption = 'Task Type';
            // OptionMembers = " ","Member File","Business Loans File","Policy Files","HR Files",Departmental,Other;
            // OptionCaption = ' , Member File, Business Loans File, Policy Files, HR Files, Departmental, Other';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                "Business Loan Types" := ' ';
                "Policy Files Types" := ' ';
                "File/Member No." := '';
                "File Name/Descrption" := '';
                "Staff PF No." := '';
                "File Custodian" := '';

                if Rec."File Type" = Rec."File Type"::"Hr Tasks" then begin
                    HRTable.RESET;
                    HRTable.SetRange("No.", Rec."Staff PF No.");
                    if HRTable.Find('-') then begin
                        Rec."File Name/Descrption" := HRTable.FullName();
                        Rec."File/Member No." := HRTable."No.";
                        Rec."No." := HRTable."No." + '-HR';
                    end;

                end
            end;
        }
        field(3; "File/Member No."; Code[100])
        {
            //Caption = 'File/Member No.';
            Caption = 'Member No.';
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Members.Get("File/Member No.") then begin
                    // if rec."File Type" = rec."File Type"::"Member File" then begin
                    // Rec."No." := Members."No.";
                    rec."File Name/Descrption" := Members."Search Name";
                    Rec."Staff PF No." := Members."No.";
                    Rec."Member Name" := Members."Search Name";
                    // end;
                    if rec."File Type" = rec."File Type"::"Accounts File" then begin
                        // Rec."No." := Members."No." + '-BSL';
                        rec."File Name/Descrption" := Members."Search Name";
                        Rec."Staff PF No." := Members."No.";
                        Rec."Member Name" := Members."Search Name";
                    end;
                end;

            end;
        }
        field(4; "File Name/Descrption"; Text[250])
        {
            Caption = 'File Name/Descrption';
        }
        field(5; "File Custodian"; Code[100])
        {
            Caption = 'File Custodian';
            TableRelation = "Responsibility Center";
        }
        field(6; "File Status"; Option)
        {
            Caption = 'File Status';
            OptionMembers = "In Store","In Movement","Archived";
        }
        field(7; "File Volume No."; Code[100])
        {
            Caption = 'File Volume No.';
            TableRelation = "Task Volumes"."File Volume No.";
        }
        field(8; "Entry No."; Code[100])
        {
            Caption = 'Entry No.';
            //AutoIncrement = true;
            trigger OnValidate()
            begin
                if rec."Document Type" = rec."Document Type"::Files then begin
                    if "Entry No." <> xRec."Entry No." then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(MembNoSeries."File Entry No.");
                        "No. Series" := '';
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::Mail then begin
                    if "Entry No." <> xRec."Entry No." then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(MembNoSeries."Mail Entry No");
                        "No. Series" := '';
                    end;
                end;
            end;
        }
        field(9; "No. Series"; Code[100])
        {
        }
        field(10; "Staff PF No."; Code[100])
        {
            trigger OnValidate()
            var
                myInt: Integer;
            begin

            end;
        }
        field(11; "Member Name"; Code[200])
        {
        }
        field(12; "Business Loan Types"; Option)
        {
            OptionMembers = " ",Individual,Groups;
            OptionCaption = ' , Individual, Groups';
        }
        field(13; "Policy Files Types"; Option)
        {
            OptionMembers = " ",Administrative,Finance;
            OptionCaption = ' , Administrative, Finance';
        }
        field(14; "File Sub Type"; Code[100])
        {
            TableRelation = IF ("File Type" = Const("Accounts File")) "File Sub Types"."Business Loans"
            else IF ("File Type" = Const("Accounts File")) "File Sub Types"."Policy Files";
        }

        field(16; "ID No."; Code[100])
        {
        }
        field(17; "Document Type"; Option)
        {
            OptionMembers = " ",Files,Mail;
            OptionCaption = '" ",File,Mail';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                "Entry No." := '';
                if rec."Document Type" = rec."Document Type"::Files then begin
                    if "Entry No." = '' then begin
                        SeriesSetup.Get;
                        SeriesSetup.TestField(SeriesSetup."File Entry No.");
                        NoSeriesMgt.InitSeries(SeriesSetup."File Entry No.", xRec."No. Series", 0D, "Entry No.", "No. Series");
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::Mail then begin
                    if "Entry No." = '' then begin
                        SeriesSetup.Get;
                        SeriesSetup.TestField(SeriesSetup."Mail Entry No");
                        NoSeriesMgt.InitSeries(SeriesSetup."Mail Entry No", xRec."No. Series", 0D, "Entry No.", "No. Series");
                    end;
                end;
            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdown; "No.", "File Type", "File Name/Descrption")
        {
        }
    }
    trigger OnInsert()

    Var
        UserSetup: Record "User Setup";
        SeriesSetup: Record "HR setup";
    begin
        if rec."Document Type" = rec."Document Type"::Files then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."File Entry No.");
                NoSeriesMgt.InitSeries(SeriesSetup."File Entry No.", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        if rec."Document Type" = rec."Document Type"::Mail then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Mail Entry No");
                NoSeriesMgt.InitSeries(SeriesSetup."Mail Entry No", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
    end;


    var
        Members: Record Employee;
        // Loans: Record Loans;
        FileMovemementFiles: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        HRTable: Record Employee;
        UserSetup: Record "User Setup";
        SeriesSetup: Record "HR setup";
}
