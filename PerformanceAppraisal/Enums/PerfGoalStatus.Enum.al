enum 52193425 "Perf Goal Status"
{
    Extensible = true;
    Caption = 'Performance Goal Status';

    value(0; Open) { Caption = 'Open'; }
    value(1; "Pending Supervisor Review") { Caption = 'Pending Supervisor (HOD) Review'; }
    value(2; "Returned for Amendment") { Caption = 'Returned for Amendment'; }
    value(3; "Approved by Supervisor") { Caption = 'Approved by Supervisor (HOD)'; }
    value(4; "Submitted to CEO") { Caption = 'Submitted to CEO'; }
    value(5; Finalized) { Caption = 'Finalized'; }
}
