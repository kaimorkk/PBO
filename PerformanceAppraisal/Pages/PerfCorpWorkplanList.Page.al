page 52193463 "Perf Corp. Workplan List"
{
    Caption = 'Corporate Annual Workplans';
    PageType = List;
    SourceTable = "Perf Corporate Workplan";
    CardPageId = "Perf Corp. Workplan Card";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Fiscal Year"; Rec."Fiscal Year") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Approved by CEO"; Rec."Approved by CEO") { ApplicationArea = All; }
            }
        }
    }
}
