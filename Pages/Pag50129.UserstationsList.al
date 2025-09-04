 

page 50129 "User Station List"
{
    CardPageID = "User Station Card";
    Editable = false;
    PageType = List;
    SourceTable = "User Stations";
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Id"; Rec."User Id")
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
                field("Can Create New"; Rec."Can Create New")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Can Issue"; Rec."Can Issue")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Can Edit File Card"; Rec."Can Edit File Card")
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

