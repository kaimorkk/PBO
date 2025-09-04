namespace PBO.PBO;


page 50115 "Task MVT Remarks"
{
    CardPageID = "Task MVT Remarks Card";
    PageType = List;
    Caption = 'Task Movement List';
    SourceTable = "Task Movement Remarks";
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
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

