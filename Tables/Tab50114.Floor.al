 
    table 50114 Floor
{
    LookupPageID = Floor;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Floor Code"; Code[10])
        {
            TableRelation = IF ("Property Type" = CONST('LAND')) "Floor Codes"."Floor Code" WHERE(Land = CONST(true))
            ELSE
            IF ("Property Type" = FILTER(<> 'LAND')) "Floor Codes"."Floor Code" WHERE(Land = CONST(false));

            trigger OnValidate()
            begin
                FloorCodes.Reset;
                FloorCodes.SetRange(FloorCodes."Floor Code", "Floor Code");
                if FloorCodes.Find('-') then
                    Description := FloorCodes.Description;
            end;
        }
        field(3; Description; Text[100])
        {
        }
        field(4; "Total Units"; Integer)
        {
            CalcFormula = Count(Unit WHERE("Property No." = FIELD("No."),
                                            "Floor Code" = FIELD("Floor Code")));
            FieldClass = FlowField;
        }
        field(5; "Unit Status"; Text[100])
        {
        }
        field(6; "Property Type"; Code[20])
        {
            CalcFormula = Lookup("Property Details"."Property Type" WHERE("No." = FIELD("No.")));
            FieldClass = FlowField;
        }
        field(7; "Floor Area sq ft"; Decimal)
        {

            trigger OnValidate()
            begin
                

            end;
        }
        field(8; "Occupied Units"; Integer)
        {
            CalcFormula = Count(Unit WHERE("Property No." = FIELD("No."),
                                            "Unit Status" = CONST(Occupied),
                                            "Floor Code" = FIELD("Floor Code")));
            FieldClass = FlowField;
        }
        field(9; "Vacant Units"; Integer)
        {
            CalcFormula = Count(Unit WHERE("Property No." = FIELD("No."),
                                            "Unit Status" = CONST(Vacant),
                                            "Floor Code" = FIELD("Floor Code")));
            FieldClass = FlowField;
        }
        field(10; "Floor Type"; Option)
        {
            OptionCaption = 'Ground,1ST Floor,2nd Floor';
            OptionMembers = Ground,"1ST Floor","2nd Floor";
        }
        field(11; "Total Area sq ft"; Decimal)
        {
            CalcFormula = Sum(Floor."Floor Area sq ft" WHERE("No." = FIELD("No."),
                                                              "Floor Code" = FIELD("Floor Code")));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Floor Code", "No.")
        {
            Clustered = true;
            SumIndexFields = "Floor Area sq ft";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        /*
        PropertyDet.RESET;
        PropertyDet.SETRANGE(PropertyDet."No.","No.");
        IF PropertyDet.FIND('-')THEN BEGIN
        "Total Area sq ft":=PropertyDet."Total Area sq ft";
        END;
        */

    end;

    var
        Unit: Record Unit;
        PropertyDet: Record "Property Details";
        FloorCodes: Record "Floor Codes";
        Floor: Record Floor;
        FTSF: Decimal;

    [Scope('OnPrem')]
    procedure SumFloor(FloorASF: Decimal) "Sum": Decimal
    begin
        PropertyDet.Reset;
        PropertyDet.SetRange(PropertyDet."No.", "No.");
        if PropertyDet.Find('-') then
            Floor.Reset;
        Floor.SetRange(Floor."No.", PropertyDet."No.");

        if Floor.Find('-') then
            repeat
                FloorASF := FloorASF + Floor."Floor Area sq ft";
            until Floor.Next = 0;

        if FloorASF > PropertyDet."Total Area sq ft" then begin

            //ERROR('Unit Area Square has exceeded the maximum floor Area by %1',FloorASF-Floor."Floor Area sq ft");
            // END;
            Error('Floor Total Area Square ft CANNOT be greater than what is specified.');
        end;
    end;
}

