page 52193477 "Perf Rating Scale"
{
    Caption = 'Performance Rating Scale';
    PageType = List;
    SourceTable = "Perf Rating Scale";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field(Rating; Rec.Rating) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Min Achievement %"; Rec."Min Achievement %") { ApplicationArea = All; }
            }
        }
    }
}
