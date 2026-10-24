
table 52193469 "SMS Header"
{
    fields
    {
        field(1; No; Code[20])
        {
            NotBlank = false;
        }
        field(2; "Date Entered"; Date)
        {
        }
        field(3; "Time Entered"; Time)
        {
        }
        field(4; "Entered By"; Code[150])
        {
        }
        field(5; "SMS Type"; Option)
        {
            OptionMembers = "Loan Balance",Other;
            ValuesAllowed = other;
        }
        field(6; "SMS Status"; Option)
        {
            OptionMembers = Pending,Sent,Cancelled;
        }
        field(10; Message; Text[1100])
        {
        }
        field(11; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(13; Status; Option)
        {
            OptionCaption = 'Open,Pending,Approved,Rejected';
            OptionMembers = Open,Pending,Approved,Rejected;
        }
        field(14; SentToServer; Boolean)
        {
        }
        field(15; "Managed By"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
            trigger OnValidate()
            var
                myInt: Integer;
                CustomerRec: Record Employee;
                GreenSmsLines: Record "SMS Lines";
                LineN: Integer;
            begin
                GreenSmsLines.Reset();
                GreenSmsLines.SetRange(No, rec.No);
                if GreenSmsLines.FindSet() then
                    GreenSmsLines.DeleteAll();
                CustomerRec.Reset();
                CustomerRec.SetRange(CustomerRec."Global Dimension 1 Code", rec."Global Dimension 1 Code");
                if CustomerRec.Find('-') then
                    repeat

                        LineN := 0;
                        GreenSmsLines.Reset();
                        if GreenSmsLines.FindSet() then
                            LineN := GreenSmsLines.Count;
                        GreenSmsLines.Init();
                        GreenSmsLines."Client No" := CustomerRec."No.";
                        GreenSmsLines.No := rec.No;
                        GreenSmsLines."entry No" := LineN + 1;
                        GreenSmsLines.Validate(GreenSmsLines."Client No");
                        GreenSmsLines."Phone No" := CustomerRec."Phone No.";
                        GreenSmsLines.Insert();
                    until CustomerRec.Next() = 0;


            end;
        }
        field(16; "Global Dimension 1 Code"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
            trigger OnValidate()
            var
                myInt: Integer;
                CustomerRec: Record Employee;
                GreenSmsLines: Record "SMS Lines";
                LineN: Integer;
            begin
                GreenSmsLines.Reset();
                GreenSmsLines.SetRange(No, rec.No);
                if GreenSmsLines.FindSet() then
                    GreenSmsLines.DeleteAll();
                CustomerRec.Reset();
                CustomerRec.SetFilter("Phone No.", '<>%1', '');
                CustomerRec.SetRange(CustomerRec."Global Dimension 1 Code", rec."Global Dimension 1 Code");
                if CustomerRec.Find('-') then
                    repeat

                        LineN := 0;
                        GreenSmsLines.Reset();
                        if GreenSmsLines.FindSet() then
                            LineN := GreenSmsLines.Count;
                        GreenSmsLines.Init();
                        GreenSmsLines."Client No" := CustomerRec."No.";
                        GreenSmsLines.No := rec.No;
                        GreenSmsLines."entry No" := LineN + 1;
                        GreenSmsLines.Validate(GreenSmsLines."Client No");
                        GreenSmsLines."Phone No" := CustomerRec."Phone No.";
                        GreenSmsLines.Insert();
                    until CustomerRec.Next() = 0;


            end;
        }
    }
    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        if No = '' then begin
            NoSetup.Get;
            NoSetup.TestField(NoSetup."SMS No. Series");
            NoSeriesMgt.InitSeries(NoSetup."SMS No. Series", xRec."No. Series", 0D, No, "No. Series");
        end;
        "Date Entered" := Today;
        "Time Entered" := Time;
        "Entered By" := UserId;
    end;

    var
        NoSetup: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
