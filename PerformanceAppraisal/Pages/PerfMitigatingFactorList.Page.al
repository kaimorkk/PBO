page 52193468 "Perf Mitigating Factor List"
{
    Caption = 'Mitigating Factors';
    PageType = ListPart;
    SourceTable = "Perf Mitigating Factor";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Factor Type"; Rec."Factor Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Corrective Action"; Rec."Corrective Action") { ApplicationArea = All; }
                field("Recorded By"; Rec."Recorded By") { ApplicationArea = All; }
                field("Recorded Date"; Rec."Recorded Date") { ApplicationArea = All; }
            }
        }
    }
}
