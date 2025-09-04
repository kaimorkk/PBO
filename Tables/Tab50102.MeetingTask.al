 
table 50102 "Meeting Task"
{
    Caption = 'Meetings Task';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Commitee Code"; Code[20])
        {
            NotBlank = true;
            Caption = 'Code';
        }
        field(2; "Employee No"; Code[30])
        {
            NotBlank = true;
            TableRelation = employee."No.";
            Caption = 'Employee No.';
            trigger OnValidate()
            var
                 
            begin
                Board.Reset();
                Board.SetRange("No.", rec."Employee No");
                if Board.FindSet() then begin
                    Names := Board."First Name" + ' ' + Board."Middle Name" + ' ' + Board."Last Name";
                    Email := Board."Company E-Mail";
                    "Phone Number" := Board."Phone No.";
                end;


            end;
        }
        field(4; Names; Text[250])
        {
            Editable = false;
            Caption = 'Full Name';
        }

        field(6; Task; Text[100])
        {
            Caption = 'Task';
        }

        field(10; Email; Text[200])
        {
            Caption = 'Email';
        }
        field(11; "Phone Number"; Code[30])
        {
            Caption = 'Phone Number';
        }
    }

    fieldgroups { }
    

    var
        Board: Record Employee;
        Directors: Record Vendor;




}
