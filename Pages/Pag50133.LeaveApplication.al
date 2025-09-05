  
page 50133 "HR Leave Applications List"
{
    ApplicationArea = Basic;
    CardPageId = "HR Leave Application Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "HR Leave Application";
    UsageCategory = Lists;
    Caption = 'HR Leave Applications List';
    layout
    {
        area(Content)
        {
            repeater(Control1102755000)
            {
                Editable = false;
                field("Application Code"; Rec."Application Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Application No';
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Application No field.';
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Employee No field.';
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Employee Name field.';
                }
                field("Leave Type"; Rec."Leave Type")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Leave Type field.';
                }
                field("Days Applied"; Rec."Days Applied")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Days Applied field.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("Return Date"; Rec."Return Date")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Return Date field.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the End Date field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Style = Attention;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic;
                    Caption = 'Department';
                    ToolTip = 'Specifies the value of the Responsibility Center field.';
                }
            }
        }
        area(FactBoxes)
        {
            // part(Control1102755006; "HR Leave Applicaitons Factbox")
            // {
            //     SubPageLink = "No." = field("Employee No");
            // }
            systempart(Control1102755004; Outlook) { }
        }
    }

    actions { }

    trigger OnAfterGetRecord()
    begin
        HREmp.Reset();
        if HREmp.Get(Rec."Employee No") then
            EmpName := HREmp."Search Name"
        else
            EmpName := 'n/a';
    end;

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Rec."User ID", UserId);

        // Report.Run(Report::"Change Approved Leave Apps", false, false);
    end;

    var
        EmpName: Text;
        HREmp: Record Employee;
        // ChangeApprovedLeaveApps: Report "Change Approved Leave Apps";


    procedure TESTFIELDS()
    begin
        Rec.TestField(Rec."Leave Type");
        Rec.TestField(Rec."Days Applied");
        Rec.TestField(Rec."Start Date");
        Rec.TestField(Rec.Reliever);
        Rec.TestField(Rec.Supervisor);
    end;


    // procedure TestLeaveFamily()
    // var
    //     LeaveFamily: Record "HR Leave Family Groups";
    //     LeaveFamilyEmployees: Record "HR Leave Family Employees";
    //     Employees: Record Employee;
    // begin
    //     LeaveFamilyEmployees.SetRange(LeaveFamilyEmployees."Employee No", Rec."Employee No");
    //     if LeaveFamilyEmployees.FindSet() then //find the leave family employee is associated with
    //         repeat
    //             LeaveFamily.SetRange(LeaveFamily.Code, LeaveFamilyEmployees.Family);
    //             LeaveFamily.SetFilter(LeaveFamily."Max Employees On Leave", '>0');
    //             if LeaveFamily.FindSet() then //find the status other employees on the same leave family
    //               begin
    //                 Employees.SetRange(Employees."No.", LeaveFamilyEmployees."Employee No");
    //                 Employees.SetRange(Employees."Leave Status", Employees."Leave Status"::" ");
    //                 if Employees.Count > LeaveFamily."Max Employees On Leave" then
    //                     Error('The Maximum number of employees on leave for this family has been exceeded, Contact th HR manager for more information');
    //             end
    //         until LeaveFamilyEmployees.Next() = 0;
    // end;
}
