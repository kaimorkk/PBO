table 52193482 "Perf Setup"
{
    Caption = 'Performance Appraisal Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Self Assessment Weight %"; Decimal)
        {
            Caption = 'Self-Assessment Weight %';
            InitValue = 40;
        }
        field(3; "Supervisor Assessment Weight %"; Decimal)
        {
            Caption = 'Supervisor Assessment Weight %';
            InitValue = 60;
        }
        field(4; "Score Rounding Precision"; Decimal)
        {
            Caption = 'Score Rounding Precision';
            InitValue = 0.01;
        }
        field(5; "Reminder Days Before Deadline"; Integer)
        {
            Caption = 'Reminder Days Before Deadline';
            InitValue = 5;
        }
        field(6; "Commendation Letter Threshold"; Decimal)
        {
            Caption = 'Commendation Letter Score Threshold';
            InitValue = 4.5;
        }
        field(7; "Warning Letter Threshold"; Decimal)
        {
            Caption = 'Warning Letter Score Threshold';
            InitValue = 2;
        }
        field(8; "Goal No. Series"; Code[20])
        {
            Caption = 'Goal No. Series';
            TableRelation = "No. Series";
        }
        field(9; "Review No. Series"; Code[20])
        {
            Caption = 'Review No. Series';
            TableRelation = "No. Series";
        }
        field(10; "Notify Supervisor on Submit"; Boolean)
        {
            Caption = 'Notify Supervisor when Staff Submits';
            InitValue = true;
        }
        field(11; "Notify Employee on Return"; Boolean)
        {
            Caption = 'Notify Employee when Returned';
            InitValue = true;
        }
        field(12; "Enforce Approver Identity"; Boolean)
        {
            Caption = 'Enforce Approver Identity';
            InitValue = true;
            // When on, each workflow step can only be performed by the user linked
            // (Employee."User ID") to the employee holding that role.
        }
        field(13; "HR Manager No."; Code[20])
        {
            Caption = 'HR Manager (Employee No.)';
            TableRelation = Employee."No.";
        }
        field(14; "GM HR&A No."; Code[20])
        {
            Caption = 'GM HR & Administration (Employee No.)';
            TableRelation = Employee."No.";
        }
        field(15; "Send Email Alerts"; Boolean)
        {
            Caption = 'Send Email Alerts';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
