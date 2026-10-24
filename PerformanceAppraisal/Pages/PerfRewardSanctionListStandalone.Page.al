page 52193474 "Perf Reward Sanction List St."
{
    Caption = 'Rewards and Sanctions';
    PageType = List;
    SourceTable = "Perf Reward Sanction";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Review No."; Rec."Review No.") { ApplicationArea = All; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Proposed by (Supervisor)"; Rec."Proposed by (Supervisor)") { ApplicationArea = All; }
                field("Proposed Date"; Rec."Proposed Date") { ApplicationArea = All; }
                field("HRAC Status"; Rec."HRAC Status") { ApplicationArea = All; }
                field("Recommended To"; Rec."Recommended To") { ApplicationArea = All; }
            }
        }
    }
}
