 
   table 50116 "Property Details"
{
    DrillDownPageID = "All Property List";
    LookupPageID = "All Property List";

    fields
    {
        field(1; "No."; Code[20])
        {
            //TableRelation = "Fixed Asset"."No." WHERE("FA Subclass Code" = FILTER('LAND'));
            TableRelation = "Fixed Asset";

            trigger OnValidate()
            Var
                FALocation: Record "FA Location";

            begin
                FA.Reset;
                FA.SetRange(FA."No.", "No.");
                if FA.Find('-') then begin
                    Description := FA.Description;
                    "L.R. No." := FA."Serial No.";
                    FALocation.RESET;
                    FALocation.Setrange(FALocation.Code, FA."Location Code");
                    IF falocation.FindFirst() THEN begin
                        "Building Location" := FALocation.Name;
                    end;
                    // "Building Location" := FALocation.Name;
                    //"Fixed Asset No." := FA."No.";
                end;
                //insert default landlord epz
                Vend.Reset;
                Vend.SetRange(Vend."Vendor Type", Vend."Vendor Type"::Institution);
                if Vend.Find('-') then begin
                    "Landlord No." := Vend."No.";
                    "Landlord Name" := Vend.Name;
                end;
            end;
        }
        field(2; "L.R. No."; Code[100])
        {
        }
        field(3; "Landlord No."; Code[20])
        {
            TableRelation = Vendor."No." WHERE("Vendor Type" = FILTER(Landlord));

            trigger OnValidate()
            begin

                Vend.Reset;
                Vend.Get("Landlord No.");
                "Landlord Name" := Vend.Name;
            end;
        }
        field(4; "Landlord Name"; Text[100])
        {
        }
        field(5; Description; Text[100])
        {
        }
        field(6; City; Code[20])
        {
            TableRelation = "Post Code";
        }
        field(7; Street; Text[100])
        {
        }
        field(111; "Fixed Asset No."; Code[20])
        {
        }
        field(8; "Commission Rate"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Commision Flat Amount" > 0 then
                    Error('You cannot Bill on both Management Fees');
            end;
        }
        field(9; "ALM Signed"; Boolean)
        {
        }
        field(10; "File Ref No."; Code[20])
        {
        }
        field(11; "No. Series"; Code[10])
        {
        }
        field(12; "Duration Value"; Integer)
        {

            trigger OnValidate()
            begin

                //check the value selected by the user
                TestField("Commence Date");
                TestField("Duration Value");
                TestField("Duration Type");
                if "Duration Type" = "Duration Type"::Days then begin
                    "Expiry Date" := CalcDate(Format("Duration Value") + 'D', "Commence Date");
                end
                else
                    if "Duration Type" = "Duration Type"::Weeks then begin
                        "Expiry Date" := CalcDate(Format("Duration Value") + 'W', "Commence Date");
                    end
                    else
                        if "Duration Type" = "Duration Type"::Months then begin
                            "Expiry Date" := CalcDate(Format("Duration Value") + 'M', "Commence Date");
                        end
                        else
                            if "Duration Type" = "Duration Type"::Quarters then begin
                                "Expiry Date" := CalcDate(Format("Duration Value") + 'Q', "Commence Date");
                            end
                            else
                                if "Duration Type" = "Duration Type"::Years then begin
                                    "Expiry Date" := CalcDate(Format("Duration Value") + 'Y''-1D', "Commence Date");
                                end;
            end;
        }
        field(13; "Commence Date"; Date)
        {

            trigger OnValidate()
            begin
                if "Duration Type" = "Duration Type"::Days then begin
                    "Expiry Date" := CalcDate(Format("Duration Value") + 'D', "Commence Date");
                end
                else
                    if "Duration Type" = "Duration Type"::Weeks then begin
                        "Expiry Date" := CalcDate(Format("Duration Value") + 'W', "Commence Date");
                    end
                    else
                        if "Duration Type" = "Duration Type"::Months then begin
                            "Expiry Date" := CalcDate(Format("Duration Value") + 'M', "Commence Date");
                        end
                        else
                            if "Duration Type" = "Duration Type"::Quarters then begin
                                "Expiry Date" := CalcDate(Format("Duration Value") + 'Q', "Commence Date");
                            end
                            else
                                if "Duration Type" = "Duration Type"::Years then begin
                                    "Expiry Date" := CalcDate(Format("Duration Value") + 'Y''-1D', "Commence Date");
                                end;
            end;
        }
        field(14; "Expiry Date"; Date)
        {

            trigger OnValidate()
            begin
                if "Expiry Date" <= Today then begin
                    "Agreement Status" := "Agreement Status"::Terminated;
                    Modify;
                    // EmailA.CreateMessage('Regeant Managemnt','dlesamana@coretec.co.ke','rmkirema@coretec.co.ke','chekmail','Expired prop',TRUE);
                    // EmailA.Send();
                end;
            end;
        }
        field(15; "Agreement Status"; Option)
        {
            OptionCaption = 'Pending,Active,Terminated';
            OptionMembers = Pending,Active,Terminated,Archived;
        }
        field(311; "Building Status"; Option)
        {
            OptionCaption = 'Pending,Active,Terminated,Archived';
            OptionMembers = Pending,Active,Terminated,Archived;
        }

        field(16; "Duration Type"; Option)
        {
            OptionMembers = Days,Weeks,Months,Quarters,Years;
        }
        field(18; "Property Code"; Code[20])
        {
            TableRelation = "Dimension Value"."Global Dimension No.";

            trigger OnLookup()
            begin

                GenSetup.Reset;
                GenSetup.Get();
                DimVal.Reset;
                DimVal.SetRange(DimVal."Dimension Code", GenSetup."Global Dimension 2 Code");
                if PAGE.RunModal(Page::"Dimension Value List", DimVal) = ACTION::LookupOK then begin
                    "Property Code" := DimVal.Code;
                    "Department name" := DimVal.Name;
                end;
            end;
        }
        field(19; "Property Type"; Code[20])
        {
            TableRelation = "Property Category".Code;
        }
        field(20; "Total Area sq ft"; Decimal)
        {
            FieldClass = Normal;
        }
        field(21; "total Units[Occupied]"; Integer)
        {
            CalcFormula = Count(Unit WHERE("Property No." = FIELD("No."),
                                            Occupied = CONST(true)));
            FieldClass = FlowField;
        }
        field(22; "Property Manager[Staff]"; Code[30])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin
                Emp.Reset;
                Emp.SetRange(Emp."No.", "Property Manager[Staff]");
                if Emp.Find('-') then begin
                    "Employee Name" := Emp."First Name";
                end;
            end;
        }
        field(23; "total Units"; Integer)
        {
            CalcFormula = Count(Unit WHERE("Property No." = FIELD("No.")));
            FieldClass = FlowField;
        }
        field(24; "Charge Code"; Code[30])
        {
            // TableRelation = Charges.Code;
        }
        field(25; "Commision Flat Amount"; Decimal)
        {

            trigger OnValidate()
            begin
                if "Commission Rate" > 0 then
                    Error('You cannot Bill on both Management Fees');
            end;
        }
        field(26; "Property Invoices"; Decimal)
        {
            FieldClass = Normal;
        }
        field(27; "Property Receipts"; Decimal)
        {
        }
        field(28; "Department name"; Text[50])
        {
        }
        field(29; "Time Property Created"; Time)
        {
        }
        field(30; "Property Created By"; Code[30])
        {
        }
        field(34; "Charge letting once"; Boolean)
        {
            Editable = false;
        }
        field(57; "Letting Fee Rate(%)"; Decimal)
        {

            trigger OnValidate()
            begin
                if "Letting Flat Amount" > 0 then begin
                    Error('You cannot Bill on both Letting and Reletting Fees');
                end;
            end;
        }
        field(58; "Letting Flat Amount"; Decimal)
        {

            trigger OnValidate()
            begin
                if "Letting Fee Rate(%)" > 0 then
                    Error('You cannot Bill on both Letting and Reletting Fees');
            end;
        }
        field(59; "Reletting Fee Rate(%)"; Decimal)
        {

            trigger OnValidate()
            begin
                if "Reletting Flat Amount" > 0 then
                    Error('You cannot Bill on both Letting and Reletting Fees');
            end;
        }
        field(60; "Reletting Flat Amount"; Decimal)
        {

            trigger OnValidate()
            begin
                /*
                  IF "Reletting Fee Rate(%)">0 THEN
                  ERROR('You cannot Bill on both Letting and Reletting Fees');
                  */

            end;
        }
        field(61; "Charge Reletting once"; Boolean)
        {
        }
        field(62; "Charge VAT"; Boolean)
        {
        }
        field(63; "Employee Name"; Text[50])
        {
        }
        field(64; Status; Option)
        {
            Caption = 'Status';
            Editable = true;
            OptionCaption = 'Open,Pending Approval,Approved,Rejected';
            OptionMembers = Open,"Pending Approval",Approved,Rejected;
        }
        field(65; "Building Location"; Text[1000])
        {
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        /*
       IF "No."='' THEN
         BEGIN
           GSetup.GET();
           GSetup.TESTFIELD(GSetup."Property Nos.");
           NoSeriesMgt.InitSeries(GSetup."Property Nos.",xRec."No. Series",TODAY,"No.","No. Series");
         END;
          */
        FA.Reset;
        FA.SetRange(FA."No.", FA."No.");
        if FA.Find('-') then begin
            Description := FA.Description;
        end;
        UserSetup.Reset;
        UserSetup.SetRange(UserSetup."User ID", UserId);
        if UserSetup.Find('-') then begin
            UserSetup."Global Dimension 1 Code" := "Property Code";
        end;

    end;

    var
        Vend: Record Vendor;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenSetup: Record "General Ledger Setup";
        DimVal: Record "Dimension Value";
        // GSetup: Record "General Setup";
        // EmailA: Codeunit "SMTP Mail";
        Emp: Record Employee;
        FA: Record "Fixed Asset";
        UserSetup: Record "User Setup";
}

