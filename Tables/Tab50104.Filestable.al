
table 50104 "Files Table"
{
    Caption = 'Task Movement Files';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Tasks List";
    LookupPageId = "Tasks List";

    fields
    {
        field(1; "Entry No."; Code[100])
        {
            Caption = 'Task No.';
            //AutoIncrement = true;
            trigger OnValidate()
            begin
                if rec."Document Type" = rec."Document Type"::"Bill Costing" then begin
                    if "Entry No." <> xRec."Entry No." then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(MembNoSeries."Bill Costing");
                        "No. Series" := '';
                        UserSetup.Reset();
                        UserSetup.SetRange("User ID", UserId);
                        IF UserSetup.FindFirst() then begin
                            rec."Author Code" := UserSetup."Staff No";
                            rec.Validate(rec."Author Code");
                        end;
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Bill Determination" then begin
                    if "Entry No." <> xRec."Entry No." then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(MembNoSeries."Bill Determination");
                        "No. Series" := '';
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Incoming Correspondence" then begin
                    if "Entry No." = '' then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(SeriesSetup."Incoming Correspondence");
                        "No. Series" := '';
                        // NoSeriesMgt.InitSeries(SeriesSetup."Incoming Correspondence", xRec."No. Series", 0D, "Entry No.", "No. Series");
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Incoming Memos" then begin
                    if "Entry No." = '' then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(SeriesSetup."Incoming Memos");
                        "No. Series" := '';
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Outgoing Correspondence" then begin
                    if "Entry No." = '' then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(SeriesSetup."Outgoing Correspondence");
                        "No. Series" := '';
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Outgoing Memos" then begin
                    if "Entry No." = '' then begin
                        MembNoSeries.Get;
                        NoSeriesMgt.TestManual(SeriesSetup."Outgoing Memos");
                        "No. Series" := '';
                    end;
                end;
                UserSetup.Reset();
                UserSetup.SetRange("User ID", UserId);
                IF UserSetup.FindFirst() then begin
                    rec."Author Code" := UserSetup."Staff No";
                    rec.Validate(rec."Author Code");
                    rec.Author := UserSetup."Staff No";
                    rec.Validate(Author);
                end;

            end;
        }
        field(8; "No."; Code[100])
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
                // "Author" := '';
                "File Name/Descrption" := '';
                Department := '';

                if Rec."File Type" <> Rec."File Type"::"Other Tasks" then begin
                    HRTable.RESET;
                    HRTable.SetRange("No.", Rec."Author Code");
                    if HRTable.Find('-') then begin
                        Rec."File Name/Descrption" := HRTable.FullName();
                        Rec."Author" := HRTable."No.";
                        Rec."No." := HRTable."No." + '-HR';
                    end;

                end
            end;
        }
        field(3; "Author"; Code[100])
        {
            //Caption = 'File/Member No.';
            Caption = 'Author';
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Members.Get("Author") then begin
                    rec."Author Code" := Members."No.";
                    // if rec."File Type" = rec."File Type"::"Member File" then begin
                    // Rec."No." := Members."No.";
                    rec."File Name/Descrption" := Members."Search Name";
                    Rec."Author" := Members."Search Name";
                    Rec."Member Name" := Members."Search Name";
                    rec."Author Email" := Members."Company E-Mail";
                    // end;
                    // if rec."File Type" = rec."File Type"::"Accounts File" then begin
                    //     // Rec."No." := Members."No." + '-BSL';
                    //     rec."File Name/Descrption" := Members."Search Name";
                    //     Rec."Staff PF No." := Members."No.";
                    //     Rec."Member Name" := Members."Search Name";
                    // end;
                end;

            end;
        }
        field(4; "File Name/Descrption"; Text[250])
        {
            Caption = 'File Name/Descrption';
        }
        field(6; "Task Status"; Option)
        {
            Caption = 'Task Status';
            OptionMembers = Open,Forwared,"Archived";
        }
        field(7; "File Volume No."; Code[100])
        {
            Caption = 'File Volume No.';
            TableRelation = "Task Volumes"."File Volume No.";
        }

        field(9; "No. Series"; Code[100])
        {
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
            // TableRelation = IF ("File Type" = Const("Accounts File")) "File Sub Types"."Business Loans"
            // else IF ("File Type" = Const("Accounts File")) "File Sub Types"."Policy Files";
        }

        field(16; "ID No."; Code[100])
        {
        }
        field(17; "Document Type"; Option)
        {
            OptionMembers = " ","Bill Costing","Bill Determination","Outgoing Memos","Incoming Memos","Outgoing Correspondence","Incoming Correspondence";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                "Entry No." := '';
                if rec."Document Type" = rec."Document Type"::"Bill Costing" then begin
                    if "Entry No." = '' then begin
                        SeriesSetup.Get;
                        SeriesSetup.TestField(SeriesSetup."Bill Costing");
                        NoSeriesMgt.InitSeries(SeriesSetup."Bill Costing", xRec."No. Series", 0D, "Entry No.", "No. Series");
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Bill Determination" then begin
                    if "Entry No." = '' then begin
                        SeriesSetup.Get;
                        SeriesSetup.TestField(SeriesSetup."Bill Determination");
                        NoSeriesMgt.InitSeries(SeriesSetup."Bill Determination", xRec."No. Series", 0D, "Entry No.", "No. Series");
                    end;
                end;
                if rec."Document Type" = rec."Document Type"::"Bill Determination" then begin
                    if "Entry No." = '' then begin
                        SeriesSetup.Get;
                        SeriesSetup.TestField(SeriesSetup."Bill Determination");
                        NoSeriesMgt.InitSeries(SeriesSetup."Bill Determination", xRec."No. Series", 0D, "Entry No.", "No. Series");
                    end;
                end;
            end;
        }
        field(18; "Author Email"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Task Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Department; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            trigger OnValidate()
            var
                myInt: Integer;
                Dimes: Record "Dimension Value";
            begin
                Dimes.Reset();
                Dimes.SetRange(Code, rec.Department);
                if Dimes.FindFirst() then
                    rec."Department Name" := Dimes.Name;

            end;
        }
        field(21; "Description/Subject"; Text[1500])
        {
            DataClassification = ToBeClassified;
        }
        field(22; Reference; Text[1300])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Remarks"; Text[1400])
        {
            DataClassification = ToBeClassified;
        }
        field(24; Feedback; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(25; Action; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Date Received"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Incoming Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Receiver"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Members.Get("Receiver") then begin
                    rec."Receiver Code" := Members."No.";
                    Rec.Receiver := Members."Search Name";
                    rec."Reciever Mail" := Members."Company E-Mail";
                end;

            end;
        }
        field(30; "Due Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Reciever Mail"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Receiver Code"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
            trigger OnValidate()
            var
                myInt: Integer;
                EmployeeC: Record Employee;
            begin
                EmployeeC.Reset();
                EmployeeC.SetRange("No.", "Author Code");
                if EmployeeC.FindFirst() then begin
                    Rec.Receiver := Members."Search Name";
                    rec."Reciever Mail" := Members."Company E-Mail";
                end;

            end;
        }
        field(33; "Author Code"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
            trigger OnValidate()
            var
                myInt: Integer;
                EmployeeC: Record Employee;
            begin
                EmployeeC.Reset();
                EmployeeC.SetRange("No.", "Author Code");
                if EmployeeC.FindFirst() then begin
                    Rec."Author" := EmployeeC."Search Name";
                    Rec."Member Name" := EmployeeC."Search Name";
                    rec."Author Email" := EmployeeC."Company E-Mail";
                end;


            end;
        }
        field(34; "Closed By"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Date Closed"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Department Name"; Text[200])
        {
            DataClassification = ToBeClassified;
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
        if rec."Document Type" = rec."Document Type"::"Bill Costing" then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Bill Costing");
                NoSeriesMgt.InitSeries(SeriesSetup."Bill Costing", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        if rec."Document Type" = rec."Document Type"::"Bill Determination" then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Bill Determination");
                NoSeriesMgt.InitSeries(SeriesSetup."Bill Determination", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        if rec."Document Type" = rec."Document Type"::"Incoming Correspondence" then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Incoming Correspondence");
                NoSeriesMgt.InitSeries(SeriesSetup."Incoming Correspondence", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        if rec."Document Type" = rec."Document Type"::"Incoming Memos" then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Incoming Memos");
                NoSeriesMgt.InitSeries(SeriesSetup."Incoming Memos", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        if rec."Document Type" = rec."Document Type"::"Outgoing Correspondence" then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Outgoing Correspondence");
                NoSeriesMgt.InitSeries(SeriesSetup."Outgoing Correspondence", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        if rec."Document Type" = rec."Document Type"::"Outgoing Memos" then begin
            if "Entry No." = '' then begin
                SeriesSetup.Get;
                SeriesSetup.TestField(SeriesSetup."Outgoing Memos");
                NoSeriesMgt.InitSeries(SeriesSetup."Outgoing Memos", xRec."No. Series", 0D, "Entry No.", "No. Series");
            end;
        end;
        UserSetup.Reset();
        UserSetup.SetRange("User ID", UserId);
        IF UserSetup.FindFirst() then begin
            rec."Author Code" := UserSetup."Staff No";
            rec.Validate(rec."Author Code");
            rec.Author := UserSetup."Staff No";
            rec.Validate(Author);
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
