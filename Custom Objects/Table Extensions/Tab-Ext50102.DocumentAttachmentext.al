namespace PBO.PBO;

using Microsoft.Foundation.Attachment;

tableextension 50002 "Document Attachment ext" extends "Document Attachment"
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
        field(50103; Version; Text[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}
