 
page 50127 "Files Locations Card"
{
    Caption = 'Files Locations Card';
    PageType = Card;
    SourceTable = "Task Locations";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Building; Rec.Building)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Building field.';
                }
                field(Floor; Rec.Floor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Floor field.';
                }
                // field(Location; Rec.Location)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Location field.';
                // }
                field(Town; Rec.Town)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Town field.';
                }
            }
        }
    }
}
