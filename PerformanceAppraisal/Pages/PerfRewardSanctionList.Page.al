page 52193473 "Perf Reward Sanction List"
{
    Caption = 'Rewards / Sanctions';
    PageType = ListPart;
    SourceTable = "Perf Reward Sanction";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; Visible = false; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Proposed by (Supervisor)"; Rec."Proposed by (Supervisor)") { ApplicationArea = All; }
                field("Proposed Date"; Rec."Proposed Date") { ApplicationArea = All; }
                field("HRAC Status"; Rec."HRAC Status") { ApplicationArea = All; }
                field("HRAC Comments"; Rec."HRAC Comments") { ApplicationArea = All; }
                field("Recommended To"; Rec."Recommended To") { ApplicationArea = All; }
                field("Final Decision"; Rec."Final Decision") { ApplicationArea = All; }
                field("Final Decision By"; Rec."Final Decision By") { ApplicationArea = All; }
                field("Decision Date"; Rec."Decision Date") { ApplicationArea = All; }
                field("Letter Generated"; Rec."Letter Generated") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Moderate)
            {
                Caption = 'Record HRAC Moderation';
                ApplicationArea = All;
                Image = Approve;
                ToolTip = 'Set HRAC Status, HRAC Comments and Recommended To on the line, then choose this action.';

                trigger OnAction()
                var
                    LetterMgt: Codeunit "Perf Letter Generation Mgt";
                begin
                    CurrPage.SaveRecord();
                    LetterMgt.ModerateByHRAC(Rec, Rec."HRAC Status", Rec."HRAC Comments", Rec."Recommended To");
                end;
            }
            action(RecordDecision)
            {
                Caption = 'Record Final Decision';
                ApplicationArea = All;
                Image = Completed;
                ToolTip = 'Records the decision of the appropriate authority entered in Final Decision.';

                trigger OnAction()
                var
                    LetterMgt: Codeunit "Perf Letter Generation Mgt";
                begin
                    CurrPage.SaveRecord();
                    LetterMgt.RecordFinalDecision(Rec, Rec."Final Decision");
                end;
            }
            action(PrintLetter)
            {
                Caption = 'Print Letter';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                var
                    RewardSanction: Record "Perf Reward Sanction";
                begin
                    RewardSanction := Rec;
                    RewardSanction.SetRecFilter();
                    Report.RunModal(Report::"Perf Appraisal Letter", true, false, RewardSanction);
                end;
            }
        }
    }
}
