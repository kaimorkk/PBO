page 52193478 "Perf AI Goal Suggestions"
{
    Caption = 'AI Suggested Targets';
    PageType = StandardDialog;
    SourceTable = "Perf AI Goal Suggestion";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            field(Disclaimer; DisclaimerLbl)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                Style = Attention;
            }
            repeater(Suggestions)
            {
                field(Select; Rec.Select) { ApplicationArea = All; }
                field("Key Result Area"; Rec."Key Result Area") { ApplicationArea = All; }
                field("Target Description"; Rec."Target Description") { ApplicationArea = All; }
                field("Measurement Criteria"; Rec."Measurement Criteria") { ApplicationArea = All; }
                field("Target Value"; Rec."Target Value") { ApplicationArea = All; }
                field("Weightage %"; Rec."Weightage %") { ApplicationArea = All; }
                field("Workplan Line No."; Rec."Workplan Line No.") { ApplicationArea = All; Editable = false; }
                field(Rationale; Rec.Rationale) { ApplicationArea = All; Editable = false; }
            }
        }
    }

    procedure SetSuggestions(var TempSuggestion: Record "Perf AI Goal Suggestion" temporary)
    begin
        Rec.Copy(TempSuggestion, true);
    end;

    var
        DisclaimerLbl: Label 'AI-generated content may be incorrect. Review and edit each target before choosing OK; only selected rows are added to the goal.';
}
