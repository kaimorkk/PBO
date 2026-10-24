page 52193464 "Perf Corp. Workplan Subform"
{
    Caption = 'Objectives / KPIs';
    PageType = ListPart;
    SourceTable = "Perf Corporate Workplan Line";
    AutoSplitKey = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Objective Description"; Rec."Objective Description") { ApplicationArea = All; }
                field("KPI Description"; Rec."KPI Description") { ApplicationArea = All; }
                field("Strategic Initiative"; Rec."Strategic Initiative") { ApplicationArea = All; }
                field("Target Value"; Rec."Target Value") { ApplicationArea = All; }
                field("Weightage %"; Rec."Weightage %") { ApplicationArea = All; }
                field("Responsible Directorate"; Rec."Responsible Directorate") { ApplicationArea = All; }
                field("Responsible Department"; Rec."Responsible Department") { ApplicationArea = All; }
                field("Cascaded to Directorate"; Rec."Cascaded to Directorate") { ApplicationArea = All; }
                field("Cascaded to Dept."; Rec."Cascaded to Dept.") { ApplicationArea = All; }
            }
        }
    }
}
