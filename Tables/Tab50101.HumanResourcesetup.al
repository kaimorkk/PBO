table 50101 "HR setup"
{
    Caption = 'HR setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Meeting Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(3; "File Entry No."; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(4; "Mail Entry No"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5; "Volume Entry No."; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(6; "File Batching No."; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(7; "Task Request"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(8; "Mail Request"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(9; "Leave Application Nos."; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(10; "Default Leave Posting Template"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Positive Leave Posting Batch"; Code[10])
        {
            // TableRelation = "HR Leave Journal Batch".Name;
            Caption = 'Positive Leave Posting Batch';
        }
        field(12; "Leave Posting Period[FROM]"; Date)
        {
            Caption = 'Leave Posting Period[FROM]';
        }
        field(13; "Leave Posting Period[TO]"; Date)
        {
            Caption = 'Leave Posting Period[TO]';
        }
        field(14; "Negative Leave Posting Batch"; Code[10])
        {
            TableRelation = "HR Leave Journal Batch".Name;
            Caption = 'Negative Leave Posting Batch';
        }
        field(15; "Leave Reimbursment Nos."; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(16; "Leave Template"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Base Calendar"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Leave Batch"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Allow Send Sms"; Boolean)
        {
            DataClassification = ToBeClassified;
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
