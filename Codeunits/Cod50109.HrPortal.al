namespace PBO.PBO;
using System.Utilities;
using System.Security.User;
using System.IO;
using System.Automation;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Company;
using System.Email;
using Microsoft.Foundation.NoSeries;
using System.Environment;
using System;
using Microsoft.HumanResources.Employee;
using System.Text;

codeunit 52186451 "Hr Portal"
{
    var
        HRLeave: Record "HR Leave Application";
        VarVariant: Variant;
        CustomApprovals: Codeunit "Approvals Mgmt.";
        ApprovalMgt: Codeunit "Custom Approvals Codeunit";

    procedure ExportDoc(ShowFileDialog: Boolean; TAbleiD: Integer; RequistNo: Code[50]): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
        DocumentRec: Record "Document Attachment";
        TestDay: Integer;
        TestMOnth: Integer;
        TestYear: Integer;
        formatedtCode: Text;
        formartedYr: Text;
        DTest: Text;
        DmonthTest: Text;
        BaseImage: Text;
        InStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        RequistDate: Date;
        HrRequisitions: Record "HR Employee Requisitions";
    begin
        HrRequisitions.Reset();
        HrRequisitions.SetRange(HrRequisitions."Requisition No.", RequistNo);
        if HrRequisitions.FindFirst() then begin
            RequistDate := HrRequisitions."Requisition Date";
            if RequistDate <> 0D then begin
                TestDay := Date2DMY(RequistDate, 1);
                if TestDay < 10 then
                    DTest := '0' + Format(TestDay)
                else
                    DTest := Format(TestDay);
                TestMOnth := Date2DMY(RequistDate, 2);
                if TestMOnth < 10 then
                    DmonthTest := '0' + Format(TestMOnth)
                else
                    DmonthTest := Format(TestMOnth);
                TestYear := Date2DMY(RequistDate, 3);
                formartedYr := CopyStr(Format(TestYear), 3, 2);
                formatedtCode := FORMAT(DTest) + '/' + FORMAT(DmonthTest) + '/' + FORMAT(formartedYr);
                // Message(formatedtCode);
            end;
            DocumentRec.Reset();
            DocumentRec.SetRange("Table ID", TAbleiD);
            DocumentRec.SetRange("No.", formatedtCode);
            if DocumentRec.Find('-') then begin
                if DocumentRec.ID = 0 then
                    exit;
                // Ensure document has value in DB
                if not DocumentRec."Document Reference ID".HasValue() then
                    exit;
                //DocumentRec.OnBeforeExportAttachment(DocumentRec);
                FullFileName := DocumentRec."File Name" + '.' + DocumentRec."File Extension";
                TempBlob.CreateOutStream(DocumentStream);
                DocumentRec."Document Reference ID".ExportStream(DocumentStream);
                FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog);
                TempBlob.CreateInstream(InStr, TEXTENCODING::UTF8);
                BaseImage := Base64Convert.ToBase64(InStr);
                exit(BaseImage);
            end;
        end;
    end;


    procedure ApproveDocument(DocumentNo: Text; ApproverID: Text)
    var
        HrLeave: Record "HR Leave Application";
        UserSetup: Record "User Setup";
        ApproMGt: Codeunit "Approvals Mgmt.";
        VarVaraint: Variant;
        AppEntr: Record "Approval Entry";
        ApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "User Setup";
        Text004: Label 'Approval Setup not found.';


    begin
        //exit(ApproverID);
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", DocumentNo);
        ApprovalEntry.SetRange(ApprovalEntry."Approver ID", ApproverID);
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open); //added to prevent double approval of a document
        if ApprovalEntry.Find('-') then begin
            repeat
                if not ApprovalSetup.Get(ApproverID) then
                    Error(Text004);
                if ApprovalEntry."Approver ID" <> '' then
                    CustomApprovals.ApproveApprovalRequests(ApprovalEntry);
            // else begin
            //     UserSetup.Reset();
            //     UserSetup.SetRange("Approval Administrator", true);
            //     if UserSetup.FindFirst() then begin
            //         //ApprovalEntry.Status := ApprovalEntry.Status::Approved;
            //         ApprovalEntry."Approver ID" := UserSetup."User ID";
            //         ApprovalEntry.Modify();
            //         AppEntr.Reset();
            //         AppEntr.SetRange(AppEntr."Entry No.", ApprovalEntry."Entry No.");
            //         if AppEntr.FindFirst() then
            //             //commit;
            //             CustomApprovals.ApproveApprovalRequests(AppEntr)
            //     end;
            //     Message('Approved');
            //CustomApprovals.OnApproveApprovalRequest(ApprovalEntry);
            //end;
            until ApprovalEntry.Next() = 0;
        end;


    end;

    procedure UploadAttachedDocument(DocNo: Code[20]; FileName: Text[2000]; Attachment: BigText; TableID: Integer; Sponsor: Text; Description: Text);
    var
        myInt: Integer;
        DocAttachment: Record "Document Attachment";
        FromRecRef: RecordRef;
        FileManagement: Codeunit "File Management";
        Bytes: dotnet Array;
        // LegalH: Record "Legal Management";
        Convert: dotnet Convert;
        MemoryStream: dotnet MemoryStream;
        Ostream: OutStream;
        CurrPage: Page "Document Attachment Details";
        tableFound: Boolean;
        //  ICTReq: Record "ICT General Requisition Header";

        //  Induction: Record "HR Induction Schedule";
        //StaffInd: Record "HR Staff  Induction";
        PboMeetings: Record "PBO Meetings";
        meetingTask: Record "Meeting Task";
        FilesTab: Record "Files Table";
        LeaveApplication: Record "HR Leave Application";
    begin
        tableFound := false;
        if TableID = Database::"Files Table" then begin
            FilesTab.Reset();
            FilesTab.SetRange(FilesTab."Entry No.", DocNo);
            if FilesTab.Find('-') then begin
                FromRecRef.GETTABLE(FilesTab);
            end;
            tableFound := true;
        end;
        if TableID = Database::"PBO Meetings" then begin
            PboMeetings.Reset();
            PboMeetings.SetRange(PboMeetings."Meeting Code", DocNo);
            if PboMeetings.Find('-') then begin
                FromRecRef.GETTABLE(PboMeetings);
            end;
            tableFound := true;
        end;
        if TableID = Database::"HR Leave Application" then begin
            LeaveApplication.Reset();
            LeaveApplication.SetRange(LeaveApplication."Application Code", DocNo);
            if LeaveApplication.Find('-') then begin
                FromRecRef.GETTABLE(LeaveApplication);
            end;
            tableFound := true;
        end;
        if TableID = Database::"Meeting Task" then begin
            meetingTask.Reset();
            meetingTask.SetRange(meetingTask."Commitee Code", DocNo);
            if meetingTask.Find('-') then begin
                FromRecRef.GETTABLE(meetingTask);
            end;
            tableFound := true;
        end;
        if tableFound = true then begin
            if FileName <> '' then begin
                Clear(DocAttachment);
                DocAttachment.Init();
                DocAttachment.Validate("File Extension", FileManagement.GetExtension(FileName));
                DocAttachment.Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(FileName), 1, MaxStrLen(FileName)));
                DocAttachment.Validate("Table ID", FromRecRef.Number);
                DocAttachment.Validate("No.", DocNo);
                DocAttachment.Description := Description;
                DocAttachment.Sponsor := Sponsor;
                Bytes := Convert.FromBase64String(Attachment);
                MemoryStream := MemoryStream.MemoryStream(Bytes);
                DocAttachment."Document Reference ID".ImportStream(MemoryStream, '', FileName);
                DocAttachment.Insert(true);
                if FileManagement.DeleteServerFile(FileName) then;
            end else
                Error('No file to upload');
        end else
            Error('File not uploaded. No table filter found');

    end;

    procedure DeleteMeetingCub(Employecode: Code[30]; DocNo: Code[40]) Status: Boolean
    var
        myInt: Integer;
        Commitee: Record "Committee Cub Members";
        PboMeet: Record "PBO Meetings";
    begin
        PboMeet.Reset();
        PboMeet.SetRange("Meeting Code", DocNo);
        if PboMeet.FindFirst() then begin
            Commitee.Reset();
            Commitee.SetRange("Employee No", Employecode);
            Commitee.SetRange("Commitee Code", DocNo);
            if Commitee.FindFirst() then begin
                Commitee.Delete();
            end;
        end;

    end;

    procedure InsertCommiteeCub(Employecode: Code[30]; DocNo: Code[40]; Role: Integer): Boolean
    var
        myInt: Integer;
        Commitee: Record "Committee Cub Members";
        PboMeet: Record "PBO Meetings";
    begin
        PboMeet.Reset();
        PboMeet.SetRange("Meeting Code", DocNo);
        if PboMeet.FindFirst() then begin
            Commitee.Reset();
            Commitee.SetRange("Employee No", Employecode);
            Commitee.SetRange("Commitee Code", DocNo);
            if not Commitee.FindFirst() then begin
                Commitee.Init();
                Commitee."Commitee Code" := DocNo;
                Commitee."Employee No" := Employecode;
                Commitee.Validate(Commitee."Employee No");
                Commitee.Role := Role;
                Commitee.Insert();
            end else begin
                Commitee."Commitee Code" := DocNo;
                Commitee."Employee No" := Employecode;
                Commitee.Validate(Commitee."Employee No");
                Commitee.Role := Role;
                Commitee.Modify();
            end;
        end;





    end;

    procedure GetDocumentAttachment(tableId: Integer; No: Code[20]; RecID: Integer) BaseImage: Text
    var
        IStream: InStream;
        Bytes: dotnet Array;
        Convert: dotnet convert;
        MemoryStream: dotnet MemoryStream;
        TenantMedia: Record "Tenant Media";
        imageID: GUID;
        docAttachment: Record "Document Attachment";
    begin
        docAttachment.Reset();
        docAttachment.SetRange("Table ID", tableId);
        docAttachment.SetRange("No.", No);
        docAttachment.SetRange(ID, RecID);
        if docAttachment.find('-') then begin
            if docAttachment."Document Reference ID".Hasvalue then begin
                imageID := docAttachment."Document Reference ID".MediaId;
                IF TenantMedia.GET(imageID) THEN BEGIN
                    TenantMedia.CALCFIELDS(Content);
                    TenantMedia.Content.CreateInstream(IStream);
                    MemoryStream := MemoryStream.MemoryStream();
                    CopyStream(MemoryStream, IStream);
                    Bytes := MemoryStream.GetBuffer();
                    BaseImage := Convert.ToBase64String(Bytes);
                    exit(BaseImage);
                END;
            end;
        end;
    end;

    procedure InsertMeeting(MeetingSummary: Text[700]; MeetingDate: Date; MeetingTime: Time; DepartmentCode: Code[100]; IsBrownBag: Boolean; DocumentComment: Text[500]; UserCode: Code[200]): Code[40]
    var
        PBOMeeting: Record "PBO Meetings";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
    begin
        // Initialize new record
        PBOMeeting.Init();
        MembNoSeries.Get;
        MembNoSeries.TestField(MembNoSeries."Meeting Code");
        DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."Meeting Code", 0D, True);
        PBOMeeting."Meeting Code" := DocNo;
        // Set field values
        PBOMeeting."Meeting Summary" := MeetingSummary;
        PBOMeeting."Meeting Date" := MeetingDate;
        PBOMeeting."Meeting Time" := MeetingTime;
        PBOMeeting."Meeting Status" := PBOMeeting."Meeting Status"::Open;
        PBOMeeting.Department := DepartmentCode;
        PBOMeeting."Captured By" := UserCode;
        PBOMeeting.Validate(PBOMeeting.Department);
        PBOMeeting."Brown-Bag" := IsBrownBag;
        PBOMeeting."Document Comment" := DocumentComment;
        PBOMeeting.Insert();

        // Return the generated Meeting Code
        exit(PBOMeeting."Meeting Code");
    end;

    procedure UpdateMeeting(DocNo: Code[30]; MeetingSummary: Text[700]; MeetingDate: Date; MeetingTime: Time; DepartmentCode: Code[100]; IsBrownBag: Boolean; DocumentComment: Text[500]; UserCode: Code[200]): Boolean
    var
        PBOMeeting: Record "PBO Meetings";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    begin
        // Initialize new record
        PBOMeeting.Reset();
        PBOMeeting.SetRange("Meeting Code", DocNo);
        if PBOMeeting.FindFirst() then begin
            PBOMeeting."Meeting Summary" := MeetingSummary;
            PBOMeeting."Meeting Date" := MeetingDate;
            PBOMeeting."Meeting Time" := MeetingTime;
            //PBOMeeting."Meeting Status" := PBOMeeting."Meeting Status"::Open;
            PBOMeeting.Department := DepartmentCode;
            PBOMeeting."Captured By" := UserCode;
            PBOMeeting.Validate(PBOMeeting.Department);
            PBOMeeting."Brown-Bag" := IsBrownBag;
            PBOMeeting."Document Comment" := DocumentComment;
            if PBOMeeting.Modify() then
                exit(true)
            else
                exit(false);
        end else
            exit(false);
        // Return the generated Meeting Code
        //exit(PBOMeeting."Meeting Code");
    end;

    procedure DeleteAttachment(tableID: Integer; DoCNo: Code[50]): Boolean
    var
        myInt: Integer;
        DocAtt: Record "Document Attachment";
    begin
        DocAtt.Reset();
        DocAtt.SetRange("Table ID", tableID);
        DocAtt.SetRange("No.", DoCNo);
        if DocAtt.FindFirst() then begin
            DocAtt.Delete();
            exit(true);
        end else
            exit(false);

    end;

    procedure CancellLeaveApplication(ApplicationCode: Code[20])
    var
        myInt: Integer;
        leaveApp: Record "HR Leave Application";
        CustomApprovalMgt: Codeunit "Custom Approvals Codeunit";
    begin
        leaveApp.Reset();
        leaveApp.SetRange("Application Code", ApplicationCode);
        if leaveApp.FindFirst() then begin
            if (Today - leaveApp."Application Date") > 7 then
                Error('You cannot Cancell You Leave Application Since three Days has elapsed,Kindly Contact HR Department');
            VarVariant := leaveApp;
            CustomApprovalMgt.OnCancelDocApprovalRequest(VarVariant);
        end;

    end;

    procedure CreateLoginEntry(UserID: Code[50]; Worksummary: Text): Integer
    var
        LoginRegister: Record "Login Register";
        entryNo: Integer;
    begin
        LoginRegister.Reset();
        if LoginRegister.FindLast() then
            entryNo := LoginRegister."Entry No." + 1
        else
            entryNo := 1;
        LoginRegister.Reset();
        LoginRegister.SetRange("User ID", UserID);
        LoginRegister.SetRange(LoginRegister."Login Type", LoginRegister."Login Type"::Login);
        LoginRegister.SetRange("Login Date", Today);
        if not LoginRegister.FindFirst() then begin
            LoginRegister.Init();
            LoginRegister."Entry No." := entryNo;
            LoginRegister."User ID" := UserID;
            LoginRegister."Login Type" := LoginRegister."Login Type"::Login;
            LoginRegister."Work Summary" := Worksummary;
            LoginRegister."Login Date" := Today;
            LoginRegister."Login Time" := Time;
            LoginRegister.Insert(true);
            exit(LoginRegister."Entry No.");
        end;
    end;

    procedure CreateTaskRegister(UserID: Code[50]; Worksummary: Text; Location: Text): Integer
    var
        LoginRegister: Record "Login Register";
        entryNo: Integer;
    begin
        LoginRegister.Reset();
        if LoginRegister.FindLast() then
            entryNo := LoginRegister."Entry No." + 1
        else
            entryNo := 1;
        LoginRegister.Init();
        LoginRegister."Entry No." := entryNo;
        LoginRegister."User ID" := UserID;
        LoginRegister."Work Summary" := Worksummary;
        LoginRegister."Login Date" := Today;
        LoginRegister.Location := Location;
        LoginRegister.Validate(LoginRegister.Location);
        LoginRegister."Login Type" := LoginRegister."Login Type"::Task;
        LoginRegister."Login Time" := Time;
        LoginRegister.Insert(true);
        exit(LoginRegister."Entry No.");
    end;

    procedure UpdateTaskRegister(DocN: Integer; UserID: Code[50]; Worksummary: Text; Location: Text): Boolean
    var
        LoginRegister: Record "Login Register";
        entryNo: Integer;
    begin

        LoginRegister.Reset();
        LoginRegister.SetRange("Entry No.", DocN);
        if LoginRegister.FindFirst() then begin
            LoginRegister."Entry No." := entryNo;
            LoginRegister."User ID" := UserID;
            LoginRegister."Work Summary" := Worksummary;
            LoginRegister."Login Date" := Today;
            LoginRegister.Location := Location;
            LoginRegister.Validate(LoginRegister.Location);
            LoginRegister."Login Type" := LoginRegister."Login Type"::Task;
            LoginRegister."Login Time" := Time;
            if LoginRegister.Modify(true) then
                exit(true);
        end else
            exit(false);
        //exit(LoginRegister."Entry No.");
    end;

    procedure RequestMeetingApproval(DocN: Code[30]): Boolean
    var
        myInt: Integer;
        PboMeetings: Record "PBO Meetings";
    begin
        PboMeetings.Reset();
        PboMeetings.SetRange("Meeting Code", DocN);
        if PboMeetings.FindFirst() then begin
            PboMeetings."Meeting Status" := PboMeetings."Meeting Status"::Pending;
            PboMeetings.Modify();
            exit(true);
        end else
            exit(false);

    end;

    procedure marklAsSuccessfull(DocN: Code[30]): Boolean
    var
        myInt: Integer;
        PboMeetings: Record "PBO Meetings";
    begin
        PboMeetings.Reset();
        PboMeetings.SetRange("Meeting Code", DocN);
        if PboMeetings.FindFirst() then begin
            PboMeetings."Meeting Status" := PboMeetings."Meeting Status"::proceeding;
            PboMeetings.Modify();
            exit(true);
        end else
            exit(false);

    end;

    procedure marketoproceed(DocN: Code[30]): Boolean
    var
        myInt: Integer;
        PboMeetings: Record "PBO Meetings";
    begin
        PboMeetings.Reset();
        PboMeetings.SetRange("Meeting Code", DocN);
        if PboMeetings.FindFirst() then begin
            PboMeetings."Meeting Status" := PboMeetings."Meeting Status"::proceeding;
            PboMeetings.Modify();
            exit(true);
        end else
            exit(false);

    end;

    procedure CancellMeeting(DocN: Code[30]): Boolean
    var
        myInt: Integer;
        PboMeetings: Record "PBO Meetings";
    begin
        PboMeetings.Reset();
        PboMeetings.SetRange("Meeting Code", DocN);
        if PboMeetings.FindFirst() then begin
            PboMeetings."Meeting Status" := PboMeetings."Meeting Status"::failled;
            PboMeetings.Modify();
            exit(true);
        end else
            exit(false);
    end;

    procedure DeleteLinesTask(MeetinCode: Code[40]; LineN: Integer)
    var
        myInt: Integer;
        MeetingTask: Record "Meeting Task";
    begin
        MeetingTask.Reset();
        MeetingTask.SetRange(MeetingTask."Commitee Code", MeetinCode);
        MeetingTask.SetRange(MeetingTask."Entry No", LineN);
        if MeetingTask.FindFirst() then
            MeetingTask.Delete();

    end;

    procedure InsertTaskLines(EmployCode: Code[30]; Task: Text; MeetinCode: Code[40]): Boolean
    var
        myInt: Integer;
        MeetingTask: Record "Meeting Task";
    begin
        MeetingTask.Reset();
        if MeetingTask.FindLast() then begin
            MeetingTask.Init();
            MeetingTask."Commitee Code" := MeetinCode;
            MeetingTask."Entry No" := MeetingTask."Entry No" + 1;
            MeetingTask."Employee No" := EmployCode;
            MeetingTask.Validate(MeetingTask."Employee No");
            MeetingTask.Task := Task;
            if MeetingTask.Insert() then
                exit(true);
        end else begin
            MeetingTask."Commitee Code" := MeetinCode;
            MeetingTask."Entry No" := 1;
            MeetingTask."Employee No" := EmployCode;
            MeetingTask.Validate(MeetingTask."Employee No");
            MeetingTask.Task := Task;
            MeetingTask.Insert();
        end;
    end;

    procedure HRLeaveAppInsert(EmployeeNo: Text; Names: Text; LeaveType: Text; DaysApplied: Decimal; StartDate: Date; ReturnDate: Date; ApplicationDate: Date; Status: Integer; EndDate: Date; UserID: Text; applicantComments: Text[250]; ResponsibilityCenter: Code[20]; "Request Leave Allowance": Boolean) HR_Doc_No: Code[20]
    var
        HRLeave: Record "HR Leave Application";
        HREmp: Record Employee;
        Text005: Label 'You have a Leave Application of type %1 - %2 that is still Pending. Kindly Cancel it or wait for Approval.';
    begin

        begin

            HRLeave.Reset();

            HRLeave.SetRange(HRLeave."Employee No", EmployeeNo);
            //  HRLeave.SETRANGE(HRLeave."Leave Type", LeaveType);
            HRLeave.SetFilter(HRLeave.Status, '%1|%2', HRLeave.Status::New, HRLeave.Status::"Pending Approval");

            if HRLeave.Find('-') then
                Error(Text005, LeaveType);
            HREmp.Get(EmployeeNo);
            HRLeave.Reset();

            HRLeave."Employee No" := EmployeeNo;
            HRLeave.Names := Names;
            HRLeave."Leave Type" := LeaveType;
            HRLeave."Days Applied" := DaysApplied;
            HRLeave."Start Date" := StartDate;
            HRLeave."End Date" := EndDate;
            HRLeave."Return Date" := ReturnDate;
            HRLeave."Application Date" := ApplicationDate;
            HRLeave.Status := Status;
            HRLeave."User ID" := UserID;
            //HRLeave."User ID" := HREmp."User ID";
            HRLeave."Applicant Comments" := applicantComments;
            HRLeave."Responsibility Center" := ResponsibilityCenter;
            HRLeave."Job Tittle" := HREmp."Job Title";
            HRLeave."Request Leave Allowance" := "Request Leave Allowance";
            HRLeave.Insert(true);
            HRLeave.Validate("Days Applied");
            HR_Doc_No := HRLeave."Application Code";
            if HR_Doc_No <> '' then
                exit(HR_Doc_No);

            //SendLeaveForApproval(HR_Doc_No);

        end
    end;

    procedure HRLeaveAppModify(ApplicationCode: Code[50]; EmployeeNo: Text; Names: Text; LeaveType: Text; DaysApplied: Decimal; StartDate: Date; ReturnDate: Date; ApplicationDate: Date; Status: Integer; EndDate: Date; UserID: Text; applicantComments: Text[250]; ResponsibilityCenter: Code[20]; "Request Leave Allowance": Boolean; LineNum: Integer; PlannerNum: Code[40]) HR_Doc_No: Code[20]
    var
        HRLeave: Record "HR Leave Application";
        HREmp: Record Employee;
        Text005: Label 'You have a Leave Application of type %1 - %2 that is still Pending. Kindly Cancel it or wait for Approval.';
    begin

        begin

            HRLeave.Reset();
            HRLeave.SetRange(HRLeave."Employee No", EmployeeNo);
            HRLeave.SetRange(HRLeave."Leave Type", LeaveType);
            HRLeave.SetRange(HRLeave.Status, HRLeave.Status::"Pending Approval");
            if HRLeave.Find('-') then
                Error(Text005, LeaveType);


            HRLeave.Reset();
            HRLeave.SetRange(HRLeave."Application Code", ApplicationCode);
            if HRLeave.Find('-') then begin
                HRLeave."Employee No" := EmployeeNo;
                HRLeave.PlannerHeaderNum := PlannerNum;
                HRLeave.Names := Names;
                HRLeave."Leave Type" := LeaveType;
                HRLeave.LeaveLineNum := LineNum;
                HRLeave."Days Applied" := DaysApplied;
                HRLeave."Start Date" := StartDate;
                HRLeave."End Date" := EndDate;
                HRLeave."Return Date" := ReturnDate;
                HRLeave."Application Date" := ApplicationDate;
                HRLeave.Status := Status;
                HRLeave."User ID" := UserID;
                HRLeave."Applicant Comments" := applicantComments;
                HRLeave."Responsibility Center" := ResponsibilityCenter;
                HRLeave."Request Leave Allowance" := "Request Leave Allowance";
                HR_Doc_No := HRLeave."Application Code";
                HRLeave.Modify();
                HRLeave.Validate("Days Applied");
                SendLeaveForApproval(ApplicationCode);
            end
        end
    end;

    procedure SendLeaveForApproval(ApplicationCode: Code[10])
    var
        LeaveApplication: Record "HR Leave Application";
        HRLeaveLedger: Record "HR Leave Ledger Entries";
        HRLvType: Record "HR Leave Types";
        HRCalendar_L: Record "HR Calendar";
        approvalentry: Record "Approval Entry";
        Text005: Label 'You have a Leave Application of type %1 - %2 that is still Pending. Kindly Cancel it or wait for Approval.';

    begin
        LeaveApplication.Reset();
        LeaveApplication.SetRange(LeaveApplication."Application Code", ApplicationCode);
        if LeaveApplication.Find('-') then begin
            //Added Dan
            HRLeave.Reset();
            HRLeave.SetRange(HRLeave."Employee No", LeaveApplication."Employee No");
            HRLeave.SetRange(HRLeave.Status, HRLeave.Status::"Pending Approval");
            if HRLeave.Find('-') then
                Error(Text005, HRLeave."Application Code", HRLeave."Leave Type");

            HRLeave.Reset();
            HRLeave.SetRange(HRLeave."Employee No", LeaveApplication."Employee No");
            HRLeave.SetRange(HRLeave.Status, HRLeave.Status::Approved);
            if HRLeave.Find('-') then
                repeat

                    if (LeaveApplication."Start Date" < HRLeave."Return Date") or (LeaveApplication."Return Date" < HRLeave."Return Date")
                    then
                        Error('Your Leave Application Overlaps with leave application [ %1 - %2 ] which is Approved and has a Return Date exceeding the Start Date specified for your current application.', HRLeave."Application Code", HRLeave."Leave Type");
                until HRLeave.Next() = 0;



            HRCalendar_L.Reset();
            HRCalendar_L.SetRange(HRCalendar_L.Current, true);
            if HRCalendar_L.Find('-') then begin
                HRLeave.Reset();
                HRLeave.SetRange(HRLeave."Return Date", HRCalendar_L."Start Date", HRCalendar_L."End Date");
                HRLeave.SetRange(HRLeave."Employee No", LeaveApplication."Employee No");
                HRLeave.SetFilter(HRLeave.Status, '%1|%2|%3', 1, 2, 4);
                HRLeave.SetRange(HRLeave."Leave Type", LeaveApplication."Leave Type");
                if HRLeave.Find('-') then begin
                    HRLvType.Reset();
                    HRLvType.SetRange(HRLvType.Code, LeaveApplication."Leave Type");
                    if HRLvType.Find('-') then
                        if HRLvType."Apply Once Per FY?" then
                            if HRLeave.Status <> HRLeave.Status::New then
                                Error('You cannot apply for this leave type [ %1 ] more than once.' +
                                         ' It was applied on Leave Application No [ %2 ] & Status [ %3] & Leave Type [ %4 ] ',
                                   HRLvType.Description, HRLeave."Application Code", HRLeave.Status, HRLeave."Leave Type");
                end;
            end;

            //error('simama hapa');
            //Added Dan - Not allow someone to apply leave more than once in a FY Year
            VarVariant := LeaveApplication;
            ApprovalMgt.OnSendDocForApproval(VarVariant);

            //ApprovalMgt.SendLeaveAppApprovalReq(LeaveApplication);
        end
    end;

    procedure SendPboComSMS(Mobile: Text; Message: Text; LoanNo: Code[30]; MessageTyp: Enum "Message Type"): Text
    var
        Client: HttpClient;
        RequestContent: HttpContent;
        Response: HttpResponseMessage;
        JsonResponse: Text;
        JsonObject: Text;
        ApiKey: Text;
        ContentHeaders: HttpHeaders;
        passwd: Text;
        PartnerID: Text;
        URL: Text;
        SenderID: Text;
        SMSMessage: Record "SMS Messages";
        iEntryNo: Integer;
        ClientId: Text;
        HrSetp: Record "HR setup";
    begin
        // API configuration
        HrSetp.Get();
        ApiKey := 'xYlZ8Durc4nD';
        passwd := '9063aa8c7bf68fa1edc41e9c1c6c8b54';
        SenderID := 'BigCatchLTD';
        ClientId := 'bigcatchltd';
        URL := 'https://client.airtouch.co.ke:9012/sms/api/';
        if StrLen(MOBILE) = 13 then begin
            MOBILE := CopyStr(MOBILE, 2, 12);
        end;

        if StrLen(MOBILE) = 10 then begin
            if CopyStr(MOBILE, 1, 1) = '0' then
                MOBILE := '254' + CopyStr(MOBILE, 2, 9);
        end;

        if StrLen(MOBILE) = 9 then begin
            if CopyStr(MOBILE, 1, 1) = '7' then
                MOBILE := '254' + MOBILE
        end;
        // {
        //  "issn":"BigCatchLTD",
        //  "msisdn":254724982440,
        //  "text":"This is a test api message",
        //  "username":"bigcatchltd",
        //  "password":"9063aa8c7bf68fa1edc41e9c1c6c8b54",
        //  "sms_id":"sms_id"
        // }
        // Create JSON payload
        JsonObject := '{' +
    '"password": "' + passwd + '",' +
    '"username": "' + ClientId + '",' +
    '"msisdn": "' + mobile + '",' +
    '"text": "' + Message + '",' +
    '"issn": "' + SenderID + '"' +
'}';
        // Prepare HTTP request
        // SMSMessage.Reset();text
        // SMSMessage.SetRange("Loan No", LoanNo);
        // SMSMessage.SetRange("Message Type", SMSMessage."Message Type"::"Installment Reminder");
        // SMSMessage.SetRange("Date Entered", Today);
        // SMSMessage.SetRange(Sent, true);
        // if SMSMessage.FindFirst() then
        //     exit;
        // SMSMessage.Reset();
        // SMSMessage.SetRange("Loan No", LoanNo);
        // SMSMessage.SetRange("Message Type", SMSMessage."Message Type"::"Arrears Reminder");

        // SMSMessage.SetRange("Date Entered", Today);
        // SMSMessage.SetRange(Sent, true);
        // if SMSMessage.FindFirst() then
        //     exit;
        RequestContent.WriteFrom(JsonObject);

        //KKAIMOR
        //Message(Format(JsonObject));
        RequestContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        RequestContent.GetHeaders(ContentHeaders);

        // Send HTTP POST request
        Client.Post(URL, RequestContent, Response);

        // Check response status and return the result
        if Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(JsonResponse);
            //Message('Response: %1', JsonResponse);
            if JsonResponse <> '' then begin
                SMSMessage.Reset;
                if SMSMessage.Find('+') then begin
                    iEntryNo := SMSMessage."Entry No";
                    iEntryNo := iEntryNo + 1;
                end
                else begin
                    iEntryNo := 1;
                end;
                SMSMessage.LockTable;
                SMSMessage.Reset;

                SMSMessage.Init;
                SMSMessage."Entry No" := iEntryNo;
                SMSMessage."Account No" := Mobile;
                SMSMessage."Date Entered" := Today;
                SMSMessage."Time Entered" := Time;
                SMSMessage.Source := 'pbo';
                SMSMessage."Loan No" := LoanNo;
                SMSMessage."Message Type" := MessageTyp;
                SMSMessage."Entered By" := UserId;
                SMSMessage."Sent To Server" := SMSMessage."sent to server"::No;
                SMSMessage."SMS Message" := Message;
                SMSMessage."Telephone No" := Mobile;
                SMSMessage.Sent := true;
                SMSMessage.Insert;
            end;
            exit(JsonResponse);
        end else begin
            SMSMessage.Reset;
            if SMSMessage.Find('+') then begin
                iEntryNo := SMSMessage."Entry No";
                iEntryNo := iEntryNo + 1;
            end
            else begin
                iEntryNo := 1;
            end;
            SMSMessage.LockTable;
            SMSMessage.Reset;
            SMSMessage.Init;
            SMSMessage."Entry No" := iEntryNo;
            SMSMessage."Account No" := Mobile;
            SMSMessage."Date Entered" := Today;
            SMSMessage."Time Entered" := Time;
            SMSMessage.Source := 'pbo';
            SMSMessage."Entered By" := UserId;
            SMSMessage."Loan No" := LoanNo;
            SMSMessage."Message Type" := MessageTyp;
            SMSMessage."Sent To Server" := SMSMessage."sent to server"::No;
            SMSMessage."SMS Message" := Message;
            SMSMessage."Telephone No" := Mobile;
            SMSMessage.Sent := false;
            SMSMessage.Insert;
            Response.Content().ReadAs(JsonResponse);
            Error('Failed to send SMS. Status Code: %1. Response: %2', Response.HttpStatusCode(), JsonResponse);
        end;
    end;


    procedure DeleteTaskFile(EntrCode: Code[30])
    var
        myInt: Integer;
        TaskVolumes: Record "Files Table";
    begin
        TaskVolumes.Reset();
        TaskVolumes.SetRange("Entry No.", EntrCode);
        if TaskVolumes.FindFirst() then
            TaskVolumes.Delete();

    end;

    procedure EditTaskfiles(DOCN: Code[40]; AuthorCode: Code[40]; reference: Code[200]; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer; TaskDuration: DateFormula; TaskTyp: Integer; Duedate: Date): Boolean
    var

        myInt: Integer;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
    begin
        TaskVolumes.Reset();
        TaskVolumes.SetRange(DocNo, DOCN);
        if TaskVolumes.FindFirst() then begin
            if TaskVolumes."Document Type" <> DocTyp then begin
                TaskVolumes."Document Type" := DocTyp;
                TaskVolumes.Validate(TaskVolumes."Document Type");
            end;
            // MembNoSeries.TestField(MembNoSeries."File Entry No.");
            // DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."File Entry No.", 0D, True);
            //  TaskVolumes."Entry No." := DocNo;
            TaskVolumes."Author Code" := AuthorCode;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes.Reference := Reference;
            TaskVolumes."File Type" := TaskTyp;
            TaskVolumes."Task Duration" := TaskDuration;
            TaskVolumes."Task Date" := Today;
            TaskVolumes.Receiver := Receiver;
            TaskVolumes.Validate(Receiver);
            TaskVolumes."Due Date" := Duedate;
            TaskVolumes.Department := Departmen;
            TaskVolumes.Validate(Department);
            TaskVolumes.Action := Action;
            TaskVolumes."Task Status" := TaskVolumes."Task Status"::Open;
            // TaskVolumes.Feedback := FileTabes.Feedback;
            TaskVolumes.Remarks := Remarks;
            if TaskVolumes.Modify() then
                exit(true)
            else
                exit(false);
        end;
    end;

    procedure CloseTask(DocNo: Code[30]): Boolean
    var
        myInt: Integer;
        TaskVolumes: Record "Files Table";
    begin
        TaskVolumes.Reset();
        TaskVolumes.SetRange(DocNO, DocNo);
        if TaskVolumes.FindFirst() then begin
            TaskVolumes."Task Status" := TaskVolumes."Task Status"::Archived;
            TaskVolumes."Date Closed" := Today;
            TaskVolumes."Closed By" := UserId;
            TaskVolumes.Modify();
            exit(true);
        end else
            exit(false);
    end;

    procedure GetPublicIPAddress(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        IPAddress: Text;
    begin
        // Using a free IP detection service
        if Client.Get('https://api.ipify.org?format=text', Response) then begin
            if Response.IsSuccessStatusCode then begin
                Response.Content.ReadAs(IPAddress);
                Message(IPAddress);
                exit(IPAddress);
            end;
        end;

        exit('');
    end;

    procedure GetMACAddressViaAPI(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: Text;
        JToken: JsonToken;
        JObject: JsonObject;
        testMac: Text;
    begin
        // Call external API that returns MAC address
        // You'd need to create your own endpoint or use a third-party service
        if Client.Get('https://your-api-endpoint.com/getmac', Response) then begin
            if Response.IsSuccessStatusCode then begin
                Response.Content.ReadAs(Content);

                if JObject.ReadFrom(Content) then
                    if JObject.Get('macAddress', JToken) then
                        testMac := JToken.AsValue().AsText();
                Message(testMac);
                exit(JToken.AsValue().AsText());
            end;
        end;

        exit('');
    end;

    procedure CreatFilesTask(AuthorCode: Code[40]; reference: Code[200]; Duedate: Date; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer; TaskDuration: DateFormula; TaskTyp: Integer): code[40]
    var
        myInt: Integer;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
    begin
        MembNoSeries.Get();
        TaskVolumes.Reset();
        TaskVolumes.Init();
        DocNo := '';
        MembNoSeries.Get;
        TaskVolumes."Document Type" := DocTyp;
        TaskVolumes.Validate(TaskVolumes."Document Type");
        MembNoSeries.TestField(MembNoSeries."File Entry No.");
        DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."File Entry No.", 0D, True);
        TaskVolumes.DocNO := DocNo;
        TaskVolumes."Author Code" := AuthorCode;
        TaskVolumes.Validate(TaskVolumes."Author Code");
        TaskVolumes.Reference := Reference;
        TaskVolumes."Task Date" := Today;
        TaskVolumes."Due Date" := Duedate;
        TaskVolumes."Task Duration" := TaskDuration;
        TaskVolumes.Receiver := Receiver;
        TaskVolumes.Validate(Receiver);
        TaskVolumes."File Type" := TaskTyp;
        TaskVolumes.Department := Departmen;
        TaskVolumes.Validate(Department);
        TaskVolumes.Action := Action;
        TaskVolumes."Task Status" := TaskVolumes."Task Status"::Open;
        // TaskVolumes.Feedback := FileTabes.Feedback;
        TaskVolumes.Remarks := Remarks;
        if TaskVolumes.Insert() then
            exit(TaskVolumes."Entry No.");

    end;

    procedure UpdateFilesTask(DocNumber: Code[30]; AuthorCode: Code[40]; reference: Code[200]; Duedate: Date; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer; TaskDuration: DateFormula): code[40]
    var
        myInt: Integer;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
    begin
        MembNoSeries.Get();
        TaskVolumes.Reset();
        TaskVolumes.SetRange(DocNo, DocNumber);
        if TaskVolumes.FindFirst() then begin
            DocNo := '';
            MembNoSeries.Get;
            TaskVolumes."Document Type" := DocTyp;
            TaskVolumes.Validate(TaskVolumes."Document Type");
            //MembNoSeries.TestField(MembNoSeries."File Entry No.");
            // DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."File Entry No.", 0D, True);
            //  TaskVolumes."Entry No." := DocNo;
            TaskVolumes."Author Code" := AuthorCode;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes.Reference := Reference;
            TaskVolumes."Task Date" := Today;
            TaskVolumes."Due Date" := Duedate;
            TaskVolumes."Task Duration" := TaskDuration;
            TaskVolumes.Receiver := Receiver;
            TaskVolumes.Department := Departmen;
            TaskVolumes.Action := Action;
            // TaskVolumes.Feedback := FileTabes.Feedback;
            TaskVolumes.Remarks := Remarks;
            TaskVolumes.Modify();
            // exit(TaskVolumes."Entry No.");
        end;

    end;

    procedure SendTaskNotifications(Meetcode: Code[30]) Status: Boolean
    var
        myInt: Integer;
        HRDiscipMemb: Record "Meeting Task";
        Employee: Record Employee;
        AccName: Text;
        CompanIn: Record "Company Information";
        msg: Text;
        EmailManager: Codeunit "Email Message";
        Email: Codeunit Email;
        SureFactory: Codeunit "Hr Portal";
        GenSetUp: Record "HR setup";
        MessageTY: Enum "Message Type";
    begin
        Status := false;
        MessageTY := MessageTY::"Meeting Notification";
        HRDiscipMemb.Reset();
        HRDiscipMemb.SetRange(HRDiscipMemb."Commitee Code", Meetcode);
        if HRDiscipMemb.Find('-') then begin
            repeat
                if Employee.Get(HRDiscipMemb."Employee No") then begin
                    AccName := '';
                    CompanIn.Get();
                    AccName := Employee."First Name";
                    if AccName = '' then
                        AccName := Employee."Middle Name";
                    GenSetUp.get();
                    if GenSetUp."Allow Send SMS" then begin
                        if Employee."Phone No." <> '' then begin //Check if the mobile phone No is not blank but dont return an error
                                                                 // msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + HRDiscipMemb."Meeting Code" + ' ' + 'and the meeting date is ' + Format(rec."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            msg := 'Dear ' + AccName + '<br><>br'', you have  been assigned  the follwowing task ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Meetcode + ' ' + '' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            SureFactory.SendPboComSMS(Employee."Phone No.", msg, Employee."No.", MessageTY);
                        end;
                    end;
                    if GenSetUp."Notify Vie Mail" = true then begin
                        msg := 'Dear ' + AccName + '<br><>br'', you have  been assigned  the follwowing task ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Meetcode + ' ' + '' + 'Kindly for Further Information Contact the Head department. Thank you.';
                        EmailManager.Create(HRDiscipMemb.Email, 'Commitee Notifications', msg, true);
                        Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                    end;
                end;
            until HRDiscipMemb.Next() = 0;
            Status := true;
            exit(Status);
        end else begin
            exit(Status);
        end;

    end;

    procedure SendAndNotifyReceiver(DocNUm: Code[40]) Status: Boolean;
    var
        myInt: Integer;
        AccName: Text;
        CompanIn: Record "Company Information";
        msg: Text;
        Emailmessage: Codeunit "Email Message";
        EmailTable: Record "Email Account";
        HRDiscipMemb: Record "Files Table";
        Employee: Record Employee;
        EmailManager: Codeunit "Email Message";
        Email: Codeunit Email;
        TaskVolumes: Record "Task Volumes";
        FileTabes: Record "Files Table";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SeriesSetup: Record "HR setup";
        DocNoE: Code[30];
        GenSetUp: Record "HR setup";
        SureFactory: Codeunit "Hr Portal";
        MessageTY: Enum "Message Type";

    begin
        Status := false;
        MessageTY := MessageTY::"Meeting Notification";
        HRDiscipMemb.Reset();
        HRDiscipMemb.SetRange(HRDiscipMemb.DocNO, DocNUm);
        if HRDiscipMemb.FindFirst() then begin
            repeat
                if Employee.Get(HRDiscipMemb."Receiver Code") then begin
                    AccName := '';
                    CompanIn.Get();
                    AccName := Employee."First Name";
                    if AccName = '' then
                        AccName := Employee."Middle Name";
                    GenSetUp.get();
                    if GenSetUp."Allow Send SMS" then begin
                        if Employee."Phone No." <> '' then begin //Check if the mobile phone No is not blank but dont return an error
                                                                 // msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + HRDiscipMemb."Meeting Code" + ' ' + 'and the meeting date is ' + Format(rec."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                                                                 // msg := 'Dear ' + AccName + '<br><>br'', you have  been assigned  the follwowing task ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Meetcode + ' ' + '' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            msg := 'Dear ' + AccName + ', you have  been assigned task no. ' + ' ' + HRDiscipMemb."Entry No." + ' ' + 'and the task assigned date is ' + Format(HRDiscipMemb."Task Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            SureFactory.SendPboComSMS(Employee."Phone No.", msg, Employee."No.", MessageTY);
                        end;
                    end;
                    if GenSetUp."Notify Vie Mail" = true then begin

                        msg := 'Dear ' + AccName + ', you have  been assigned task no. ' + ' ' + HRDiscipMemb."Entry No." + ' ' + 'and the task assigned date is ' + Format(HRDiscipMemb."Task Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                        EmailManager.Create(HRDiscipMemb."Reciever Mail", 'PBO Notifications', msg, true);
                        Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                    end;
                end;
            until HRDiscipMemb.Next() = 0;
        end;
        DocNoE := '';
        FileTabes.Reset();
        FileTabes.SetRange(DocNo, DocNUm);
        if FileTabes.FindFirst() then begin
            TaskVolumes.Reset();
            TaskVolumes.Init();
            SeriesSetup.Get;
            SeriesSetup.TestField(SeriesSetup."Volume Entry No.");
            DocNoE := NoSeriesMgt.GetNextNo(SeriesSetup."Volume Entry No.", 0D, True);
            TaskVolumes."File No." := FileTabes.DocNO;
            TaskVolumes."Volume Entry No." := FileTabes."Entry No.";
            TaskVolumes."Author Code" := FileTabes.Author;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes."Date Received" := Today;
            TaskVolumes."File Type" := FileTabes."File Type";
            TaskVolumes."Document Type" := FileTabes."Document Type";
            TaskVolumes."Incoming Date" := FileTabes."Incoming Date";
            TaskVolumes.Reference := FileTabes.Reference;
            TaskVolumes."Task Date" := FileTabes."Task Date";
            TaskVolumes."Receiver Code" := FileTabes."Receiver Code";
            TaskVolumes.Validate(TaskVolumes."Receiver Code");
            TaskVolumes.Department := FileTabes.Department;
            TaskVolumes.Validate(TaskVolumes.Department);
            TaskVolumes.Action := FileTabes.Action;
            TaskVolumes."Task Status" := FileTabes."Task Status"::Forwared;
            TaskVolumes.Remarks := FileTabes.Remarks;
            if TaskVolumes.Insert() then begin
                FileTabes."Author Code" := FileTabes."Receiver Code";
                FileTabes.Validate(FileTabes."Author Code");
                FileTabes."Reciever Mail" := '';
                FileTabes.Receiver := '';
                FileTabes."Task Status" := FileTabes."Task Status"::Forwared;
                FileTabes."Incoming Date" := Today;
                FileTabes.Action := '';
                FileTabes.Remarks := '';
                FileTabes.Modify();
            end;
        end;
    end;

    procedure ConfirmLogin(USERNAME: Text; Passcode: Code[40]) Status: Boolean;
    var
        myInt: Integer;
        PortalUser: Record "portal User";
    begin
        Status := false;
        PortalUser.Reset();
        PortalUser.SetRange(PortalUser."User Name", USERNAME);
        if PortalUser.FindFirst() then begin
            if PortalUser."Password Value" = Passcode then
                Status := true
            else
                Status := false;
            exit(Status);
        end else
            exit(Status);
    end;

    procedure CheckUserCanLogin(StaffN: Code[50]) Status: Boolean;
    var
        myInt: Integer;
        userSet: Record "User Setup";
    begin
        Status := false;
        userSet.Reset();
        userSet.SetRange("Staff No", StaffN);
        if userSet.FindFirst() then begin
            if userSet."Can Login" = true then
                Status := true
            else
                Status := false;
            exit(Status);
        end else
            exit(Status);
    end;



    procedure FnResetPassword(USERNAME: Text; Passw: Code[40]) passChangestatus: Text
    var
        PortalUser: Record "portal User";
        RandomDigit: Text;
        Body: Text;

    begin
        PortalUser.Reset;
        PortalUser.SetRange(PortalUser."User Name", USERNAME);
        if PortalUser.FindSet then begin
            // RandomDigit := CreateGuid;
            // RandomDigit := DelChr(RandomDigit, '=', '{}-01');
            // RandomDigit := CopyStr(RandomDigit, 1, 8);
            PortalUser."Password Value" := Passw;
            PortalUser."Last Modified Date" := Today;
            PortalUser."Change Password" := false;
            PortalUser."Record Type" := PortalUser."record type"::"Job Applicant";
            if PortalUser.Modify(true) then begin
                passChangestatus := 'password changed';
                exit(passChangestatus);
            end else begin
                Error('Password not reset, Kindly try again!')
            end;
        end else begin
            Error('User name is Missing')
        end;
    end;

    procedure GeneratePortalEmailOTPCode(UserName: Text)
    var
        otp: Text;
        HrSetup: Record "HR setup";
        HrEmp: Record Employee;
        UserSet: Record "User Setup";
        NameX: Text;
        GenSetUp: Record "HR setup";
        msg: Text;
        SureFactory: Codeunit "Hr Portal";
        MessageTY: Enum "Message Type";
    begin
        MessageTY := MessageTY::Other;

        NameX := '';
        UserSet.Reset();
        UserSet.SetRange("User ID", UserName);
        if UserSet.FindFirst() then begin
            if UserSet."User ID" <> '' then
                NameX := COPYSTR(UserSet."User ID", STRPOS(UserSet."User ID", '\') + 1, STRLEN(UserSet."User ID"));
            HrSetup.Get();
            HrEmp.Reset();
            HrEmp.Setrange(HrEmp."No.", NameX);
            if HrEmp.find('-') then begin
                otp := GenerateRandomOTPCode(5);
                HrEmp."OTP Code" := otp;
                HrEmp."OTP Code Expiration" := CurrentDateTime + HrSetup."OTP Timeout";
                HrEmp.modify(false);
                if HREmp."Company E-mail" <> '' then
                    SendEmail(HREmp."Company E-Mail", 'Login OTP', 'Your Login OTP is ' + otp);
                GenSetUp.get();
                if GenSetUp."Allow Send SMS" then begin
                    if HREmp."Phone No." <> '' then begin
                        msg := 'Dear ' + HrEmp."First Name" + ',Login OTP Your Login OTP is ' + otp;
                        SureFactory.SendPboComSMS(HREmp."Phone No.", msg, HREmp."No.", MessageTY);
                    end;
                end;
            end;
        end;
    end;

    procedure SendEmail(receiver: Text[50]; subject: Text[100]; message: Text[1000]) returnValue: Boolean
    var
        SMTPMail: Codeunit "Email Message";
        SendEmail: codeunit email;
        MailManagement: Codeunit "Mail Management";
        SendToList: List of [Text];
        SenderEmail: Text;
        ret: Boolean;
    begin
        returnValue := FALSE;
        returnValue := false;
        SendToList.Add(receiver);
        SMTPMail.Create(SendToList, subject, message, true);
        SendEmail.Send(SMTPMail, Enum::"Email Scenario"::Default);
        returnValue := TRUE;
    end;

    procedure ReturnOTPExpiration(EmpNo: Text; OTP: Text) ExpirationDate: DateTime
    var
        HrEmp: Record Employee;
        UserSetup: Record "User Setup";
    begin
        HrEmp.Reset();
        HrEmp.setrange("No.", EmpNo);
        HrEmp.setrange("OTP Code", OTP);
        //HrEmp.Setfilter("OTP Code Expiration", '<%1', CurrentDateTime + HrSetup."OTP Timeout");
        if HrEmp.find('-') then
            ExpirationDate := HrEmp."OTP Code Expiration";

    end;

    procedure VerifyPortalOTPCode(UserName: Text; OTP: Text) Success: Boolean
    var
        HrEmp: Record Employee;
        UserSetup: Record "User Setup";
        EmpNo: Text;
    begin
        Success := false;
        EmpNo := '';
        UserSetup.Reset();
        UserSetup.SetRange("User ID", UserName);
        if UserSetup.FindFirst() then begin
            if UserSetup."User ID" <> '' then
                EmpNo := COPYSTR(UserSetup."User ID", STRPOS(UserSetup."User ID", '\') + 1, STRLEN(UserSetup."User ID"));
            HrEmp.Reset();
            HrEmp.setrange("No.", EmpNo);
            HrEmp.setrange("OTP Code", OTP);
            if HrEmp.find('-') then
                if CurrentDateTime < HrEmp."OTP Code Expiration" then
                    Success := true;
        end
        else
            Success := false;
        exit(Success);
    end;

    procedure GenerateRandomOTPCode(CodeLength: Integer): Text
    var
        OTP: Text;
        Characters: Text;
        RandomIndex: Integer;
        I: Integer;
    begin
        Characters := '0123456789';//'ABCDEFGHJKMNPQRSTUVWXYabcdefghjkmnpqrstuvwxy3456789';
        OTP := '';

        // Ensure CodeLength is positive
        if CodeLength <= 0 then
            Error('Code length must be greater than zero.');

        // Initialize the random number generator
        Randomize;

        // Generate the OTP code
        for I := 1 to CodeLength do begin
            RandomIndex := Random(StrLen(Characters));
            OTP := OTP + CopyStr(Characters, RandomIndex, 1);
        end;

        exit(OTP);
    end;


    procedure CreatePortalUser(Name: Text; NewPasswrd: Code[20]): Boolean
    var
        myInt: Integer;
        RandomDigit: Text[50];
        entryno: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IDD: Integer;
        PortalUSer: Record "portal User";
        employee: Record Employee;
        UserSet: Record "User Setup";
        NameX: Text;
    begin
        UserSet.Reset();
        UserSet.SetRange("User ID", Name);
        if UserSet.FindFirst() then begin
            if UserSet."User ID" <> '' then
                NameX := COPYSTR(UserSet."User ID", STRPOS(UserSet."User ID", '\') + 1, STRLEN(UserSet."User ID"));
            PortalUSer.Reset;
            PortalUSer.SetRange("User Name", UserSet."User ID");
            if not PortalUSer.FindSet then begin
                PortalUSer.Init;
                PortalUSer."User Name" := UserSet."User ID";
                PortalUSer."Full Name" := UserSet."User ID";
                employee.Reset();
                employee.SetRange("No.", NameX);
                if employee.FindFirst() then
                    PortalUSer."Authentication Email" := employee."Company E-Mail";
                PortalUSer.State := PortalUSer.State::Enabled;
                PortalUSer."Record Type" := PortalUSer."record type"::"Job Applicant";
                // RandomDigit := CreateGuid;
                // RandomDigit := DelChr(RandomDigit, '=', '{}-01');
                // RandomDigit := CopyStr(RandomDigit, 1, 8);
                PortalUSer."Password Value" := NewPasswrd;
                PortalUSer."Last Modified Date" := Today;
                if not PortalUSer.Insert(true) then begin
                    Error('Account creation not successfull, Kindly contact ICT!')
                end;
                exit(true);
            end else
                exit(false);
        end
        else
            exit(false);

    end;

    procedure SendEmail(Username: Text)
    var
        PortalUser: Record "portal User";
        SMTPMailSetup: Record "Email Account";
        SMTPMail: Codeunit "Email Message";
        Smail: Codeunit EMail;
        Body: Text;
        SMTP: Codeunit Mail;
        Receipients: List of [Text];
        Subject: Text[250];
    begin
        PortalUser.Reset;
        PortalUser.SetRange(PortalUser."User Name", Username);
        if PortalUser.FindSet then begin
            Subject := 'Portal Password';
            Body := 'Dear ' + PortalUser."Full Name" + ', your password for the account: ' + ' <strong>' + PortalUser."User Name" + '</strong> has been reset successfully. Kindly use the password below to access your account<br> <strong>Password: ' + PortalUser."Password Value" + '</strong> <br>';
            Body := Body + ' ' + 'Kind Regards,<br> PBO' + '<br><br>';
            Body := Body + '[This email is automated. Kindly do not reply to it]<br><br>';
            SMTPMail.Create(PortalUser."Authentication Email", Subject, Body, true);
            Smail.Send(SMTPMail, Enum::"Email Scenario"::Default);
        end;
    end;

    procedure NotifyCommittee(MeetingCode: Code[20]): Boolean
    var
        myInt: Integer;
        AccName: Text;
        CompanIn: Record "Company Information";
        msg: Text;
        Emailmessage: Codeunit "Email Message";
        EmailTable: Record "Email Account";
        HRDiscipMemb: Record "Committee Cub Members";
        Employee: Record Employee;
        EmailManager: Codeunit "Email Message";
        Email: Codeunit Email;
        PBOMEetings: Record "PBO Meetings";
        GenSetUp: Record "HR setup";
        SureFactory: Codeunit "Hr Portal";
        MessageTY: Enum "Message Type";

    begin
        GenSetUp.Get();
        PBOMEetings.Reset();
        PBOMEetings.SetRange("Meeting Code", MeetingCode);
        if PBOMEetings.FindFirst() then begin
            HRDiscipMemb.Reset();
            HRDiscipMemb.SetRange(HRDiscipMemb."Commitee Code", MeetingCode);
            if HRDiscipMemb.FindFirst() then
                repeat
                    if Employee.Get(HRDiscipMemb."Employee No") then begin
                        AccName := '';
                        CompanIn.Get();
                        AccName := Employee."First Name";
                        if AccName = '' then
                            AccName := Employee."Middle Name";
                        if GenSetUp."Allow Send SMS" then begin
                            if Employee."Phone No." <> '' then begin //Check if the mobile phone No is not blank but dont return an error
                                msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + MeetingCode + ' ' + 'and the meeting date is ' + Format(PBOMEetings."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                                SureFactory.SendPboComSMS(Employee."Phone No.", msg, Employee."No.", MessageTY);
                            end;
                        end;
                        if GenSetUp."Notify Vie Mail" then begin

                            msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + MeetingCode + ' ' + 'and the meeting date is ' + Format(PBOMEetings."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            EmailManager.Create(HRDiscipMemb.Email, 'Commitee Notifications', msg, true);
                            Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                        end;
                    end;
                until HRDiscipMemb.Next() = 0;
            exit(true);
        end;
        exit(false);

    end;

}
