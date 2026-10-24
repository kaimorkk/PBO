namespace PBO.PBO;

page 50019 "Sector/tags"
{
    ApplicationArea = All;
    Caption = 'Sector/tags';
    PageType = List;
    SourceTable = "Sector /Tags";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry no"; "Entry no")
                {
                    ApplicationArea = all;
                }
                field(Name; Name)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
