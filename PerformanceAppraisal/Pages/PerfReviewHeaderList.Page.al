page 52193476 "Perf Review Header List"
{
    Caption = 'Performance Reviews';
    PageType = List;
    SourceTable = "Perf Review Header";
    CardPageId = "Perf Review Header Card";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Supervisor No."; Rec."Supervisor No.") { ApplicationArea = All; }
                field("Period Code"; Rec."Period Code") { ApplicationArea = All; }
                field("Period Type"; Rec."Period Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Overall Score"; Rec."Overall Score") { ApplicationArea = All; }
                field("Rating Category"; Rec."Rating Category") { ApplicationArea = All; }
            }
        }
    }
}
