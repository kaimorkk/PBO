

Table 50142 "portal User"
{
    Caption = 'Portal User';

    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "User Name"; Text[60])
        {
            DataClassification = ToBeClassified;
            Description = 'User Names shall by default be email addresses. However, for scalability, we maintain a separate authentication email just in case we use a different User name';
        }
        field(3; "Full Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Authentication Email"; Text[80])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("Authentication Email");
            end;
        }
        field(5; "Mobile Phone No."; Text[300])
        {
            DataClassification = ToBeClassified;

            // trigger OnValidate()
            // var
            //     Char: dotnet Char;
            //     i: Integer;
            // begin
            //     for i := 1 to StrLen("Mobile Phone No.") do
            //       if Char.IsLetter("Mobile Phone No."[i]) then
            //         Error(PhoneNoCannotContainLettersErr);
            // end;
        }
        field(6; State; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Enabled,Disabled';
            OptionMembers = Enabled,Disabled;
        }
        field(7; "Change Password"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Record Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ',Vendor,Customer,Employee,Job Applicant';
            OptionMembers = ,Vendor,Customer,Employee,"Job Applicant";
        }
        field(9; "Record ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Password Value"; Text[30])
        {
            DataClassification = ToBeClassified;
            Description = 'Disbale Read rights to this field on NAV. Have the field masked. For first time batch user creation, the RANDOM string generation function on NAV shall be used';
            ExtendedDatatype = None;
        }
        field(11; "Last Modified Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Student Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; PasswordChanged; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; Notified; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Notification Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Id Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(19; FirstName; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(20; LastName; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(21; MiddleName; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Updated By"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Updated On"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(24; Emailsent; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Notified On"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        PhoneNoCannotContainLettersErr: label 'You cannot enter letters in this field.';
        Students: Record Customer;
}

