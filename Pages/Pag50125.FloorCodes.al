 

page 50125 "Floor Codes"
{
    CardPageID = "Floor Description Card";
    Editable = false;
    PageType = List;
    SourceTable = "Floor Codes";
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                ShowCaption = false;
                field("Floor Code"; Rec."Floor Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    actions
    {
    }
}

