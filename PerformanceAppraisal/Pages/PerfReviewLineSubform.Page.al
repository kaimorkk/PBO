page 52193472 "Perf Review Line Subform"
{
    Caption = 'Review Lines';
    PageType = ListPart;
    SourceTable = "Perf Review Line";
    InsertAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Key Result Area"; Rec."Key Result Area") { ApplicationArea = All; }
                field("Target Description"; Rec."Target Description") { ApplicationArea = All; }
                field("Measurement Criteria"; Rec."Measurement Criteria") { ApplicationArea = All; }
                field("Weightage %"; Rec."Weightage %") { ApplicationArea = All; }
                field("Target Value"; Rec."Target Value") { ApplicationArea = All; }
                field("Actual Achievement"; Rec."Actual Achievement") { ApplicationArea = All; Editable = SelfEditable; }
                field("Achievement %"; Rec."Achievement %") { ApplicationArea = All; }
                field("Self Rating"; Rec."Self Rating") { ApplicationArea = All; Editable = SelfEditable; }
                field("Employee Comments"; Rec."Employee Comments") { ApplicationArea = All; Editable = SelfEditable; }
                field("Supervisor Rating"; Rec."Supervisor Rating") { ApplicationArea = All; Editable = SupervisorEditable; }
                field("Supervisor Comments"; Rec."Supervisor Comments") { ApplicationArea = All; Editable = SupervisorEditable; }
                field("Training Need"; Rec."Training Need") { ApplicationArea = All; Editable = SupervisorEditable; }
                field("Final Score"; Rec."Final Score") { ApplicationArea = All; }
            }
        }
    }

    /// <summary>
    /// Employee rates while drafting/returned; supervisor rates once the self-assessment is submitted.
    /// </summary>
    procedure SetEditMode(NewSelfEditable: Boolean; NewSupervisorEditable: Boolean)
    begin
        SelfEditable := NewSelfEditable;
        SupervisorEditable := NewSupervisorEditable;
        CurrPage.Update(false);
    end;

    var
        SelfEditable: Boolean;
        SupervisorEditable: Boolean;
}
