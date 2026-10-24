report 52193426 "PBO Meeting Card Report"
{
    Caption = 'PBO Meeting Card Report';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/PBO Meeting Card Report.rdlc';

    dataset
    {
        dataitem(PBOMeetings; "PBO Meetings")
        {
            RequestFilterFields = "Meeting Code", "Meeting Date";
            column(Meeting_Code; "Meeting Code") { }
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(COMPANYNAME; CompanyInfo.Name) { }
            column(Address; CompanyInfo.Address) { }
            column(Meeting_Summary; "Meeting Summary") { }
            column(Meeting_Date; "Meeting Date") { }
            column(Meeting_Status; "Meeting Status") { }
            column(Meeting_Time; "Meeting Time") { }
            column(Date_captured; "Date captured") { }
            column(Captured_By; "Captured By") { }
            column(Document_Comment; "Document Comment") { }
            column(Brown_Bag; "Brown-Bag") { }
            column(Department; Department) { }


            dataitem(CommitteeCubMembers; "Committee Cub Members")
            {
                DataItemLink = "Commitee Code" = field("Meeting Code");
                column(Employee_No; "Employee No")
                {

                }
                column(Role; Role)
                {

                }
                column(Phone_Number; "Phone Number")
                {

                }

            }
        }
    }
    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.get;
        CompanyInfo.CalcFields(Picture);

    end;

    var
        CompanyInfo: Record "Company Information";
}
