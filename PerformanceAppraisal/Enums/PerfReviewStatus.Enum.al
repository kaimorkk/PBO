enum 52193429 "Perf Review Status"
{
    Extensible = true;
    Caption = 'Performance Review Status';

    value(0; Open) { Caption = 'Open'; }
    value(1; "Self-Assessment Submitted") { Caption = 'Self-Assessment Submitted'; }
    value(2; "Supervisor Review Submitted") { Caption = 'Supervisor Review Submitted'; }
    value(3; "Objected by Employee") { Caption = 'Objected by Employee'; }
    value(4; "Escalated to Next Level Supervisor") { Caption = 'Escalated to Next Level Supervisor'; }
    value(5; "Consolidated by HR") { Caption = 'Consolidated by HR Manager'; }
    value(6; "Submitted to HRAC") { Caption = 'Submitted to HR Appraisal Committee (EPMC)'; }
    value(7; "Recommendation Submitted to ED") { Caption = 'Committee Recommendation Submitted to ED'; }
    value(8; Closed) { Caption = 'Closed'; }
    // FRD Figure 2 steps. Appended (not inserted) so existing review data keeps its meaning.
    value(9; "Returned to Employee") { Caption = 'Returned to Employee for Amendment'; }
    value(10; "Approved by Next Level Supervisor") { Caption = 'Approved by Next Level Supervisor'; }
    value(11; "Escalated to GM HR") { Caption = 'Escalated to GM HR (Unresolved Objection)'; }
    value(12; "Submitted to GM HR&A") { Caption = 'Submitted to GM HR & Administration'; }
}
