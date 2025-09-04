namespace PBO.PBO;

using Microsoft.Purchases.Vendor;

tableextension 50101 "Vendor Extenstions" extends Vendor
{
    fields
    {
        field(50000; "Vendor Type"; Option)
        {
            OptionCaption = 'Trade,Director,Insurance,Fleet,Person,Staff,Institution,Landlord';
            OptionMembers = Trade,Director,Insurance,Fleet,Person,Staff,Institution,Landlord;
        }
    }
}
