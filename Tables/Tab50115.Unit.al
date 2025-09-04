 
    table 50115 Unit
{
    LookupPageID = "Unit List";

    fields
    {
        field(1; "Property No."; Code[20])
        {
            TableRelation = "Property Details"."No.";
            trigger OnValidate()
            begin
                Prpertydetails.RESET;
                Prpertydetails.SETRANGE(Prpertydetails."No.", "Property No.");
                IF Prpertydetails.FIND('-') THEN BEGIN
                    //"Total area square" := Prpertydetails."Total Area sq ft";
                    "Property Name" := Prpertydetails.Description;
                END;
            end;
        }
        field(2; "Floor Code"; Code[20])
        {
            TableRelation = Floor."Floor Code" WHERE("No." = FIELD("Property No."));
        }
        field(3; "Unit Code"; Code[100])
        {
        }
        field(4; "Unit Name"; Text[100])
        {
        }
        field(5; "Unit Type"; Code[20])
        {
            TableRelation = "Unit Type".Code;

            trigger OnValidate()
            begin
                UnitType.Reset;
                UnitType.Get("Unit Type");
                "Unit Type Name" := UnitType.Description;
            end;
        }
        field(6; "Unit Type Name"; Text[100])
        {
            FieldClass = Normal;
        }
        field(7; "Unit Sub Type"; Code[20])
        {
            TableRelation = "Unit Sub Type".Code;
        }
        field(8; "Unit Sub Type Name"; Text[100])
        {
            CalcFormula = Lookup("Unit Sub Type".Description WHERE("Unit Type" = FIELD("Unit Type"),
                                                                    Code = FIELD("Unit Sub Type")));
            FieldClass = FlowField;
        }
        field(9; "Unit Status"; Option)
        {
            OptionMembers = Vacant,Occupied;
        }
        field(10; "Area Square ft"; Decimal)
        {
            FieldClass = Normal;

            trigger OnValidate()
            begin

            //     TotalSqrFeet := 0;
            //     Prpertydetails.RESET;
            //     Prpertydetails.SETRANGE(Prpertydetails."No.", "Property No.");
            //     IF Prpertydetails.FIND('-') THEN BEGIN
            //         REPEAT
            //             TotalSqrFeet := TotalSqrFeet + "Area Square ft";
            //             "Area Square ft" := TotalSqrFeet;
            //         UNTIL NEXT = 0;
            //         // IF "Area Square ft" > Prpertydetails."Total Area sq ft" THEN
            //         //     ERROR('Unit Area Square ft cannot exceed Total Floor Area Square ft of %1', Prpertydetails."Total Area sq ft");
            //     END;


            //     Prpertydetails.RESET;
            //     Prpertydetails.SETRANGE(Prpertydetails."No.", "Property No.");
            //     IF Prpertydetails.FIND('-') THEN BEGIN
            //         IF "Total area square" > Prpertydetails."Total Area sq ft" THEN
            //             ERROR('Unit Area Square ft cannot exceed Total Floor Area Square ft of %1', Prpertydetails."Total Area sq ft");
                END;



                // TSF := SumArea("Area Square ft");

            // end;
        }
        field(11; "Meter No."; Text[100])
        {
        }
        field(12; Occupied; Boolean)
        {
        }
        field(13; "Total area square"; Decimal)
        {
            CalcFormula = Sum(Unit."Area Square ft" WHERE("Floor Code" = FIELD("Floor Code"),
                                                           "Property No." = FIELD("Property No.")));
            FieldClass = FlowField;
        }
        field(14; "Amount Per Sq ft"; Decimal)
        {
        }
        field(15; "Property Name"; Text[100])
        {
        }
    }

    keys
    {
        key(Key1; "Property No.", "Floor Code", "Unit Code")
        {
            Clustered = true;
            SumIndexFields = "Area Square ft";
        }
    }

    fieldgroups
    {
    }

    var
        UnitType: Record "Unit Type";
        UnitST: Record "Unit Sub Type";
        Floor: Record Floor;
        TotalSqrFeet: Decimal;
        Prpertydetails: Record "Property Details";
        TSF: Decimal;
        Unt: Record Unit;

    //[Scope('OnPrem')]
    procedure SumArea(ASF: Decimal) "Sum": Decimal
    begin
        Floor.Reset;
        Floor.SetRange(Floor."No.", "Property No.");
        Floor.SetRange(Floor."Floor Code", "Floor Code");
        if Floor.Find('-') then
            Unt.Reset;
        Unt.SetRange(Unt."Property No.", "Property No.");
        Unt.SetRange(Unt."Floor Code", "Floor Code");
        if Unt.Find('-') then
            repeat
                ASF := ASF + Unt."Area Square ft";
            until Unt.Next = 0;
        if ASF > Floor."Floor Area sq ft" then begin

            Error('Unit Area Square has exceeded the maximum floor Area by %1', ASF - Floor."Floor Area sq ft");
        end;
    end;
}

