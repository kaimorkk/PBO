namespace PBO.PBO;
using System.Utilities;
using System.Security.User;
using System.IO;
using Microsoft.Sales.Customer;
using System.Automation;
using Microsoft.Foundation.Attachment;
using Microsoft.Service.Document;
using Microsoft.Foundation.Company;
using System.Email;
using Microsoft.Foundation.NoSeries;
using System.Environment;
using System;
using Microsoft.HumanResources.Employee;
using System.Text;

codeunit 50000 "Hr Portal"
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

    procedure InsertOrDeleteTags(Name: Text; Int: Integer)
    var
        myInt: Integer;
        Sect: Record "Sector /Tags";
    begin
        if Int = 0 then begin
            Sect.Reset();
            Sect.Init();
            if Sect.FindLast() then
                myInt := Sect."Entry no" + 1 else
                myInt := 1;
            Sect."Entry no" := myInt;
            Sect.Name := Name;
            Sect.Insert();
        end else begin
            Sect.Reset();
            Sect.SetRange("Entry no", Int);
            if Sect.FindFirst() then
                Sect.Delete();
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
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange(ApprovalEntry."Document No.", DocumentNo);
        ApprovalEntry.SetRange(ApprovalEntry."Approver ID", ApproverID);
        ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.Find('-') then begin
            repeat
                if not ApprovalSetup.Get(ApproverID) then
                    Error(Text004);
                if ApprovalEntry."Approver ID" <> '' then
                    CustomApprovals.ApproveApprovalRequests(ApprovalEntry);
            until ApprovalEntry.Next() = 0;
        end;


    end;

    procedure UploadAttachedDocument(DocNo: Code[20]; FileName: Text[2000]; Attachment: BigText; TableID: Integer; Sponsor: Text; Description: Text);
    var
        myInt: Integer;
        Version: Integer;
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
                Version := 0;
                Clear(DocAttachment);
                DocAttachment.Reset();
                DocAttachment.SetRange("No.", DocNo);
                Version := DocAttachment.Count;
                DocAttachment.Init();
                DocAttachment.Validate("File Extension", FileManagement.GetExtension(FileName));
                DocAttachment.Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(FileName), 1, MaxStrLen(FileName)));
                DocAttachment.Validate("Table ID", FromRecRef.Number);
                DocAttachment.Validate("No.", DocNo);
                DocAttachment.Description := Description;
                DocAttachment.Sponsor := Sponsor;
                DocAttachment.Version := 'V' + Format(Version + 1);
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
        Total: Integer;
        NameX: Text;
        employees: Record Employee;
    begin
        NameX := '';
        entryNo := 0;
        Total := 0;
        IF STRPOS(UserID, '\') > 0 THEN
            NameX := COPYSTR(UserID, STRPOS(UserID, '\') + 1, STRLEN(UserID))
        ELSE
            NameX := UserID;
        // NameX := '';
        // NameX := COPYSTR(UserID, STRPOS(UserID, '\') + 1, STRLEN(UserID));
        LoginRegister.Reset();
        Total := LoginRegister.Count;
        entryNo := Total + 1;
        LoginRegister.Reset();
        LoginRegister.SetRange("User ID", UserID);
        LoginRegister.SetRange(LoginRegister."Login Type", LoginRegister."Login Type"::Login);
        LoginRegister.SetRange("Login Date", Today);
        if not LoginRegister.FindFirst() then begin
            LoginRegister.Init();
            LoginRegister."Entry No." := entryNo;
            LoginRegister."User ID" := UserID;
            LoginRegister."Login Name" := NameX;
            LoginRegister."Login Type" := LoginRegister."Login Type"::Login;
            LoginRegister."Work Summary" := Worksummary;
            LoginRegister."Login Date" := Today;
            LoginRegister."Login Time" := Time;
            LoginRegister."Login Status" := LoginRegister."Login Status"::Available;

            NameX := '';
            NameX := COPYSTR(UserID, STRPOS(UserID, '\') + 1, STRLEN(UserID));
            employees.Reset();
            employees.setrange("No.", NameX);
            if employees.findfirst() then begin
                LoginRegister."Global Dimension 1 Code" := employees."Global Dimension 1 Code";
                employees."Login Status" := employees."Login Status"::Available;
                employees.Modify();
            end;
            LoginRegister.Insert(true);
            exit(LoginRegister."Entry No.");
        end else begin
            LoginRegister.Reset();
            LoginRegister.SetRange("User ID", UserID);
            LoginRegister.SetRange(LoginRegister."Login Type", LoginRegister."Login Type"::Login);
            LoginRegister.SetRange("Login Date", Today);
            if LoginRegister.FindFirst() then begin
                LoginRegister."Login Name" := NameX;
                LoginRegister."Login Status" := LoginRegister."Login Status"::Available;
                employees.Reset();
                employees.setrange("No.", NameX);
                if employees.findfirst() then begin
                    LoginRegister."Global Dimension 1 Code" := employees."Global Dimension 1 Code";
                    employees."Login Status" := employees."Login Status"::Available;
                    employees.Modify();
                end;
                LoginRegister.Modify();

            end;
            // employees.Reset();
            // employees.setrange("No.", NameX);
            // if employees.findfirst() then begin
            //     employees."Login Status" := employees."Login Status"::Available;
            //     employees.Modify();
            // end;
        end;
    end;

    procedure CreateTaskRegister(UserID: Code[50]; Worksummary: Text; Location: Text): Integer
    var
        LoginRegister: Record "Login Register";
        entryNo: Integer;
        NameX: Text;
        employees: Record Employee;
    begin
        NameX := '';
        NameX := COPYSTR(UserID, STRPOS(UserID, '\') + 1, STRLEN(UserID));
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
        LoginRegister."Login Name" := NameX;
        employees.Reset();
        employees.setrange("No.", NameX);
        if employees.findfirst() then begin
            LoginRegister."Global Dimension 1 Code" := employees."Global Dimension 1 Code";
        end;
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
        NameX: Text;
    begin
        NameX := '';
        NameX := COPYSTR(UserID, STRPOS(UserID, '\') + 1, STRLEN(UserID));
        LoginRegister.Reset();
        LoginRegister.SetRange("Entry No.", DocN);
        if LoginRegister.FindFirst() then begin
            LoginRegister."Entry No." := entryNo;
            LoginRegister."User ID" := UserID;
            LoginRegister."Work Summary" := Worksummary;
            LoginRegister."Login Date" := Today;
            LoginRegister."Login Name" := NameX;
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

    procedure markAsSuccessful(DocN: Code[30]): Boolean
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

    procedure HRLeaveAppInsert(EmployeeNo: Text; StartDate: Date; EndDate: Date; UserIDCode: Text; applicantComments: Text[250]; Department: Code[20]; DocNo: code[20]) HR_Doc_No: Code[20]
    var
        HRLeave: Record "HR Leave Application";
        HREmp: Record Employee;
        NameX: Text;
        Text005: Label 'You have a Leave Application of type %1 - %2 that is still Pending. Kindly Cancel it or wait for Approval.';
    begin

        begin
            if DocNo = '' then begin
                HRLeave.Reset();
                HRLeave.SetRange(HRLeave."Employee No", EmployeeNo);
                if HRLeave.Find('-') then
                    repeat
                        if (StartDate < HRLeave."Return Date") or (EndDate < HRLeave."Return Date")
                        then
                            Error('Your Leave Application Overlaps with leave application [ %1 - %2 ] which is Approved and has a Return Date exceeding the Start Date specified for your current application.', HRLeave."Application Code", HRLeave."Leave Type");
                    until HRLeave.Next() = 0;
                NameX := '';
                NameX := COPYSTR(UserIDCode, STRPOS(UserIDCode, '\') + 1, STRLEN(UserIDCode));
                UserIDCode := NameX;
                HREmp.Get(EmployeeNo);
                HRLeave.Reset();
                HRLeave.init;
                HRLeave."Employee No" := EmployeeNo;
                HRLeave."Start Date" := StartDate;
                HRLeave.Names := HREmp."Search Name";
                HRLeave."End Date" := EndDate;
                HRLeave."Application Date" := Today;
                HRLeave."User ID" := UserID;
                //HRLeave."User ID" := HREmp."User ID";
                HRLeave."Applicant Comments" := applicantComments;
                HRLeave."Responsibility Center" := Department;
                HRLeave."Job Tittle" := HREmp."Job Title";
                HRLeave.Insert(true);
                // HRLeave.Validate("Days Applied");
                HR_Doc_No := HRLeave."Application Code";
                if HR_Doc_No <> '' then
                    exit(HR_Doc_No);
            end else begin
                HRLeave.Reset();
                HRLeave.SetRange("Application Code", DocNo);
                if HRLeave.FindFirst() then begin
                    HRLeave."Employee No" := EmployeeNo;
                    HRLeave."Start Date" := StartDate;
                    HRLeave.Names := HREmp."Search Name";
                    HRLeave."End Date" := EndDate;
                    HRLeave."Application Date" := Today;
                    HRLeave."User ID" := UserID;
                    //HRLeave."User ID" := HREmp."User ID";
                    HRLeave."Applicant Comments" := applicantComments;
                    HRLeave."Responsibility Center" := Department;
                    HRLeave."Job Tittle" := HREmp."Job Title";
                    HRLeave.Modify();
                    HR_Doc_No := HRLeave."Application Code";
                    if HR_Doc_No <> '' then
                        exit(HR_Doc_No);
                end;
            end;
            //SendLeaveForApproval(HR_Doc_No);

        end
    end;

    procedure HRLeaveAppModify(ApplicationCode: Code[50]; EmployeeNo: Text; Names: Text; LeaveType: Text; DaysApplied: Decimal; StartDate: Date; ReturnDate: Date; ApplicationDate: Date; Status: Integer; EndDate: Date; UserIDCode: Text; applicantComments: Text[250]; ResponsibilityCenter: Code[20]; "Request Leave Allowance": Boolean; LineNum: Integer; PlannerNum: Code[40]) HR_Doc_No: Code[20]
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
            VarVariant := LeaveApplication;
            ApprovalMgt.OnSendDocForApproval(VarVariant);
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
        JsonObject := '{' +
    '"password": "' + passwd + '",' +
    '"username": "' + ClientId + '",' +
    '"msisdn": "' + mobile + '",' +
    '"text": "' + Message + '",' +
    '"issn": "' + SenderID + '"' +
'}';
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

    procedure EditTaskfiles(DOCN: Code[40]; AuthorCode: Code[40]; reference: Code[200]; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer; TaskDuration: DateFormula; TaskTyp: Integer; Duedate: Date; SectCategory: Text; IncomingDate: Date; IsDepartmentTask: Boolean; Priority: Integer): Boolean
    var

        myInt: Integer;
        Numberofdays: Integer;
        TaskD: DateFormula;
        DurationText: Text;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
    begin
        Numberofdays := 0;
        TaskVolumes.Reset();
        TaskVolumes.SetRange(DocNo, DOCN);
        if TaskVolumes.FindFirst() then begin
            if TaskVolumes."Document Type" <> DocTyp then begin
                TaskVolumes."Document Type" := DocTyp;
                TaskVolumes.Validate(TaskVolumes."Document Type");
            end;
            TaskVolumes."Author Code" := AuthorCode;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes.Reference := Reference;
            TaskVolumes.Priority := Priority;
            TaskVolumes."File Type" := TaskTyp;
            TaskVolumes."Sector/Category" := SectCategory;
            TaskVolumes."Incoming Date" := IncomingDate;
            TaskVolumes."Due Date" := Duedate;
            if TaskVolumes."Incoming Date" > TaskVolumes."Due Date" then
                Error('Due Date cannot be less than Incoming Date');
            Numberofdays := Duedate - IncomingDate;
            Evaluate(TaskD, Format(Numberofdays) + 'D');
            TaskVolumes."Task Duration" := TaskD;
            TaskVolumes."Is department Task" := IsDepartmentTask;
            // TaskVolumes."Task Duration" := TaskDuration;
            // Evaluate(DurationText, Format(TaskVolumes."Task Duration"));
            // DurationText := DelChr(Format(DurationText), '=', '-|+|');
            // Evaluate(TaskVolumes."Task Duration", DurationText);
            // TaskVolumes."Due Date" := CalcDate(TaskVolumes."Task Duration", TaskVolumes."Incoming Date");
            TaskVolumes."Task Date" := Today;
            TaskVolumes.Receiver := Receiver;
            TaskVolumes.Validate(Receiver);
            TaskVolumes.Department := Departmen;
            TaskVolumes.Validate(Department);
            TaskVolumes.Action := Action;
            TaskVolumes."Task Status" := TaskVolumes."Task Status"::Open;
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
        if Client.Get('https://your-api-endpoint.com/getmac', Response) then begin
            if Response.IsSuccessStatusCode then begin
                Response.Content.ReadAs(Content);
                if JObject.ReadFrom(Content) then
                    if JObject.Get('macAddress', JToken) then
                        testMac := JToken.AsValue().AsText();
                // Message(testMac);
                exit(JToken.AsValue().AsText());
            end;
        end;

        exit('');
    end;

    procedure CreatFilesTask(AuthorCode: Code[40]; reference: Code[200]; Duedate: Date; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer; TaskDuration: DateFormula; TaskTyp: Integer; SectCategory: Text; IncomingDate: Date; IsDepartmentTask: Boolean; Priority: Integer): code[40]
    var
        myInt: Integer;
        DurationText: Text;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
        Numberofdays: Integer;
        TaskD: DateFormula;
    begin
        MembNoSeries.Get();
        TaskVolumes.Reset();
        TaskVolumes.Init();
        DocNo := '';
        MembNoSeries.Get;
        TaskVolumes."Document Type" := DocTyp;
        TaskVolumes."Is department Task" := IsDepartmentTask;
        TaskVolumes.Validate(TaskVolumes."Document Type");
        MembNoSeries.TestField(MembNoSeries."File Entry No.");
        DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."File Entry No.", 0D, True);
        TaskVolumes.DocNO := DocNo;
        TaskVolumes.Priority := Priority;
        TaskVolumes."Author Code" := AuthorCode;
        TaskVolumes.Validate(TaskVolumes."Author Code");
        TaskVolumes.Reference := Reference;
        TaskVolumes."Sector/Category" := SectCategory;
        TaskVolumes."Incoming Date" := IncomingDate;
        TaskVolumes."Due Date" := Duedate;
        TaskVolumes."Captured By" := AuthorCode;
        if TaskVolumes."Incoming Date" > TaskVolumes."Due Date" then
            Error('Due Date cannot be less than Incoming Date');
        Numberofdays := Duedate - IncomingDate;
        Evaluate(TaskD, Format(Numberofdays) + 'D');
        TaskVolumes."Task Duration" := TaskD;
        // TaskVolumes."Task Duration" := TaskDuration;
        // Evaluate(DurationText, Format(TaskVolumes."Task Duration"));
        // DurationText := DelChr(Format(DurationText), '=', '-|+|');
        // Evaluate(TaskVolumes."Task Duration", DurationText);
        // TaskVolumes."Due Date" := CalcDate(TaskVolumes."Task Duration", TaskVolumes."Incoming Date");
        TaskVolumes.Receiver := Receiver;
        TaskVolumes.Validate(Receiver);
        TaskVolumes."File Type" := TaskTyp;
        TaskVolumes.Department := Departmen;
        TaskVolumes.Validate(Department);
        TaskVolumes.Action := Action;
        TaskVolumes."Task Status" := TaskVolumes."Task Status"::Open;
        TaskVolumes.Remarks := Remarks;
        if TaskVolumes.Insert() then
            exit(TaskVolumes."Entry No.");
    end;

    procedure UpdateFilesTask(DocNumber: Code[30]; AuthorCode: Code[40]; reference: Code[200]; Duedate: Date; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer; TaskDuration: DateFormula; SectCategory: Text; IncomingDate: Date; IsDepartmentTask: Boolean): code[40]
    var
        myInt: Integer;
        DurationText: Text;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
        TaskVo: Record "Task Volumes";
        Numberofdays: Integer;
        TaskD: DateFormula;
    begin
        MembNoSeries.Get();
        TaskVolumes.Reset();
        TaskVolumes.SetRange(DocNo, DocNumber);
        if TaskVolumes.FindFirst() then begin
            DocNo := '';
            MembNoSeries.Get;
            TaskVolumes."Document Type" := DocTyp;
            TaskVolumes.Validate(TaskVolumes."Document Type");
            TaskVolumes."Author Code" := AuthorCode;
            TaskVolumes."Sector/Category" := SectCategory;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes.Reference := Reference;
            TaskVolumes."Incoming Date" := IncomingDate;
            TaskVolumes."Due Date" := Duedate;
            if TaskVolumes."Incoming Date" > TaskVolumes."Due Date" then
                Error('Due Date cannot be less than Incoming Date');
            Numberofdays := Duedate - IncomingDate;
            Evaluate(TaskD, Format(Numberofdays) + 'D');
            TaskVolumes."Task Duration" := TaskD;
            // TaskVolumes."Incoming Date" := Duedate;
            // TaskVolumes."Task Duration" := TaskDuration;
            // Evaluate(DurationText, Format(TaskVolumes."Task Duration"));
            // DurationText := DelChr(Format(DurationText), '=', '-|+|');
            // Evaluate(TaskVolumes."Task Duration", DurationText);
            // TaskVolumes."Due Date" := CalcDate(TaskVolumes."Task Duration", TaskVolumes."Incoming Date");
            TaskVolumes.Receiver := Receiver;
            TaskVolumes.Department := Departmen;
            TaskVolumes.Action := Action;
            TaskVolumes.Remarks := Remarks;
            TaskVolumes.Modify();
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
                                                                 // msg := 'Dear ' + AccName + '<br><>br'', you have  been assigned  the follwowing task ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Meetcode + ' ' + '' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            msg := 'Dear ' + AccName + ', you have  been assigned ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Meetcode + ' ' + '' + 'Kindly Purpose to attend. Thank you.';
                            SureFactory.SendPboComSMS(Employee."Phone No.", msg, Employee."No.", MessageTY);
                        end;
                    end;
                    if GenSetUp."Notify Vie Mail" = true then begin
                        msg := 'Dear ' + AccName + '<br><>br'', you have  been assigned ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Meetcode + ' ' + '' + 'Kindly for Further Information Contact the Head department. Thank you.';
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

    procedure NewLine() NewLine: Text
    var
        nL: Char;
    begin

        nL := 13;
        NewLine := Format(nL, 0, '<CHAR>');
    end;


    procedure SendAndNotifyReceiver(DocNUm: Code[40]; ReceiverCode: Code[20]; Remarks: Text; Action: Text; AuthorCode: Code[20]; Priority: Integer) Status: Boolean;
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
                if Employee.Get(ReceiverCode) then begin
                    AccName := '';
                    CompanIn.Get();
                    AccName := Employee."First Name";
                    if AccName = '' then
                        AccName := Employee."Middle Name";
                    if Action = '' then
                        Action := HRDiscipMemb.Action;
                    GenSetUp.get();
                    if GenSetUp."Allow Send SMS" then begin
                        if Employee."Phone No." <> '' then begin

                            msg := 'Dear ' + AccName + '\n' +
                             'You have received a Task notification on  ' + Format(HRDiscipMemb."Document Type") + ' Task no. ' + HRDiscipMemb."Entry No." + '\n' +
                              Action + '\n' +
                              'Task due date is ' + Format(HRDiscipMemb."Due Date") + '\n' +
                               'Thank you.';
                            SureFactory.SendPboComSMS(Employee."Phone No.", msg, Employee."No.", MessageTY);
                        end;
                    end;
                    if GenSetUp."Notify Vie Mail" = true then begin
                        if Employee."Company E-Mail" <> '' then begin
                            msg := 'Dear ' + AccName + '<br>' +
                              'You have received a Task notification on  ' + Format(HRDiscipMemb."Document Type") + ' Task no. ' + HRDiscipMemb."Entry No." + '<br>' + Action + '<br>' +
                              'Task assigned due date is ' + Format(HRDiscipMemb."Due Date") + '<br>' +
                               'Thank you.';
                            EmailManager.Create(Employee."Company E-Mail", 'PBO Notifications', msg, true);

                            Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                        end;
                    end;
                end;
            until HRDiscipMemb.Next() = 0;
        end;
        DocNoE := '';
        FileTabes.Reset();
        FileTabes.SetRange(DocNo, DocNUm);
        if FileTabes.FindFirst() then begin
            TaskVolumes.Reset();
            TaskVolumes.SetRange("Task Volume", FileTabes."Entry No.");
            TaskVolumes.SetRange(TaskVolumes.Receiver, AuthorCode);
            if TaskVolumes.FindLast() then begin
                TaskVolumes.Forwarded := true;
                TaskVolumes.Modify();
            end;
            TaskVolumes.Init();
            SeriesSetup.Get;
            SeriesSetup.TestField(SeriesSetup."Volume Entry No.");
            DocNoE := NoSeriesMgt.GetNextNo(SeriesSetup."Volume Entry No.", 0D, True);
            TaskVolumes."File No." := FileTabes.DocNO;
            TaskVolumes."Volume Entry No." := DocNoE;
            TaskVolumes."Task Volume" := FileTabes."Entry No.";
            TaskVolumes."Author Code" := AuthorCode;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes."Date Received" := Today;
            TaskVolumes."File Type" := FileTabes."File Type";
            TaskVolumes."Is Department Task" := FileTabes."Is Department Task";
            TaskVolumes."Sector/Category" := FileTabes."Sector/Category";
            TaskVolumes."Document Type" := FileTabes."Document Type";
            TaskVolumes."Incoming Date" := FileTabes."Incoming Date";
            TaskVolumes."Due Date" := FileTabes."Due Date";
            TaskVolumes.Reference := FileTabes.Reference;
            TaskVolumes."Task Date" := FileTabes."Task Date";
            TaskVolumes."Receiver Code" := ReceiverCode;
            TaskVolumes.Receiver := ReceiverCode;
            //TaskVolumes.Validate(TaskVolumes."Receiver Code");
            TaskVolumes.Department := FileTabes.Department;
            TaskVolumes.Validate(TaskVolumes.Department);
            TaskVolumes.Action := Action;
            TaskVolumes."Task Status" := FileTabes."Task Status"::Forwared;
            TaskVolumes.Remarks := Remarks;
            TaskVolumes.Insert();
            if DocNoE <> '' then begin
                FileTabes."Author Code" := ReceiverCode;
                FileTabes.Validate(FileTabes."Author Code");
                FileTabes."Reciever Mail" := '';
                FileTabes.Priority := Priority;
                FileTabes."Receiver Code" := '';
                FileTabes.Receiver := '';
                FileTabes."Captured By" := AuthorCode;
                FileTabes."Task Status" := FileTabes."Task Status"::Forwared;
                FileTabes."Incoming Date" := Today;
                FileTabes.Action := '';
                FileTabes.Remarks := '';
            end;
            FileTabes.Modify();
        end;
    end;

    procedure UpdateStatus(StaffNo: code[40]; LoginStatus: Integer) Status: Boolean
    var
        employees: record Employee;
        LoginRegister: Record "Login Register";
        NameX: Text;
    begin
        NameX := '';
        NameX := COPYSTR(StaffNo, STRPOS(StaffNo, '\') + 1, STRLEN(StaffNo));
        LoginRegister.Reset();
        LoginRegister.SetRange(LoginRegister."Login Name", StaffNo);
        LoginRegister.SetRange("Login Date", Today);
        LoginRegister.SetRange(LoginRegister."Login Type", LoginRegister."Login Type"::Login);
        if LoginRegister.FindFirst() then begin
            LoginRegister."Logout Time" := Time;
            LoginRegister."Login Status" := LoginStatus;
            LoginRegister.Modify();
        end;
        employees.Reset();
        employees.setrange("No.", NameX);
        if employees.findfirst() then begin
            Status := true;
            employees."Login Status" := LoginStatus;
            employees.Modify();
        end else begin
            Status := false;
        end;
        Status := false;
        exit(Status);
    end;

    procedure ConfirmLogin(USERNAME: Text; Passcode: Code[40]) Status: Boolean;
    var
        myInt: Integer;
        PortalUser: Record "portal User";
        NameX: Text;
    begin
        NameX := '';
        NameX := COPYSTR(UserName, STRPOS(UserName, '\') + 1, STRLEN(UserName));
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
        NameX: Text;
        UserSet: Record "User Setup";
        employee: Record Employee;

    begin
        NameX := '';
        NameX := COPYSTR(UserName, STRPOS(UserName, '\') + 1, STRLEN(UserName));

        PortalUser.Reset();
        PortalUser.SetRange(PortalUser."User Name", USERNAME);
        if PortalUser.FindFirst() then begin
            PortalUSer."User Name" := UpperCase(USERNAME);
            PortalUSer."Full Name" := UpperCase(USERNAME);
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
            PortalUSer.Init;
            PortalUSer."User Name" := UpperCase(USERNAME);
            PortalUSer."Full Name" := UpperCase(USERNAME);
            employee.Reset();
            employee.SetRange("No.", NameX);
            if employee.FindFirst() then
                PortalUSer."Authentication Email" := employee."Company E-Mail";
            PortalUSer.State := PortalUSer.State::Enabled;
            PortalUSer."Record Type" := PortalUSer."record type"::"Job Applicant";
            // RandomDigit := CreateGuid;
            // RandomDigit := DelChr(RandomDigit, '=', '{}-01');
            // RandomDigit := CopyStr(RandomDigit, 1, 8);
            PortalUSer."Password Value" := Passw;
            PortalUSer."Last Modified Date" := Today;
            if not PortalUSer.Insert(true) then begin
                Error('Account creation not successfull, Kindly contact ICT!')
            end else begin
                passChangestatus := 'password changed';
                exit(passChangestatus);
            end;
        end;
        // end else begin
        //     UserSet.Reset();
        //     UserSet.SetRange("User ID", USERNAME);
        //     if UserSet.FindFirst() then begin
        //         PortalUser.Reset();
        //         PortalUser.SetRange(PortalUser."User Name", USERNAME);
        //         if PortalUser.FindFirst() then begin
        //             // RandomDigit := CreateGuid;
        //             // RandomDigit := DelChr(RandomDigit, '=', '{}-01');
        //             // RandomDigit := CopyStr(RandomDigit, 1, 8);
        //             PortalUser."Password Value" := Passw;
        //             PortalUser."Last Modified Date" := Today;
        //             PortalUser."Change Password" := false;
        //             PortalUser."Record Type" := PortalUser."record type"::"Job Applicant";
        //             if PortalUser.Modify(true) then begin
        //                 passChangestatus := 'password changed';
        //                 exit(passChangestatus);
        //             end else begin
        //                 Error('Password not reset, Kindly try again!')
        //             end;
        //         end else begin
        //             PortalUSer.Init;
        //             PortalUSer."User Name" := USERNAME;
        //             PortalUSer."Full Name" := USERNAME;
        //             employee.Reset();
        //             employee.SetRange("No.", NameX);
        //             if employee.FindFirst() then
        //                 PortalUSer."Authentication Email" := employee."Company E-Mail";
        //             PortalUSer.State := PortalUSer.State::Enabled;
        //             PortalUSer."Record Type" := PortalUSer."record type"::"Job Applicant";
        //             PortalUSer."Password Value" := Passw;
        //             PortalUSer."Last Modified Date" := Today;
        //             if not PortalUSer.Insert(true) then begin
        //                 Error('Account creation not successfull, Kindly contact ICT!')
        //             end else begin
        //                 passChangestatus := 'password changed';
        //                 exit(passChangestatus);
        //             end;
        //         end;
        //     end
        //end;
    end;

    procedure GeneratePortalEmailOTPCode(UserName: Text)
    var
        otp: Text;
        HrSetup: Record "HR setup";
        HrEmp: Record Employee;
        service: Record "Service Document Log";
        UserSet: Record "User Setup";
        NameX: Text;
        GenSetUp: Record "HR setup";
        msg: Text;
        SureFactory: Codeunit "Hr Portal";
        MessageTY: Enum "Message Type";
    begin
        MessageTY := MessageTY::Other;

        NameX := '';
        // Error('weeeee is Missing');
        NameX := COPYSTR(UserName, STRPOS(UserName, '\') + 1, STRLEN(UserName));
        UserSet.Reset();
        UserSet.SetRange("User ID", NameX);
        if UserSet.FindFirst() then begin
            //Error('user not found %1', NameX);
            HrSetup.Get();
            HrEmp.Reset();
            HrEmp.Setrange(HrEmp."No.", NameX);
            if HrEmp.find('-') then begin
                //Error('Employee not found %1', NameX);
                otp := GenerateRandomOTPCode(5);
                HrEmp."OTP Code" := otp;
                HrEmp."OTP Code Expiration" := CurrentDateTime + HrSetup."OTP Timeout";
                HrEmp.modify();
                GenSetUp.get();
                if HREmp."Company E-mail" <> '' then
                    if GenSetUp."Notify Vie Mail" then
                        if GenSetUp."Notify Vie Mail" then
                            SendEmail(HREmp."Company E-Mail", 'Login OTP', 'Your Login OTP is ' + otp);
                // GenSetUp.get();
                if GenSetUp."Allow Send SMS" then begin
                    if HREmp."Phone No." <> '' then begin
                        msg := 'Dear ' + HrEmp."First Name" + ',Login OTP Your Login OTP is ' + otp;
                        // Error('Number %1', HREmp."Phone No.");
                        SureFactory.SendPboComSMS(HREmp."Phone No.", msg, HREmp."No.", MessageTY);
                    end;
                end;
            end;
        end else begin
            UserSet.Reset();
            UserSet.SetRange("User ID", UserName);
            if UserSet.FindFirst() then begin

                HrSetup.Get();
                HrEmp.Reset();
                HrEmp.Setrange(HrEmp."No.", UserName);
                if HrEmp.find('-') then begin

                    otp := GenerateRandomOTPCode(5);
                    HrEmp."OTP Code" := otp;
                    HrEmp."OTP Code Expiration" := CurrentDateTime + HrSetup."OTP Timeout";
                    HrEmp.modify;

                    if HREmp."Company E-mail" <> '' then
                        SendEmail(HREmp."Company E-Mail", 'Login OTP', 'Your Login OTP is ' + otp);
                    GenSetUp.get();
                    if GenSetUp."Allow Send SMS" then begin
                        if HREmp."Phone No." <> '' then begin
                            msg := 'Dear ' + HrEmp."First Name" + ',Login OTP Your Login OTP is ' + otp;
                            //Error('2 Number %1', HREmp."Phone No.");
                            SureFactory.SendPboComSMS(HREmp."Phone No.", msg, HREmp."No.", MessageTY);
                        end;
                    end;
                end else
                    Error('2nd employee not found %1', UserName);
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
        NameX: Text;
    begin
        Success := false;
        NameX := '';
        NameX := COPYSTR(UserName, STRPOS(UserName, '\') + 1, STRLEN(UserName));
        EmpNo := '';
        UserSetup.Reset();
        UserSetup.SetRange("User ID", NameX);
        if UserSetup.FindFirst() then begin
            if UserSetup."User ID" <> '' then
                EmpNo := COPYSTR(UserSetup."User ID", STRPOS(UserSetup."User ID", '\') + 1, STRLEN(UserSetup."User ID"));
            HrEmp.Reset();
            HrEmp.setrange("No.", EmpNo);
            HrEmp.setrange("OTP Code", OTP);
            if HrEmp.find('-') then
                if CurrentDateTime < HrEmp."OTP Code Expiration" then
                    Success := true;
        end else begin
            UserSetup.Reset();
            UserSetup.SetRange("User ID", UserName);
            if UserSetup.FindFirst() then begin
                // if UserSetup."User ID" <> '' then
                //     EmpNo := COPYSTR(UserSetup."User ID", STRPOS(UserSetup."User ID", '\') + 1, STRLEN(UserSetup."User ID"));
                HrEmp.Reset();
                HrEmp.setrange("No.", UserSetup."User ID");
                HrEmp.setrange("OTP Code", OTP);
                if HrEmp.find('-') then
                    if CurrentDateTime < HrEmp."OTP Code Expiration" then
                        Success := true;
            end;
        end;

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

    procedure AppendZerosToString(var MyString: Text)
    var
        ZerosToAdd: Integer;
        Zeros: Text;
    begin
        ZerosToAdd := 6 - STRLEN(MyString);

        // If the string length is less than 6, append leading zeros
        if ZerosToAdd > 0 then begin
            Zeros := '';
            // Append zeros to Zeros variable
            repeat
                Zeros := Zeros + '0';
                ZerosToAdd := ZerosToAdd - 1;
            until ZerosToAdd = 0;

            // Concatenate leading zeros with the original string
            MyString := Zeros + MyString;
        end;
    end;


    procedure GenerateLoginReport(LoginDate: Date; UserName: Code[40]; Department: Text): Text
    var
        //"Login Date", "User ID"
        BlobOutStream: OutStream;
        RecRef: RecordRef;
        BlobInStream: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        FileContentsB64: Text;
        ResponseObject: JsonObject;
        filenameFromApp: text;
        LoginReg: Record "Login Register";
    begin

        TempBlob.CreateInStream(BlobInStream);
        TempBlob.CreateOutStream(BlobOutStream, TextEncoding::UTF8);
        LoginReg.Reset();
        if UserName <> '' then
            LoginReg.SetRange(LoginReg."User ID", UserName);
        if Department <> '' then
            LoginReg.SetRange(LoginReg."Global Dimension 1 Code", Department);
        if LoginDate <> 0D then
            LoginReg.SetRange(LoginReg."Login Date", LoginDate);
        if LoginReg.Find('-') then begin
            RecRef.GetTable(LoginReg);
            Report.SaveAs(Report::"Login Register Report", '', ReportFormat::Pdf, BlobOutStream, RecRef);
            FileContentsB64 := Base64Convert.ToBase64(BlobInStream);
            //Message(FileContentsB64);
            exit(FileContentsB64)
        end;
    end;
    //TaskRe
    procedure GenerateTaskRegister(IncomingDate: Date; DocumentType: Integer; TaskStatus: Option Open,Forwared,"Archived"," "; Priority: Option Normal,Urgent," "): Text
    var
        //"Login Date", "User ID"
        //"Document Type", "Incoming Date"
        BlobOutStream: OutStream;
        RecRef: RecordRef;
        BlobInStream: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        FileContentsB64: Text;
        ResponseObject: JsonObject;
        filenameFromApp: text;
        LoginReg: Record "Files Table";
    begin

        TempBlob.CreateInStream(BlobInStream);
        TempBlob.CreateOutStream(BlobOutStream, TextEncoding::UTF8);
        LoginReg.Reset();
        if DocumentType <> 0 then
            LoginReg.SetRange(LoginReg."Document Type", DocumentType);
        if IncomingDate <> 0D then
            LoginReg.SetRange(LoginReg."Incoming Date", IncomingDate);
        if TaskStatus <> TaskStatus::" " then
            LoginReg.SetRange(LoginReg."Task Status", TaskStatus);
        if Priority <> Priority::" " then
            LoginReg.SetRange(LoginReg.Priority, Priority);
        if LoginReg.Find('-') then begin
            RecRef.GetTable(LoginReg);
            Report.SaveAs(Report::"Task Tracking Report", '', ReportFormat::Pdf, BlobOutStream, RecRef);
            FileContentsB64 := Base64Convert.ToBase64(BlobInStream);
            //Message(FileContentsB64);
            exit(FileContentsB64)
        end;
    end;
    //"PBO Meeting Card Report"
    procedure GenerateMeetingReport(MeetingDate: Date; Meetingcode: Code[40]): Text
    var
        //"Login Date", "User ID"
        //"Document Type", "Incoming Date"
        BlobOutStream: OutStream;
        RecRef: RecordRef;
        BlobInStream: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        FileContentsB64: Text;
        ResponseObject: JsonObject;
        filenameFromApp: text;
        Meetings: Record "PBO Meetings";
    begin

        TempBlob.CreateInStream(BlobInStream);
        TempBlob.CreateOutStream(BlobOutStream, TextEncoding::UTF8);
        Meetings.Reset();
        if MeetingDate <> 0D then
            Meetings.SetRange(Meetings."Meeting Date", MeetingDate);
        if Meetingcode <> '' then
            Meetings.SetRange(Meetings."Meeting Code", Meetingcode);
        if Meetings.Find('-') then begin
            RecRef.GetTable(Meetings);
            Report.SaveAs(Report::"PBO Meeting Card Report", '', ReportFormat::Pdf, BlobOutStream, RecRef);
            FileContentsB64 := Base64Convert.ToBase64(BlobInStream);
            //Message(FileContentsB64);
            exit(FileContentsB64)
        end;
    end;

    procedure InsertSMSHeader(Message: Text; Usercode: Code[40]; DepartMent: Code[50]; DocNo: code[30]): Code[30]
    var
        myInt: Integer;
        SMSHeader: Record "SMS Header";
        NameX: Text;
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    // DocNo: Code[30];//
    begin
        if DocNo = '' then begin
            MembNoSeries.Get();
            NameX := '';
            NameX := COPYSTR(usercode, STRPOS(usercode, '\') + 1, STRLEN(usercode));
            MembNoSeries.TestField(MembNoSeries."SMS No. Series");
            DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."SMS No. Series", 0D, True);
            SMSHeader.Init();
            SMSHeader.No := DocNo;
            SMSHeader."Entered By" := usercode;
            SMSHeader."SMS Type" := SMSHeader."SMS Type"::Other;
            SMSHeader.Message := Message;
            SMSHeader."Global Dimension 1 Code" := DepartMent;
            SMSHeader.Validate(SMSHeader."Global Dimension 1 Code");
            SMSHeader."Date Entered" := Today;
            SMSHeader."Time Entered" := Time;
            SMSHeader.Insert(true);
        end else begin
            SMSHeader.Reset();
            SMSHeader.SetRange(No, DocNo);
            if SMSHeader.FindFirst() then begin
                SMSHeader."Entered By" := usercode;
                SMSHeader."SMS Type" := SMSHeader."SMS Type"::Other;
                SMSHeader.Message := Message;
                SMSHeader."Global Dimension 1 Code" := DepartMent;
                SMSHeader.Validate(SMSHeader."Global Dimension 1 Code");
                SMSHeader."Date Entered" := Today;
                SMSHeader."Time Entered" := Time;
                SMSHeader.Modify();
            end;

        end;
        if DocNo <> '' then
            exit(DocNo)
        else
            exit(SMSHeader.No);
    end;

    procedure SendBulkSms(DocNo: Code[40]; SendAs: Integer)
    var
        myInt: Integer;
        CustomerRec: Record Employee;
        GreenSmsLines: Record "SMS Lines";
        LineN: Integer;
        BulkHeader: Record "Sms Header";
        SureFactory: Codeunit "Hr Portal";
        BulkLines: Record "Sms Lines";
        Vend: Record Employee;
        MessageTyp: Enum "Message Type";
    begin
        MessageTyp := MessageTyp::Other;
        BulkHeader.Reset();
        BulkHeader.SetRange(No, DocNo);
        if BulkHeader.FindFirst() then begin
            if SendAs = 1 then begin
                BulkLines.Reset;
                BulkLines.SetRange("Sms sent", false);
                BulkLines.SetRange(BulkLines.No, BulkHeader.No);
                if BulkLines.FindSet() then begin
                    repeat
                        Vend.Reset;
                        Vend.SetRange(Vend."No.", BulkLines."Client No");
                        if Vend.Find('-') then begin
                            SureFactory.SendPboComSMS(BulkLines."Phone No", BulkHeader.Message, BulkLines."Client No", MessageTyp);
                            BulkLines."Sms sent" := true;
                            BulkLines.Modify();
                        end;
                    until BulkLines.Next = 0;
                end;
            end;
            if SendAs = 2 then begin
                GreenSmsLines.Reset();
                GreenSmsLines.SetRange(No, BulkHeader.No);
                if GreenSmsLines.FindSet() then
                    GreenSmsLines.DeleteAll();
                CustomerRec.Reset();
                CustomerRec.SetFilter("Phone No.", '<>%1', '');
                //CustomerRec.SetRange(CustomerRec."Global Dimension 1 Code", rec."Global Dimension 1 Code");
                if CustomerRec.FindSet() then begin
                    repeat
                        LineN := 0;
                        GreenSmsLines.Reset();
                        if GreenSmsLines.FindSet() then
                            LineN := GreenSmsLines.Count;
                        GreenSmsLines.Init();
                        GreenSmsLines."Client No" := CustomerRec."No.";
                        GreenSmsLines.No := BulkHeader.No;
                        GreenSmsLines."entry No" := LineN + 1;
                        GreenSmsLines.Validate(GreenSmsLines."Client No");
                        GreenSmsLines."Phone No" := CustomerRec."Phone No.";
                        SureFactory.SendPboComSMS(GreenSmsLines."Phone No", BulkHeader.Message, '', MessageTyp);
                        GreenSmsLines.Insert();
                    until CustomerRec.Next() = 0;
                end;
                BulkLines.Reset();
                BulkLines.SetRange(No, DocNo);
                if BulkLines.FindSet() then begin
                    repeat
                        BulkLines."Sms sent" := true;
                        BulkLines.Modify();
                    until BulkLines.Next() = 0;
                end;
                // Vend.Reset;
                // Vend.SetRange(Status, Vend.Status::Active);
                // Vend.SetFilter("Phone No.", '<>%1', '');
                // if Vend.FindSet() then begin
                //     repeat
                //         SureFactory.SendPboComSMS(Vend."Phone No.", BulkHeader.Message, '', MessageTyp);
                //     until Vend.Next() = 0;
                // end;
            end;
            BulkHeader.Status := BulkHeader.Status::Approved;
            BulkHeader."SMS Status" := BulkHeader."SMS Status"::Sent;
            BulkHeader.Modify();
        end;

    end;

    procedure InsertSMSLines(DocNo: Code[30]; Depart: Code[40]; EmployCode: Code[40])
    var

        myInt: Integer;
        CustomerRec: Record Employee;
        GreenSmsLines: Record "SMS Lines";
        LineN: Integer;
    begin

        LineN := 0;
        GreenSmsLines.Reset();
        if GreenSmsLines.FindSet() then
            LineN := GreenSmsLines.Count;
        GreenSmsLines.Init();
        GreenSmsLines."Client No" := CustomerRec."No.";
        GreenSmsLines.No := DocNo;
        GreenSmsLines."entry No" := LineN + 1;
        GreenSmsLines."Client No" := EmployCode;
        GreenSmsLines.Validate(GreenSmsLines."Client No");
        // GreenSmsLines."Phone No" := CustomerRec."Phone No.";
        GreenSmsLines.Insert();

    end;

    procedure CreatePortalUser(Name: Text; NewPasswrd: Code[20]) status: Boolean
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
        status := false;
        NameX := '';
        NameX := COPYSTR(Name, STRPOS(Name, '\') + 1, STRLEN(Name));
        UserSet.Reset();
        UserSet.SetRange("User ID", NameX);
        if UserSet.FindFirst() then begin
            // if UserSet."User ID" <> '' then
            //     NameX := COPYSTR(UserSet."User ID", STRPOS(UserSet."User ID", '\') + 1, STRLEN(UserSet."User ID"));
            PortalUSer.Reset;
            PortalUSer.SetRange("User Name", NameX);
            if not PortalUSer.FindSet then begin
                PortalUSer.Init;
                PortalUSer."User Name" := UpperCase(Name);
                PortalUSer."Full Name" := UpperCase(Name);
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
                status := true;
                exit(status);
            end;
        end else begin
            UserSet.Reset();
            UserSet.SetRange("User ID", Name);
            if UserSet.FindFirst() then begin
                // if UserSet."User ID" <> '' then
                //     NameX := COPYSTR(UserSet."User ID", STRPOS(UserSet."User ID", '\') + 1, STRLEN(UserSet."User ID"));
                PortalUSer.Reset;
                PortalUSer.SetRange("User Name", NameX);
                if not PortalUSer.FindSet then begin
                    PortalUSer.Init;
                    PortalUSer."User Name" := UpperCase(Name);
                    PortalUSer."Full Name" := UpperCase(Name);
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
                    status := true;
                    exit(status);
                end;
            end
        end;
        exit(status);
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
        NameX: Text;
    begin
        NameX := '';
        NameX := COPYSTR(Username, STRPOS(Username, '\') + 1, STRLEN(Username));
        PortalUser.Reset;
        PortalUser.SetRange(PortalUser."User Name", NameX);
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
                                msg := 'Dear ' + AccName + ', you have  been Selected to be a  Commitee member Of meeting no. ' + ' ' + MeetingCode + ' ' + 'and the meeting date is ' + Format(PBOMEetings."Meeting Date") + ', Time ' + format(PBOMEetings."Meeting Time") + ' ' + '.MEETING SUMMARY: ';
                                SureFactory.SendPboComSMS(Employee."Phone No.", msg + ',' + PBOMEetings."Meeting Summary", Employee."No.", MessageTY);
                            end;
                        end;
                        if GenSetUp."Notify Vie Mail" then begin

                            msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + MeetingCode + ' ' + 'and the meeting date is ' + Format(PBOMEetings."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                            EmailManager.Create(HRDiscipMemb.Email, 'PBO Notifications', PBOMEetings."Meeting Summary", true);
                            Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                        end;
                    end;
                until HRDiscipMemb.Next() = 0;
            exit(true);
        end;
        exit(false);

    end;

}
