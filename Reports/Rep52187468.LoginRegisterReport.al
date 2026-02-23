report 52185425 "Login Register Report"
{
    Caption = 'Login Register Report';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/Login Register Report.rdlc';

    dataset
    {
        dataitem(LoginRegister; "Login Register")
        {
            RequestFilterFields = "Login Date", "User ID";
            DataItemTableView = sorting("Login Date");

            column(Entry_No_; "Entry No.") { }
            column(User_ID; "User ID") { }
            column(Login_Date; "Login Date") { }
            column(Login_Time; "Login Time") { }
            column(Logout_Time; "Logout Time") { }
            column(Duration__Hours_; "Duration (Hours)") { }
            column(Work_Summary; "Work Summary") { }
            column(Location_Name; "Location Name") { }
        }
    }

    // No custom request page defined — RequestFilterFields will provide filters for Login Date and User ID.
}
