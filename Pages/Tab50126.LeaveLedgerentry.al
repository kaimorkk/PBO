table 50126 "HR Leave Ledger Entries"
{
    Caption = 'Leave Ledger Entry';
    DrillDownPageId = "HR Leave Ledger Entries";
    LookupPageId = "HR Leave Ledger Entries";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Leave Calendar Code"; Code[20])
        {
            Editable = true;
            TableRelation = "HR Calendar".Code;
            Caption = 'Leave Calendar Code';
        }
        field(3; Closed; Boolean)
        {
            Caption = 'Closed';
        }
        field(4; "Staff No."; Code[20])
        {
            Caption = 'Staff No.';
            TableRelation = Employee."No.";
            trigger OnValidate()
            var
                myInt: Integer;
                HrEmpRec: Record Employee;
            begin
                HrEmpRec.Reset();
                HrEmpRec.SetRange("No.", rec."Staff No.");
                if HrEmpRec.FindFirst() then
                    rec."Staff Name" := HrEmpRec."Search Name";

            end;
        }
        field(5; "Staff Name"; Text[70])
        {
            Caption = 'Staff Name';
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; "Leave Entry Type"; Option)
        {
            Caption = 'Leave Entry Type';
            OptionMembers = Positive,Negative;
        }
        field(8; "Leave Approval Date"; Date)
        {
            Caption = 'Leave Approval Date';
        }
        field(9; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(10; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
        }
        field(11; "Job ID"; Code[20])
        {
            Caption = 'Job ID';
            //TableRelation = Table0.Field4;
        }
        field(12; "Job Group"; Code[20])
        {
            Caption = 'Job Group';
            //TableRelation = "HRBack To Office Form".Field23;
        }
        field(13; "Contract Type"; Code[20])
        {
            Caption = 'Contract Type';
        }
        field(14; "No. of days"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'No. of days';
        }
        field(15; "Leave Start Date"; Date)
        {
            Caption = 'Leave Start Date';
        }
        field(16; "Leave Posting Description"; Text[50])
        {
            Caption = 'Leave Posting Description';
        }
        field(17; "Leave End Date"; Date)
        {
            Caption = 'Leave End Date';
        }
        field(18; "Leave Return Date"; Date)
        {
            Caption = 'Leave Return Date';
        }
        field(20; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(21; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(22; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(23; "Posted By"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User;

        }
        field(24; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(25; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(26; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(27; "Index Entry"; Boolean)
        {
            Caption = 'Index Entry';
        }
        field(28; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(29; "Leave Recalled No."; Code[20])
        {
            Caption = 'Leave Application No.';
            TableRelation = "HR Leave Application"."Application Code" where("Employee No" = field("Staff No.")
                                                                             );
        }
        field(30; "Leave Type"; Code[20])
        {
            TableRelation = "HR Leave Types".Code;
            Caption = 'Leave Type';
        }
        field(31; "Is For Annual Leave"; Boolean)
        {
            Caption = 'Is For Annual Leave';
        }
        field(32; "Leave Posting Type"; Option)
        {
            OptionMembers = Normal,"Carry Forward";
            Caption = 'Leave Posting Type';
        }
        field(33; Batched; Boolean)
        {
            Caption = 'Batched';
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Leave Calendar Code", "Posting Date")
        {
            SumIndexFields = "No. of days";
        }
        key(Key3; "Leave Calendar Code", Closed, "Posting Date")
        {
            SumIndexFields = "No. of days";
        }
        key(Key4; "Staff No.", "Leave Calendar Code", Closed, "Posting Date")
        {
            SumIndexFields = "No. of days";
        }
        key(Key5; "Staff No.", Closed, "Posting Date") { }
        key(Key6; "Posting Date", "Leave Entry Type", "Staff No.")
        {
            SumIndexFields = "No. of days";
        }
        key(Key7; "Staff No.")
        {
            SumIndexFields = "No. of days";
        }
        key(Key8; "Leave Entry Type", "Staff No.", "Leave Type", Closed)
        {
            SumIndexFields = "No. of days";
        }
        key(Key9; "Leave Entry Type", "Staff No.", Closed)
        {
            Enabled = false;
            SumIndexFields = "No. of days";
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Leave Calendar Code", "Staff No.", "Staff Name", "Posting Date") { }
    }
}
