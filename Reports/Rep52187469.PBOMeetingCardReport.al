report 52185426 "PBO Meeting Card Report"
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
            column(Meeting_Summary; "Meeting Summary") { }
            column(Meeting_Date; "Meeting Date") { }
            column(Meeting_Status; "Meeting Status") { }
            column(Meeting_Time; "Meeting Time") { }
            column(Date_captured; "Date captured") { }
            column(Captured_By; "Captured By") { }
            column(Document_Comment; "Document Comment") { }
            column(Brown_Bag; "Brown-Bag") { }
            column(Department; Department) { }

            dataitem(MeetingTask; "Meeting Task")
            {
                DataItemLink = "Commitee Code" = field("Meeting Code");
                column(Employee_No; "Employee No") { }
                column(Names; Names) { }
                column(Task; Task) { }
                column(Email; Email) { }
                column(Phone_Number; "Phone Number") { }
            }
        }
    }
}
