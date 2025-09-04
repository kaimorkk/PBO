page 50116 "Task MVT Remarks Card"
{
    PageType = Card;
    Caption = 'Task Movement Card';
    SourceTable = "Task Movement Remarks";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Stage; Rec.Stage)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Responsibility Centre"; Rec."Responsibility Centre")
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

