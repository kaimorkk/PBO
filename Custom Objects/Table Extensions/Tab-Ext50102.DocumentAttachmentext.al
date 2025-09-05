namespace PBO.PBO;

using Microsoft.Foundation.Attachment;

tableextension 50102 "Document Attachment ext" extends "Document Attachment"
{
    fields
    {
        field(50100; "Sponsor"; Text[100])
        {
            Caption = 'Sponsor';
            DataClassification = ToBeClassified;
        }
        field(50101; "Date Received"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
}
