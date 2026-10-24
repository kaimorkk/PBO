page 52193469 "Perf Migating Factor List St."
{
    Caption = 'Mitigating Factors';
    PageType = List;
    SourceTable = "Perf Mitigating Factor";
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
                field("Factor Type"; Rec."Factor Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Corrective Action"; Rec."Corrective Action") { ApplicationArea = All; }
            }
        }
    }
}
