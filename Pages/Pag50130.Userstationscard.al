 
 
   page 50130 "User Station Card"
{
    PageType = Card;
    SourceTable = "User Stations";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Custodian To"; Rec."Custodian To")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Station Code"; Rec."Station Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Station Name"; Rec."Station Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                { 
                    ApplicationArea = Basic, Suite; 
                }
                field("Can Create New"; Rec."Can Create New")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Can Issue"; Rec."Can Issue")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Can Edit File Card";Rec."Can Edit File Card")
                {
                    ApplicationArea = Basis, Suite;
                }
            }
        }
    }

    actions
    {
    }
}

