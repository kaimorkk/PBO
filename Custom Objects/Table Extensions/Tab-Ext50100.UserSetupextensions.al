namespace PBO.PBO;

using System.Security.User;
using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Location;

tableextension 50100 "User Setup extensions" extends "User Setup"
{
    fields
    {
        field(50100; "Responsibility Center"; Code[50])
        {
            Caption = '';
            DataClassification = ToBeClassified;
            TableRelation = "Responsibility Center";
        }
        field(50101; "Global Dimension 1 Code"; Code[40])
        {
            DataClassification = ToBeClassified;
            Caption = 'Department';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(50102; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(60001; "Adjust Leave Days"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
