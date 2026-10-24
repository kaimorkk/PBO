codeunit 52193438 "Perf Employee Mgt"
{
    // Resolves the people behind each appraisal role (staff, HOD, next level supervisor,
    // CEO, HR Manager, GM HR&A) and checks the signed-in user holds the role a step needs.
    // Users are linked to employees through Employee."User ID".

    trigger OnRun()
    begin
    end;

    procedure CheckCurrentUserIs(EmployeeNo: Code[20]; RoleCaption: Text)
    var
        Employee: Record Employee;
    begin
        if not IsIdentityEnforced() then
            exit;
        if EmployeeNo = '' then
            Error(RoleNotAssignedErr, RoleCaption);
        Employee.Get(EmployeeNo);
        if Employee."User ID" <> CurrentUserCode() then
            Error(WrongUserErr, RoleCaption, Employee."No.", Employee.FullName(), UserId());
    end;

    procedure CheckCurrentUserIsCEO()
    begin
        if not IsIdentityEnforced() then
            exit;
        CheckCurrentUserIs(GetCEONo(), CEORoleTxt);
    end;

    procedure CheckCurrentUserIsHRManager()
    var
        PerfSetup: Record "Perf Setup";
    begin
        if not IsIdentityEnforced() then
            exit;
        PerfSetup.Get();
        CheckCurrentUserIs(PerfSetup."HR Manager No.", HRManagerRoleTxt);
    end;

    procedure CheckCurrentUserIsGMHRA()
    var
        PerfSetup: Record "Perf Setup";
    begin
        if not IsIdentityEnforced() then
            exit;
        PerfSetup.Get();
        CheckCurrentUserIs(PerfSetup."GM HR&A No.", GMHRARoleTxt);
    end;

    /// <summary>
    /// HRAC secretariat steps may be recorded by either the HR Manager or the GM HR and Administration.
    /// </summary>
    procedure CheckCurrentUserIsHROfficial()
    var
        PerfSetup: Record "Perf Setup";
        CurrentEmployeeNo: Code[20];
    begin
        if not IsIdentityEnforced() then
            exit;
        PerfSetup.Get();
        CurrentEmployeeNo := GetEmployeeNoForCurrentUser();
        if (CurrentEmployeeNo = '') or
           not (CurrentEmployeeNo in [PerfSetup."HR Manager No.", PerfSetup."GM HR&A No."])
        then
            Error(NotHROfficialErr, UserId());
    end;

    procedure GetEmployeeNoForCurrentUser(): Code[20]
    var
        Employee: Record Employee;
    begin
        Employee.SetRange("User ID", CurrentUserCode());
        if Employee.FindFirst() then
            exit(Employee."No.");
    end;

    procedure GetCEONo(): Code[20]
    var
        Employee: Record Employee;
    begin
        Employee.SetRange("Perf Is CEO", true);
        if Employee.FindFirst() then
            exit(Employee."No.");
    end;

    procedure GetHRManagerNo(): Code[20]
    var
        PerfSetup: Record "Perf Setup";
    begin
        if PerfSetup.Get() then
            exit(PerfSetup."HR Manager No.");
    end;

    procedure GetGMHRANo(): Code[20]
    var
        PerfSetup: Record "Perf Setup";
    begin
        if PerfSetup.Get() then
            exit(PerfSetup."GM HR&A No.");
    end;

    /// <summary>
    /// The next level supervisor (FRD 3.iii) is the appraisal supervisor of the HOD.
    /// </summary>
    procedure GetSupervisorOf(EmployeeNo: Code[20]): Code[20]
    var
        Employee: Record Employee;
    begin
        if Employee.Get(EmployeeNo) then
            exit(Employee."Perf Supervisor No.");
    end;

    procedure GetEmail(EmployeeNo: Code[20]): Text
    var
        Employee: Record Employee;
    begin
        if not Employee.Get(EmployeeNo) then
            exit('');
        if Employee."Company E-Mail" <> '' then
            exit(Employee."Company E-Mail");
        exit(Employee."E-Mail");
    end;

    procedure GetName(EmployeeNo: Code[20]): Text
    var
        Employee: Record Employee;
    begin
        if Employee.Get(EmployeeNo) then
            exit(Employee.FullName());
    end;

    /// <summary>
    /// Fills the organisational analysis columns used by the FRD section 4 reports.
    /// </summary>
    procedure FillReportBuffer(var Buffer: Record "Perf Report Buffer" temporary; EmployeeNo: Code[20])
    var
        Employee: Record Employee;
    begin
        Buffer."Employee No." := EmployeeNo;
        if not Employee.Get(EmployeeNo) then
            exit;
        Buffer."Employee Name" := CopyStr(Employee.FullName(), 1, MaxStrLen(Buffer."Employee Name"));
        Buffer.Designation := CopyStr(Employee."Job Title", 1, MaxStrLen(Buffer.Designation));
        Buffer.Department := Employee."Global Dimension 1 Code";
        Buffer.Directorate := Employee."Perf Directorate Code";
        Buffer.Region := Employee."Perf Region Code";
        Buffer.Grade := Employee."Perf Grade";
    end;

    local procedure IsIdentityEnforced(): Boolean
    var
        PerfSetup: Record "Perf Setup";
    begin
        if not PerfSetup.Get() then
            exit(false);
        exit(PerfSetup."Enforce Approver Identity");
    end;

    local procedure CurrentUserCode(): Code[30]
    begin
        exit(CopyStr(UpperCase(UserId()), 1, 30));
    end;

    var
        WrongUserErr: Label 'This step must be performed by the %1 (%2 %3). You are signed in as %4.', Comment = '%1 = role, %2 = employee no., %3 = employee name, %4 = user id';
        RoleNotAssignedErr: Label 'No employee is assigned as %1. Set it up before continuing.', Comment = '%1 = role';
        NotHROfficialErr: Label 'Only the HR Manager or GM HR & Administration set up in Performance Appraisal Setup can perform this step. You are signed in as %1.', Comment = '%1 = user id';
        CEORoleTxt: Label 'CEO';
        HRManagerRoleTxt: Label 'HR Manager';
        GMHRARoleTxt: Label 'GM HR & Administration';
}
