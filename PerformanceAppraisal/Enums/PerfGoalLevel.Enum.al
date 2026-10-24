enum 52193431 "Perf Goal Level"
{
    // Organisational level a goal document is set at. Directorate goals can be created once the
    // workplan is cascaded to Directorates; Department goals once it is cascaded to Departments.
    Extensible = true;
    Caption = 'Performance Goal Level';

    value(0; Department) { Caption = 'Department'; }
    value(1; Directorate) { Caption = 'Directorate'; }
}
