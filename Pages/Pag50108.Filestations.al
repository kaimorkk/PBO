namespace PBO.PBO;


page 50108 "Task Stations"
{
    PageType = List;
    SourceTable = "Task Stations";
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    Caption = 'Task Stations';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Station No."; Rec."Station No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Station Code"; Rec."Station Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Responsibility Centre"; Rec."Responsibility Centre")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Duration (Hr)"; Rec."Duration (Hr)")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

