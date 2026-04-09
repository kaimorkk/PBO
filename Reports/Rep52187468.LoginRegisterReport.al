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
            column(LoginDate; "Login Date") { }
            column(Login_Time; "Login Time") { }
            column(Logout_Time; "Logout Time") { }
            column(Duration__Hours_; "Duration (Hours)") { }
            column(Work_Summary; "Work Summary") { }
            column(Location_Name; "Location Name") { }
            column(CI_Address; CompanyAdre)
            {
                //IncludeCaption = true;
            }
            column(Compname; CompnayName)
            {

            }
            column(CI_Address2; CompInfo."Address 2")
            {
                IncludeCaption = true;
            }
            column(CI_City; CompInfo.City)
            {
                IncludeCaption = true;
            }
            column(CI_EMail; Compmail)
            {
                // IncludeCaption = true;
            }
            column(picture; CompInfo.Picture)
            {

            }
            column(Login_Type; "Login Type")
            {

            }
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                LoginDate := '';
                if "Login Date" <> 0D then
                    LoginDate := GlobalFunc.FormatDate("Login Date");


            end;
        }
    }
    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        CompInfo.Get();
        CompInfo.CalcFields(CompInfo.Picture);
        CompanyAdre := CompInfo.Address;
        CompnayName := CompInfo.Name;
        CompPhone := CompInfo."Phone No.";
        Compmail := CompInfo."E-Mail";

    end;

    var

        CompInfo: Record "Company Information";
        CompanyAdre: Text;
        CompnayName: Text;
        CompPhone: Text;
        EndDAteCon: Text;
        Compmail: Text;
        LoginDate: Text;
        GlobalFunc: Codeunit "Global Functions";


    // No custom request page defined — RequestFilterFields will provide filters for Login Date and User ID.
}
