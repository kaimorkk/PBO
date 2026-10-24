page 52193470 "Perf Report Buffer List"
{
    Caption = 'Report Results';
    PageType = List;
    SourceTable = "Perf Report Buffer";
    ApplicationArea = All;
    Editable = false;


    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Employee Name"; Rec."Employee Name") { ApplicationArea = All; }
                field(Designation; Rec.Designation) { ApplicationArea = All; }
                field(Grade; Rec.Grade) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(Directorate; Rec.Directorate) { ApplicationArea = All; }
                field(Region; Rec.Region) { ApplicationArea = All; }
                field("Period Code"; Rec."Period Code") { ApplicationArea = All; }
                field("Text Value 1"; Rec."Text Value 1") { ApplicationArea = All; Caption = 'Detail 1'; }
                field("Text Value 2"; Rec."Text Value 2") { ApplicationArea = All; Caption = 'Detail 2'; }
                field("Decimal Value 1"; Rec."Decimal Value 1") { ApplicationArea = All; Caption = 'Value 1'; }
                field("Decimal Value 2"; Rec."Decimal Value 2") { ApplicationArea = All; Caption = 'Value 2'; }
                field("Boolean Value 1"; Rec."Boolean Value 1") { ApplicationArea = All; Caption = 'Flag'; }
                field("Date Value 1"; Rec."Date Value 1") { ApplicationArea = All; Caption = 'Date'; }
            }
        }
    }
    procedure LoadBuffer(var SourceBuffer: Record "Perf Report Buffer" temporary)
    begin
        Rec.Copy(SourceBuffer, true);
        if Rec.FindFirst() then;
    end;

}
