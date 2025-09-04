 
   
table 50103 "Committee Cub Members"
{
    Caption = 'Committee Cub Members';
    DataClassification = CustomerContent;
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
                // Committeerec: Record "HR Disciplinary Cases NCA";
            begin
                Board.Reset();
                Board.SetRange("No.", rec."Employee No");
                if Board.FindSet() then begin
                    Names := Board."First Name" + ' ' + Board."Middle Name" + ' ' + Board."Last Name";
                    Designation := Board."Job Title";
                    Email := Board."Company E-Mail";
                    "Phone Number" := Board."Phone No.";
                    Address := Board.Address;
                end;
               

            end;
        }
        field(4; Names; Text[250])
        {
            Editable = false;
            Caption = 'Full Name';
        }
        field(5; Designation; Text[250])
        {
            Caption = 'Designation';
            Editable = false;
        }
        field(6; Remarks; Text[200])
        {
            Caption = 'Remarks';
        }
        field(7; Role; Option)
        {
            OptionCaption = ' ,Chairman,Secretary,Member,Consultant';
            OptionMembers = " ",Chairman,Secretary,Member,Consultant;
            Caption = 'Role';
        }
        field(10; Email; Text[200])
        {
            Caption = 'Email';
        }
        field(11; "Phone Number"; Code[30])
        {
            Caption = 'Phone Number';
        }
        field(12; Address; Code[200])
        {
            Caption = 'Address';
        }
    }

    keys
    {
        key(Key1; "Commitee Code", "Employee No")
        {
            Clustered = true;
        }
    }

    fieldgroups { }
    
    var
        Board: Record Employee;
        Directors: Record Vendor;
}

