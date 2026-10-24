page 52193467 "Perf Goal Line Subform"
{
    Caption = 'Key Result Areas / Targets';
    PageType = ListPart;
    SourceTable = "Perf Goal Line";
    AutoSplitKey = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Workplan Line No."; Rec."Workplan Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The cascaded workplan objective this target contributes to (FRD 2.v).';
                }
                field("Key Result Area"; Rec."Key Result Area") { ApplicationArea = All; }
                field("Target Description"; Rec."Target Description") { ApplicationArea = All; }
                field("Measurement Criteria"; Rec."Measurement Criteria") { ApplicationArea = All; }
                field("Target Value"; Rec."Target Value") { ApplicationArea = All; }
                field("Weightage %"; Rec."Weightage %") { ApplicationArea = All; }
                field("Workplan No."; Rec."Workplan No.") { ApplicationArea = All; Visible = false; }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.InitFromHeader();
    end;
}
