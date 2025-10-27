namespace PBO.PBO;

using System.Security.User;
using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Location;
using Microsoft.HumanResources.Employee;

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
        field(60003; "Staff No"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
            trigger OnValidate()
            var
                myInt: Integer;
                EmployeeRe: Record Employee;
            begin
                EmployeeRe.Reset();
                EmployeeRe.SetRange("No.", rec."Staff No");
                if EmployeeRe.FindFirst() then begin
                    rec."Employee Name" := EmployeeRe."Search Name";
                    rec."E-Mail" := EmployeeRe."E-Mail";
                end;

            end;
        }
        field(7000; "Can Login"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
