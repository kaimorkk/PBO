
table 52193470 "SMS Lines"
{
    fields
    {
        field(1; No; Code[20])
        {
            NotBlank = true;
            TableRelation = "SMS Header".No;
        }
        field(2; "Client No"; Code[50])
        {
            NotBlank = true;
            TableRelation = Employee."No.";
            trigger OnValidate()
            var
                myInt: Integer;
                customerrec: Record Employee;
            begin
                customerrec.Reset();
                customerrec.SetRange("No.", rec."Client No");
                if customerrec.FindFirst() then begin
                    rec."Client Name" := customerrec."Search Name";
                end;

            end;
        }
        field(3; "Client Name"; Text[100])
        {
        }
        field(4; "entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Sms sent"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Loan Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Phone No"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; No, "entry No")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
    }
    trigger OnInsert()
    var
        myInt: Integer;
        GreenLines: Record "SMS Lines";
    begin
        GreenLines.Reset();
        if GreenLines.FindSet() then
            myInt := GreenLines.Count;
        rec."entry No" := myInt + 1;

    end;
}
