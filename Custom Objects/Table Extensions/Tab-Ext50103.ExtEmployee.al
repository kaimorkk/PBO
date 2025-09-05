namespace PBO.PBO;

using Microsoft.HumanResources.Employee;

tableextension 50103 "Ext Employee" extends Employee
{
    fields
    {
        field(60001; "Leave Calendar"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(60002; "User ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(60003; "Leave Type Filter"; Code[20])
        {
            TableRelation = "HR Leave Types";
            Caption = 'Leave Type Filter';
        }
        field(2008; "Reimbursed Leave Days"; Decimal)
        {
            CalcFormula = sum("HR Leave Ledger Entries"."No. of days" where("Staff No." = field("No."),
                                                                             Closed = const(false),
                                                                             "Leave Entry Type" = const(Positive),
                                                                             "Leave Type" = const('ANNUAL'),
                                                                             "Leave Posting Type" = const("Carry Forward"),
                                                                             "Leave Calendar Code" = field("Leave Calendar")));
            // "Leave Posting Description" = const('Carry Forward Days on07/04/23')));
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            Caption = 'Reimbursed Leave Days';
            Editable = false;
            trigger OnValidate()
            begin
                Validate("Allocated Leave Days");
            end;
        }
        field(2023; "Allocated Leave Days"; Decimal)
        {
            CalcFormula = sum("HR Leave Ledger Entries"."No. of days" where("Staff No." = field("No."),
                                                                             //"Posting Date" = filter('07/05/23..06/30/24'),
                                                                             Closed = const(false),
                                                                             "Leave Entry Type" = const(Positive),
                                                                             "Leave Type" = const('ANNUAL'),
                                                                             "Leave Calendar Code" = field("Leave Calendar"),
                                                                             "Leave Posting Type" = const(Normal)));
            //"Leave Posting Description" = const('Leave Allocation on07/14/24')));
            FieldClass = FlowField;
            Caption = 'Allocated Leave Days';
            Editable = false;
            trigger OnValidate()
            begin
                /*
               CALCFIELDS("Total Leave Taken");
               "Total (Leave Days)" := "Allocated Leave Days" + "Reimbursed Leave Days";
               //SUM UP LEAVE LEDGER ENTRIES
               "Leave Balance" := "Total (Leave Days)" - "Total Leave Taken";
               //TotalDaysVal := Rec."Total Leave Taken";
                  */

                // CalcFields("Leave Balance");
                // "Leave Balance" := "Total (Leave Days)" - "Total Leave Taken";

            end;
        }
        field(2007; "Cash - Leave Earned"; Decimal)
        {
            DecimalPlaces = 2 : 2;
            Caption = 'Cash - Leave Earned';
        }
        field(2009; "Cash per Leave Day"; Decimal)
        {
            DecimalPlaces = 2 : 2;
            Caption = 'Cash per Leave Day';
        }
        field(39003910; "Leave Balance"; Decimal)
        {

            CalcFormula = sum("HR Leave Ledger Entries"."No. of days" where("Staff No." = field("No."),
                                                                             Closed = const(false),
                                                                             "Leave Calendar Code" = field("Leave Calendar"),
                                                                             "Leave Type" = const('ANNUAL')));
            FieldClass = FlowField;
            DecimalPlaces = 2 : 2;
            Caption = 'Leave Balance';
            Editable = false;
        }
        field(2004; "Total Leave Taken"; Decimal)
        {
            CalcFormula = sum("HR Leave Ledger Entries"."No. of days" where("Staff No." = field("No."),
                                                                             "Leave Entry Type" = const(Negative),
                                                                             Closed = const(false),
                                                                             "Leave Type" = const('ANNUAL'),
                                                                             "Leave Calendar Code" = field("Leave Calendar")));
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            Caption = 'Total Leave Taken';
            Editable = false;
        }
        field(2006; "Total (Leave Days)"; Decimal)
        {
            DecimalPlaces = 2 : 2;
            Editable = false;
            Caption = 'Total (Leave Days)';
        }
    }
}
