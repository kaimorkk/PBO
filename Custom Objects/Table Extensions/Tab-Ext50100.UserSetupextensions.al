namespace PBO.PBO;

using System.Security.User;
using Microsoft.Finance.Dimension;

tableextension 50100 "User Setup extensions" extends "User Setup"
{
    fields
    {
        field(50100; "Responsibility Center"; Code[50])
        {
            Caption = '';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(50101; "Global Dimension 1 Code"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(50102; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
}
