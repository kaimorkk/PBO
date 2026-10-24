enum 52193426 "Perf HRAC Status"
{
    Extensible = true;
    Caption = 'HR Appraisal Committee Status';

    value(0; Pending) { Caption = 'Pending Review'; }
    value(1; Approved) { Caption = 'Approved'; }
    value(2; Rejected) { Caption = 'Rejected'; }
    value(3; Moderated) { Caption = 'Moderated'; }
}
