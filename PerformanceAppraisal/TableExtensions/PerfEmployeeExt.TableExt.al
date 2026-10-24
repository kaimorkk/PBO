tableextension 52193423 "Perf Employee Ext" extends Employee
{
    fields
    {
        field(50100; "Perf Supervisor No."; Code[20])
        {
            Caption = 'Appraisal Supervisor (HOD) No.';
            TableRelation = Employee."No.";
            DataClassification = CustomerContent;
        }
        field(50101; "Perf Directorate Code"; Code[20])
        {
            Caption = 'Directorate Code';
            DataClassification = CustomerContent;
        }
        field(50102; "Perf Is HOD"; Boolean)
        {
            Caption = 'Is Head of Department';
            DataClassification = CustomerContent;
        }
        field(50103; "Perf Is CEO"; Boolean)
        {
            Caption = 'Is CEO';
            DataClassification = CustomerContent;
        }
        // FRD 4: coverage and score reports are analysed by region and grade.
        // Department is taken from Global Dimension 1 Code, as elsewhere in this app.
        field(50104; "Perf Region Code"; Code[20])
        {
            Caption = 'Region Code';
            DataClassification = CustomerContent;
        }
        field(50105; "Perf Grade"; Code[20])
        {
            Caption = 'Grade';
            DataClassification = CustomerContent;
        }
    }
}
