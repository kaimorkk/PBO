table 50129 "HR E-Mail Parameters"
{
    Caption = 'HR E-Mail Parameters';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Associate With"; Option)
        {
            Caption = 'Associate With';
            OptionCaption = ',Vacancy Advertisements,Interview Invitations,General,HR Jobs,Regret Notification,Reliever Notifications,Leave Notifications,Activity Notifications,Send Payslip Email,Training Notifications,Leave Approval Notifications,Retirement,Procurement';
            OptionMembers = ,"Vacancy Advertisements","Interview Invitations",General,"HR Jobs","Regret Notification","Reliever Notifications","Leave Notifications","Activity Notifications","Send Payslip Email","Training Notifications","Leave Approval Notifications",Retirement,Procurement;
        }
        field(2; "Sender Name"; Text[50])
        {
            Caption = 'Sender Name';
        }
        field(3; "Sender Address"; Text[60])
        {
            Caption = 'Sender Address';
        }
        field(4; "Recipient 1"; Text[50])
        {
            Caption = 'Recipient 1';
        }
        field(5; Subject; Text[100])
        {
            Caption = 'Subject';
        }
        field(6; Body; Text[100])
        {
            Caption = 'Body';
        }
        field(7; "Body 2"; Text[250])
        {
            Caption = 'Body 2';
        }
        field(8; HTMLFormatted; Boolean)
        {
            Caption = 'HTMLFormatted';
        }
        field(9; "Body 3"; Text[250])
        {
            Caption = 'Body 3';
        }
        field(10; "Body 4"; Text[250])
        {
            Caption = 'Body 4';
        }
        field(11; "Body 5"; Text[250])
        {
            Caption = 'Body 5';
        }
        field(12; "Template Path"; Text[100])
        {
            Caption = 'Template Path';
        }
        field(13; "Payslip Message"; Text[100])
        {
            Caption = 'Payslip Message';
        }
        field(14; "Recipient 2"; Text[50])
        {
            Caption = 'Recipient 2';
        }
        field(15; "Recipient 3"; Text[50])
        {
            Caption = 'Recipient 3';
        }
    }

    keys
    {
        key(Key1; "Associate With")
        {
            Clustered = true;
        }
    }

    fieldgroups { }
}
