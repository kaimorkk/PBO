 

page 50117 Floor
{
    Caption = 'Property Lines';
    PageType = ListPart;
    SourceTable = Floor;

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Floor Code"; Rec."Floor Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Code';
                    NotBlank = true;
                }
                field("Property Type"; Rec."Property Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        //if "Property Type" = 'RESIDENTIAL' then
                        //CurrPage."Total Area sq ft".VISIBLE:=FALSE;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Floor Area sq ft"; Rec."Floor Area sq ft")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Area';
                    Editable = true;
                }
                field("Occupied Units"; Rec."Occupied Units")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Vacant Units"; Rec."Vacant Units")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Units"; Rec."Total Units")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;

                    trigger OnDrillDown()
                    begin
                        Rec.Validate("Floor Code");
                        unit.Reset;
                        unit.SetFilter(unit."Property No.", Rec."No.");
                        unit.SetFilter(unit."Floor Code", Rec."Floor Code");
                        PAGE.Run(Page::"Unit List", unit);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        unit: Record Unit;
}

