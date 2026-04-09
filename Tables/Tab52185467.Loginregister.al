
table 52185467 "Login Register"
{
    DataClassification = CustomerContent;
    Caption = 'Task Register';
    DrillDownPageId = "Login Register List";
    LookupPageId = "Login Register List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
            //TableRelation = "User Setup";
        }
        field(3; "Login Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Login Date';
        }
        field(4; "Login Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Login Time';
        }
        field(5; "Logout Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Logout Time';
        }
        field(6; "Work Summary"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Work Summary';
        }
        field(7; "Duration (Hours)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Duration (Hours)';
            DecimalPlaces = 0 : 2;
        }
        field(8; Location; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
            trigger OnValidate()
            var
                myInt: Integer;
                Location: Record Location;
            begin
                Location.Reset();
                Location.SetRange(Code, rec.Location);
                if Location.FindFirst() then begin
                    rec."Location Name" := Location.Name;

                end;
            end;
        }
        field(9; "Login Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Task,Login;
            OptionCaption = 'Task, Login';
        }
        field(10; "Location Name"; Text[100])
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
        fieldgroup(DropDown; "Entry No.", "User ID", "Login Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Login Date" = 0D then
            "Login Date" := Today;
        if "Login Time" = 0T then
            "Login Time" := Time;
    end;

    trigger OnModify()
    begin
        CalculateDuration();
    end;

    local procedure CalculateDuration()
    var
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        DurationMs: BigInteger;
    begin
        if ("Login Time" <> 0T) and ("Logout Time" <> 0T) then begin
            StartDateTime := CreateDateTime("Login Date", "Login Time");
            EndDateTime := CreateDateTime("Login Date", "Logout Time");
            DurationMs := EndDateTime - StartDateTime;
            "Duration (Hours)" := DurationMs / 3600000; // Convert milliseconds to hours
        end;
    end;
}