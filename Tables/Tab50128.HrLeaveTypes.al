 
table 50128 "HR Leave Types"
{
    LookupPageId = "HR Leave Types";
    Caption = 'HR Leave Types';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Code"; Code[40])
        {
            NotBlank = true;
            Caption = 'Code';
        }
        field(2; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(3; Days; Decimal)
        {
            Caption = 'Days';
        }
        field(4; "Acrue Days"; Boolean)
        {
            Caption = 'Acrue Days';
        }
        field(5; "Unlimited Days"; Boolean)
        {
            Caption = 'Unlimited Days';
        }
        field(6; Gender; Option)
        {
            OptionCaption = 'Both,Male,Female';
            OptionMembers = Both,Male,Female;
            Caption = 'Gender';
        }
        field(7; Balance; Option)
        {
            OptionCaption = 'Ignore,Carry Forward,Convert to Cash';
            OptionMembers = Ignore,"Carry Forward","Convert to Cash";
            Caption = 'Balance';
        }
        field(8; "Inclusive of Holidays"; Boolean)
        {
            Caption = 'Inclusive of Holidays';
        }
        field(9; "Inclusive of Saturday"; Boolean)
        {
            Caption = 'Inclusive of Saturday';
        }
        field(10; "Inclusive of Sunday"; Boolean)
        {
            Caption = 'Inclusive of Sunday';
        }
        field(11; "Off/Holidays Days Leave"; Boolean)
        {
            Caption = 'Off/Holidays Days Leave';
        }
        field(12; "Max Carry Forward Days"; Decimal)
        {
            Caption = 'Max Carry Forward Days';
        }
        field(13; "Inclusive of Non Working Days"; Boolean)
        {
            Caption = 'Inclusive of Non Working Days';
        }
        field(14; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }
        field(15; "Carry Forward Allowed"; Boolean)
        {
            Caption = 'Carry Forward Allowed';
        }
        field(16; "Fixed Days"; Boolean)
        {
            Caption = 'Fixed Days';
        }
        field(17; "Allow Edit No. of Days?"; Boolean)
        {
            Caption = 'Allow Edit No. of Days?';
        }
        field(18; "Apply Once Per FY?"; Boolean)
        {
            Caption = 'Apply Once Per FY?';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups { }
}
