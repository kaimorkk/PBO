namespace PBO.PBO;

using Microsoft.Foundation.Attachment;

pageextension 50101 """Document Attachment Ext """ extends "Document Attachment Details"
{
    layout
    {
        addafter("File Extension")
        {
            field(Description; Description)
            {
                ApplicationArea = all;
            }
            field(Sponsor; Sponsor)
            {
                ApplicationArea = all;
            }
            field("Date Received"; "Date Received")
            {
                ApplicationArea = all;
            }
        }
    }
}
