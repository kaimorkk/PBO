page 52193461 "Perf Appraisal Period List"
{
    Caption = 'Appraisal Periods';
    PageType = List;
    SourceTable = "Perf Appraisal Period";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Period Type"; Rec."Period Type") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Target Setting Deadline"; Rec."Target Setting Deadline") { ApplicationArea = All; }
                field("Self-Assessment Deadline"; Rec."Self-Assessment Deadline") { ApplicationArea = All; }
                field("Supervisor Review Deadline"; Rec."Supervisor Review Deadline") { ApplicationArea = All; }
                field(Closed; Rec.Closed) { ApplicationArea = All; }
            }
        }
    }
}
