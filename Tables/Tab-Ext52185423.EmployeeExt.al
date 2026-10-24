namespace PBO.PBO;

using Microsoft.HumanResources.Employee;

tableextension 50004 "Employee Ext" extends Employee
{
    fields
    {
        field(10000; "ON Leave"; Boolean)
        {
            Caption = '';
            DataClassification = ToBeClassified;
        }
        field(10001; Remarks; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(10002; "Login Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Available,"Out of Office";
        }
    }
}
