namespace PBO.PBO;

using System.Security.User;

pageextension 50100 "Extends User setup" extends "User Setup"
{
    layout
    {
        addafter("User ID")
        {
            field("Responsibility Center"; "Responsibility Center")
            {
                ApplicationArea = Basic;
            }
            field("Global Dimension 1 Code"; "Global Dimension 1 Code")
            {
                ApplicationArea = all;

            }
        }
    }

}
