namespace PBO.PBO;
using Microsoft.HumanResources.Employee;
using Microsoft.Foundation.NoSeries;
using System.Security.User;
using System.Utilities;
using System.Automation;


page 50134 "HR Leave Application Card"
{
    DeleteAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Workflow Process3,Workflow Process,Relievers,Documents,Approve Document';
    SourceTable = "HR Leave Application";
    ApplicationArea = All;
    Caption = 'HR Leave Application Card';
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                //Editable = page_editable;
                field("Application Code"; Rec."Application Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Application No';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Application No field.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Application Date field.';
                }
                label("Applicant Details")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StandardAccent;
                    StyleExpr = true;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic;
                    Caption = 'No.';
                    // Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Employee Name"; "Employee Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Name';
                    // Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Job Tittle"; Rec."Job Tittle")
                {
                    ApplicationArea = Basic;
                    Caption = 'Job Title';
                    // Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Job Title field.';
                }
                field(EmpDept; EmpDept)
                {
                    ApplicationArea = Basic;
                    Caption = 'Department';
                    // Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Department field.';
                }
                field(MyRecId; Rec.MyRecId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MyRecId field.';
                    Visible = false;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    Caption = 'Department';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Responsibility Center field.';
                }
                field(Supervisor; Rec.Supervisor)
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    // Visible = false;
                    ToolTip = 'Specifies the value of the Supervisor field.';
                }
                field("Supervisor Email"; Rec."Supervisor Email")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Supervisor Email field.';
                }
                label("**")
                {
                    ApplicationArea = Basic;
                    Caption = '*';
                    Visible = false;
                }
                field("Leave Type"; Rec."Leave Type")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Leave Type field.';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        rec."Days Applied" := 0;
                        rec."Start Date" := 0D;
                        Rec."Return Date" := 0D;
                    end;

                }
                field("Leave Plan"; "Leave Plan")
                {
                    ApplicationArea = all;
                    Visible = false;
                    Editable = IsAnnual;
                    ToolTip = 'Specifies the header plan Number for Annual Leaves';
                }

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("Days Applied"; Rec."Days Applied")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Days Applied field.';
                    trigger OnValidate()
                    begin
                        HREmp.RESET;
                        HREmp.SETRANGE("No.", "Employee No");
                        IF HREmp.FIND('-') THEN BEGIN
                            // rec.Acting := HREmp.Acting;
                            // rec."Position Acting" := HREmp."Job Title5";
                            // rec."Department acting" := HREmp."Department acting";
                            // rec."DEpartment acting Name" := HREmp."Department acting Name";
                        end;
                        HREmp.Get(Rec."Employee No");
                        if Rec."Leave Type" = 'ANNUAL' then begin
                            if Rec."Days Applied" > dLeft then
                                Message('Days applied cannot exceed leave balance for this leave');
                        end else begin
                            HRLeaveTypes.Reset();
                            HRLeaveTypes.SetRange(HRLeaveTypes.Code, Rec."Leave Type");
                            if HRLeaveTypes.Find('-') then
                                if Rec."Days Applied" > HRLeaveTypes.Days then
                                    Error('Days applied cannot exceed leave balance for this leave');

                        end;
                    end;
                }
                field("Return Date"; Rec."Return Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Return Date field.';
                }
                label("***")
                {
                    ApplicationArea = Basic;
                    Caption = '*';
                    Visible = false;
                }
                field(dAlloc; dAlloc)
                {
                    ApplicationArea = Basic;
                    Caption = 'Allocated days';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Allocated days field.';
                }
                field(dEarnd; dEarnd)
                {
                    ApplicationArea = Basic;
                    Caption = 'Total Leave Days';
                    Editable = false;
                    Visible = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Total Leave Days field.';
                }
                field(dTaken; dTaken)
                {
                    ApplicationArea = Basic;
                    Caption = 'Total Leave Taken';
                    Editable = false;
                    Visible = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Total Leave Taken field.';
                }
                field(dLeft; dLeft)
                {
                    ApplicationArea = Basic;
                    Caption = 'Leave Balance';
                    Editable = false;
                    Enabled = false;
                    Style = Strong;
                    Visible = false;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Leave Balance field.';
                }
                label("*****")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                    Caption = '*';
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Posted field.';
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Posted By field.';
                }
                field("Postedd By"; Rec."Postedd By")
                {
                    ApplicationArea = Basic;
                    Caption = 'Posted By';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted By field.';
                }
                field("Date Posted"; Rec."Date Posted")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Date Posted field.';
                }
                field("Time Posted"; Rec."Time Posted")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Time Posted field.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    ToolTip = 'Specifies the value of the User ID field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Editable = true;
                    Style = Attention;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field(LeaveLineNum; LeaveLineNum)
                {
                    Caption = 'Leave Plan Ln';
                    ApplicationArea = all;
                    Visible = false;
                }
                field(PlannerHeaderNum; PlannerHeaderNum)
                {
                    ApplicationArea = all;
                    Visible = false;
                    Caption = 'Planner Header No.';
                }
            }
            group("More Leave Details")
            {
                Caption = 'More Leave Details';
                Editable = Page_Editable;
                field("Cell Phone Number"; Rec."Cell Phone Number")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Cell Phone Number field.';
                }
                field("E-mail Address"; Rec."E-mail Address")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the E-mail Address field.';
                }
                field("Details of Examination"; Rec."Details of Examination")
                {
                    ApplicationArea = Basic;
                    // Importance = Promoted;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Details of Examination field.';
                }
                field("Date of Exam"; Rec."Date of Exam")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Date of Exam field.';
                }
                field("Applicant Comments"; Rec."Applicant Comments")
                {
                    ApplicationArea = Basic;
                    ToolTip = 'Specifies the value of the Applicant Comments field.';
                }
                field(Names; Rec.Names)
                {
                    ApplicationArea = Basic;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Names field.';
                }
                field("Number of Previous Attempts"; Rec."Number of Previous Attempts")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Number of Previous Attempts field.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Control1102755004; Outlook) { }
        }
    }

    actions
    {
        area(Navigation)
        {
            group("&Show")
            {
                Caption = '&Show';
                action(Relievers)
                {
                    ApplicationArea = Basic;
                    Caption = 'Relievers';
                    Image = EditCustomer;
                    Promoted = true;
                    PromotedCategory = Category6;
                    // RunObject = page "HR Leave Relievers";
                    // RunPageLink = "Document No" = field("Application Code"),
                    //               "Applicant No" = field("Employee No");
                    ToolTip = 'Executes the Relievers action.';
                }
            }
            group("Workflow process")
            {
                Caption = 'Workflow process';

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic;
                    Caption = '&Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Executes the &Send Approval Request action.';
                    trigger OnAction()
                    var
                        approvalentry: Record "Approval Entry";
                    begin
                        Rec.TestField(Status, rec.Status::New);
                        if Confirm('Send this Application for Approval?', true) = false then
                            exit;
                        VarVariant := Rec;
                        if CustomApprovals.CheckApprovalsWorkflowEnabled(VarVariant) then
                            CustomApprovals.OnSendDocForApproval(VarVariant);
                        approvalentry.Reset();
                        approvalentry.SetRange("Document No.", rec."Application Code");
                        if approvalentry.findfirst then begin
                            repeat
                                approvalentry."Sender ID" := rec."User ID";
                                approvalentry.Modify();
                            until approvalentry.next = 0;
                        end;
                        //ApprovalMgt.SendLeaveAppApprovalReq(Rec);
                    end;
                }
                action(testcode)
                {
                    ApplicationArea = Basic;
                    Caption = 'testcode';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    Visible = false;
                    PromotedCategory = Category5;
                    ToolTip = 'Executes the &Send Approval Request action.';
                    trigger OnAction()
                    var
                    // haki: Codeunit "Haki kwa ground Api";
                    begin
                        // haki.GetAvailableEmployees(0D, 0D);

                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic;
                    Caption = '&Cancel Approval Request';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Executes the &Cancel Approval Request action.';
                    trigger OnAction()
                    begin
                        Rec.TestField(Status, rec.Status::"Pending Approval");
                        VarVariant := Rec;
                        CustomApprovals.OnCancelDocApprovalRequest(VarVariant);
                        // ApprovalMgt.CancelLeaveAppRequest(Rec,true,true);
                    end;
                }
                action("Reject Approval")
                {
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    ToolTip = 'Executes the &Reject Approval Request action.';
                    PromotedCategory = Category5;
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = Basic;
                    Caption = '&Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Executes the &Approvals action.';
                    trigger OnAction()
                    var
                        //ApprovalEntries: Page "Approval Entries";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin

                        ApprovalsMgmt.OpenApprovalEntriesPage(rec.RecordId);
                    end;
                }
                action("Mark As Approved")
                {
                    ApplicationArea = Basic;
                    Caption = 'Mark As Approved';
                    Promoted = true;
                    PromotedCategory = Category8;
                    Visible = false;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Mark As Approved action.';
                    trigger OnAction()
                    begin

                        HRLeaveApp.Reset();
                        HRLeaveApp.SetRange(HRLeaveApp."Application Code", Rec."Application Code");
                        if HRLeaveApp.Find('-') then begin
                            AppEntry.Reset();
                            AppEntry.SetRange(AppEntry."Document No.", HRLeaveApp."Application Code");
                            if AppEntry.Find('-') then begin
                                repeat
                                    if AppEntry.Status <> AppEntry.Status::Approved then
                                        Error('Leave Application %1 must be Approved', Rec."Application Code");
                                until AppEntry.Next() = 0;
                                Rec.Status := Rec.Status::Approved;
                                Rec.Modify();
                            end;
                        end;
                    end;
                }

                action(Attachment1)
                {
                    ApplicationArea = Basic;
                    Caption = 'Attachments';
                    Ellipsis = false;
                    PromotedCategory = Category7;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Visible = false;
                    Image = Attach;
                    trigger OnAction()
                    var
                        // DMSInt: Record DMS;
                        userSetup: Record "User Setup";
                    begin
                        userSetup.reset;
                        userSetup.SetRange(userSetup."User ID", USERID);
                        IF userSetup.Find('-') THEN begin

                            //  Hyperlink('http://greencom-svr020:2023/_Layouts/15/Pages/EDMS.aspx?DocNo=' + Rec."Application Code" + '&Department=' + userSetup."Global Dimension 2 Code" + '&DocName=Leave+Application');
                        end;
                    end;
                }
                action(Attachment)
                {
                    ApplicationArea = Basic;
                    Caption = 'Document Attachments';
                    Ellipsis = false;
                    Image = Attach;
                    InFooterBar = false;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = false;
                    // RunObject = page "HR Leave Documents";
                    // RunPageLink = "Doc No." = field("Application Code");
                    RunPageOnRec = false;
                    ToolTip = 'Executes the Attachment action.';
                    trigger OnAction()
                    var
                    //D//MSInt: Record DMS;
                    begin
                        // DMSInt.Reset();
                        // DMSInt.SetRange(DMSInt."DMS Link Type", DMSInt."DMS Link Type"::Leave);
                        // if DMSInt.Find('-') then
                        //     Hyperlink(DMSInt."DMS Link Path" + Rec."Application Code");
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        // rec.CalcFields("Employee Name");
    end;

    trigger OnAfterGetRecord()
    begin
        //Get Employee Details
        FillVariables();
        // rec.CalcFields("Employee Name");

        //Get leave statistics
        Rec.GetLeaveStats(Rec."Leave Type");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        HRLeaveApp.Reset();
        HRLeaveApp.SetRange(HRLeaveApp."User ID", UserId);
        HRLeaveApp.SetRange(HRLeaveApp.Status, Rec.Status::New);
        if HRLeaveApp.Find('-') then begin
            repeat
                UnUsedDocs := UnUsedDocs + HRLeaveApp."Application Code" + Spacer;
            until HRLeaveApp.Next() = 0;

            CounterVar := HRLeaveApp.Count;
            if CounterVar > 0 then
                Error(Text0001, UnUsedDocs);
        end;
    end;

    trigger OnOpenPage()
    begin
        //GetLeaveStats("Leave Type");

        Rec.GetLeaveStats(Rec."Leave Type");
        // rec.CalcFields("Employee Name");

        /*
        //To make The OnLeave boolean field in Employee card False
        VALIDATE("Start Date") ;

       HREmp.RESET;
       HREmp.SETRANGE(HREmp."No.","Employee No") ;
       IF HREmp.FIND('-') THEN
       BEGIN
          IF "Return Date"<=TODAY  THEN
          MESSAGE (FORMAT("Return Date"));
          REPEAT
            HREmp."On Leave":= FALSE
           // HREmp.MODIFY
          UNTIL HREmp.NEXT=0;
          HREmp.MODIFY
       END
         */

        Page_Editable := true;
        if Rec.Status <> Rec.Status::New then
            Page_Editable := false;

    end;

    var
        HREmp: Record Employee;
        EmpJobDesc: Text[50];
        SupervisorName: Text[60];
        //SMTP: Codeunit "SMTP Mail";
        URL: Text[500];
        dAlloc: Decimal;
        dEarnd: Decimal;
        dTaken: Decimal;
        dLeft: Decimal;
        cReimbsd: Decimal;
        cPerDay: Decimal;
        cbf: Decimal;
        HRSetup: Record "HR Setup";
        EmpDept: Text[30];
        VarVariant: Variant;
        CustomApprovals: Codeunit "Custom Approvals Codeunit";
        //ApprovalMgt: Codeunit "Export F/O Consolidation";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",None,"Payment Voucher","Petty Cash",Imprest,Requisition,ImprestSurrender,Interbank,Receipt,"Staff Claim","Staff Advance",AdvanceSurrender,"Bank Slip",Grant,"Grant Surrender","Employee Requisition","Leave Application","Training Requisition","Transport Requisition",JV,"Grant Task","Concept Note",Proposal,"Job Approval","Disciplinary Approvals",GRN,Clearence,Donation,Transfer,PayChange,Budget,GL,"Cash Purchase","Leave Reimburse",Appraisal,Inspection,Closeout,"Lab Request",ProposalProjectsAreas,"Leave Carry over","IB Transfer",EmpTransfer,LeavePlanner,HrAssetTransfer;
        HRLeaveLedgerEntries: Record "HR Leave Ledger Entries";
        EmpName: Text[70];
        ApprovalComments: Page "Approval Comments";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        UserSetup: Record "User Setup";
        varDaysApplied: Integer;
        HRLeaveTypes: Record "HR Leave Types";
        // BaseCalendarChange: Record "Base Calendar Change";
        ReturnDateLoop: Boolean;
        mSubject: Text[250];
        ApplicantsEmail: Text[30];
        LeaveGjline: Record "HR Leave Journal Line";
        "LineNo.": Integer;
        sDate: Record Date;
        Customized: Record "HR Calendar List";
        HRLeavePeriods: Record "HR Leave Periods";
        HRJournalBatch: Record "HR Leave Journal Batch";
        CounterVar: Integer;
        Text0001: Label 'There are still some NEW DOCUMENTS(s) on your account which have not been used. Please list & select the pending document to use.  //%1';
        UnUsedDocs: Text;
        Spacer: Label ' , ';
        HRLeaveApp: Record "HR Leave Application";
        ApprovalEntries: Page "Approval Entries";
        AppEntry: Record "Approval Entry";
        OldStatus: Text;
        NewStatus: Text;
        // LeaveLog: Record "Leave Log";
        Var_Counter: Integer;
        Page_Editable: Boolean;
        COMP: Label 'COMPASSIONATE';
        RC_COMP: Label 'COM-LEAVE';
        MaturityDate: Date;
        FiscalStart: Date;


    procedure FillVariables()
    begin
        //Initialize Variables
        EmpDept := '';
        EmpJobDesc := '';
        EmpName := '';
        SupervisorName := '';

        //Employee Details
        HREmp.Reset();

        if HREmp.Get(Rec."Employee No") then begin
            EmpName := HREmp."Search Name";
            //MESSAGE(EmpName);
            EmpDept := HREmp."Global Dimension 2 Code";
        end;

        //Approver Details
        HREmp.Reset();
        HREmp.SetRange(HREmp."User ID", Rec.Supervisor);
        if HREmp.Find('-') then
            SupervisorName := HREmp."Search Name";
    end;

    local procedure MyProcedure()
    var
        myInt: Integer;
    begin

    end;


    procedure TESTFIELDS()
    begin
        Rec.TestField(Rec."Leave Type");
        Rec.TestField(Rec."Days Applied");
        Rec.TestField(Rec."Start Date");
        //TESTFIELD(Supervisor);
        if Rec."Leave Type" = COMP then
            Rec."Responsibility Center" := RC_COMP;
        Rec.Modify();
        Commit();
    end;


    procedure DetermineLeaveReturnDate(var fBeginDate: Date; var fDays: Decimal) fReturnDate: Date
    begin
        varDaysApplied := fDays;
        fReturnDate := fBeginDate;
        repeat
            if Rec.DetermineIfIncludesNonWorking(Rec."Leave Type") = false then begin
                fReturnDate := CalcDate('1D', fReturnDate);
                if Rec.DetermineIfIsNonWorking(fReturnDate) then
                    varDaysApplied := varDaysApplied + 1
                else
                    varDaysApplied := varDaysApplied;
                varDaysApplied := varDaysApplied - 1
            end
            else begin
                fReturnDate := CalcDate('1D', fReturnDate);
                varDaysApplied := varDaysApplied - 1;
            end;
        until varDaysApplied = 0;
        exit(fReturnDate);
    end;


    procedure DetermineIfIncludesNonWorking(var fLeaveCode: Code[10]): Boolean
    begin
        if HRLeaveTypes.Get(fLeaveCode) then
            if HRLeaveTypes."Inclusive of Non Working Days" = true then
                exit(true);
    end;


    procedure DetermineIfIsNonWorking(var bcDate: Date) Isnonworking: Boolean
    begin
        /*
        HRSetup.FIND('-');
        HRSetup.TESTFIELD(HRSetup."Base Calendar");
        BaseCalendarChange.SETFILTER(BaseCalendarChange."Base Calendar Code",HRSetup."Base Calendar");
        BaseCalendarChange.SETRANGE(BaseCalendarChange.Date,bcDate);

        IF BaseCalendarChange.FIND('-') THEN BEGIN
        IF BaseCalendarChange.Nonworking = FALSE THEN
        ERROR('Start date can only be a Working Day Date');
        EXIT(TRUE);
        END;
        */

        /*
        Customized.RESET;
        Customized.SETRANGE(Customized.Date,bcDate);
        IF Customized.FIND('-') THEN BEGIN
            IF Customized."Non Working" = TRUE THEN
            EXIT(TRUE)
            ELSE
            EXIT(FALSE);
        END;
         */

    end;


    procedure DeterminethisLeaveEndDate(var fDate: Date) fEndDate: Date
    begin
        ReturnDateLoop := true;
        fEndDate := fDate;
        if fEndDate <> 0D then begin
            fEndDate := CalcDate('-1D', fEndDate);
            while (ReturnDateLoop) do
                if Rec.DetermineIfIsNonWorking(fEndDate) then
                    fEndDate := CalcDate('-1D', fEndDate)
                else
                    ReturnDateLoop := false;
        end;
        exit(fEndDate);
    end;


    procedure NotifyApplicant()
    begin
        /*
        HREmp.GET("Employee No");
        HREmp.TESTFIELD(HREmp."Company E-Mail");

        //GET E-MAIL PARAMETERS FOR GENERAL E-MAILS
        HREmailParameters.RESET;
        HREmailParameters.SETRANGE(HREmailParameters."Associate With",HREmailParameters."Associate With"::"Interview Invitations");
        IF HREmailParameters.FIND('-') THEN
        BEGIN


             HREmp.TESTFIELD(HREmp."Company E-Mail");
             SMTP.CreateMessage(HREmailParameters."Sender Name",HREmailParameters."Sender Address",HREmp."Company E-Mail",
             HREmailParameters.Subject,'Dear'+' '+ HREmp."First Name" +' '+
             HREmailParameters.Body+' '+"Application Code"+' '+ HREmailParameters."Body 2",TRUE);
             SMTP.Send();


        MESSAGE('Leave applicant has been notified successfully');
        END;
        */

    end;


    procedure GetLeaveStats(LeaveType: Text[50])
    var
        Leavecalender: Code[30];
    begin
        Rec.FindMaturityDate();
        Rec."Maturity Date" := MaturityDate;
        Rec."Fiscal Start Date" := FiscalStart;

        //MESSAGE('%1%2',MaturityDate,FiscalStart);

        dAlloc := 0;
        dEarnd := 0;
        dTaken := 0;
        dLeft := 0;
        cReimbsd := 0;
        cPerDay := 0;
        Leavecalender := '';
        cbf := 0;
        HREmp.Reset();
        if HREmp.Get(Rec."Employee No") then begin
            Leavecalender := HREmp."Leave Calendar";
            HRSetup.Get();
            //Filter by Leave Type Selected
            HREmp.SetFilter(HREmp."Leave Type Filter", LeaveType);

            //Filter by Leave Period from HR Setup
            //HREmp.SETFILTER(HREmp."Date Filter",'%1..%2',HRSetup."Leave Posting Period[FROM]",HRSetup."Leave Posting Period[TO]");


            HRLeaveLedgerEntries.Reset();
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Staff No.", Rec."Employee No");
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Entry Type", HRLeaveLedgerEntries."Leave Entry Type"::Positive);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Type", LeaveType);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Calendar Code", HREmp."Leave Calendar");
            if HRLeaveLedgerEntries.Find('-') then begin
                dAlloc := 0;
                repeat
                    dAlloc := HRLeaveLedgerEntries."No. of days" + dAlloc;
                until HRLeaveLedgerEntries.Next() = 0;
            end;

            HRLeaveLedgerEntries.Reset();
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Staff No.", Rec."Employee No");
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Entry Type", HRLeaveLedgerEntries."Leave Entry Type"::Negative);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Type", LeaveType);
            HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Leave Calendar Code", HREmp."Leave Calendar");
            //HRLeaveLedgerEntries.SetRange(HRLeaveLedgerEntries."Posting Date", HRSetup."Leave Posting Period[FROM]", HRSetup."Leave Posting Period[TO]");

            if HRLeaveLedgerEntries.Find('-') then begin
                dTaken := 0;
                repeat
                    dTaken := HRLeaveLedgerEntries."No. of days" + dTaken;
                until HRLeaveLedgerEntries.Next() = 0;
            end;

            //Leave Balance
            dEarnd := dAlloc + dTaken;
            dLeft := dAlloc + dTaken;

            //Reimbursed Leave Days
            cbf := HREmp."Reimbursed Leave Days";
            cReimbsd := HREmp."Cash - Leave Earned";
            cPerDay := HREmp."Cash per Leave Day";

        end;
    end;

    local procedure UpdateContrls()
    begin
    end;

    procedure IsAnnualLeave()
    var
        myInt: Integer;

    begin
        if rec."Leave Type" = 'ANNUAL' then
            IsAnnual := true
        else
            IsAnnual := false;
    end;


    procedure FindMaturityDate()
    var
        AccPeriod: Record "HR Leave Periods";
    begin
        AccPeriod.Reset();
        AccPeriod.SetRange(AccPeriod."Starting Date", 0D, Today);
        AccPeriod.SetRange(AccPeriod."New Fiscal Year", true);
        AccPeriod.SetRange(AccPeriod.Closed, false);
        if AccPeriod.Find('+') then begin
            //MESSAGE(FORMAT(AccPeriod."Starting Date"));
            FiscalStart := AccPeriod."Starting Date";
            MaturityDate := CalcDate('1Y', AccPeriod."Starting Date");
            MaturityDate := CalcDate('-1D', MaturityDate);
            //MESSAGE('New Maturity Date %1',FORMAT(MaturityDate));
        end;
    end;

    var
        IsAnnual: Boolean;
}
