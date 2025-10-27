namespace PBO.PBO;
using System.Utilities;
using System.IO;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Company;
using System.Email;
using Microsoft.Foundation.NoSeries;
using Microsoft.HumanResources.Employee;
using System.Text;

codeunit 50109 "Hr Portal"
{
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

    procedure InsertMeeting(MeetingSummary: Text[700]; MeetingDate: Date; MeetingTime: Time; DepartmentCode: Code[100]; IsBrownBag: Boolean; DocumentComment: Text[500]): Code[40]
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
        PBOMeeting.Validate(PBOMeeting.Department);
        PBOMeeting."Brown-Bag" := IsBrownBag;
        PBOMeeting."Document Comment" := DocumentComment;
        PBOMeeting.Insert();

        // Return the generated Meeting Code
        exit(PBOMeeting."Meeting Code");
    end;

    procedure CreateLoginEntry(UserID: Code[50]): Integer
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
        LoginRegister."Login Date" := Today;
        LoginRegister."Login Time" := Time;
        LoginRegister.Insert(true);
        exit(LoginRegister."Entry No.");
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

    procedure EditTaskfiles(EntrCode: Code[40]; AuthorCode: Code[40]; reference: Code[200]; TaskDate: Date; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer): Text
    var

        myInt: Integer;
        TaskVolumes: Record "Files Table";
        MembNoSeries: Record "HR setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocNo: Code[30];
    begin
        TaskVolumes.Reset();
        TaskVolumes.SetRange("Entry No.", EntrCode);
        if TaskVolumes.FindFirst() then begin
            TaskVolumes."Document Type" := DocTyp;
            TaskVolumes.Validate(TaskVolumes."Document Type");
            MembNoSeries.TestField(MembNoSeries."File Entry No.");
            // DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."File Entry No.", 0D, True);
            //  TaskVolumes."Entry No." := DocNo;
            TaskVolumes."Author Code" := AuthorCode;
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes.Reference := Reference;
            TaskVolumes."Task Date" := TaskDate;
            TaskVolumes.Receiver := Receiver;
            TaskVolumes.Department := Departmen;
            TaskVolumes.Action := Action;
            TaskVolumes."Task Status" := TaskVolumes."Task Status"::Open;
            // TaskVolumes.Feedback := FileTabes.Feedback;
            TaskVolumes.Remarks := Remarks;
            TaskVolumes.Modify();
        end;
    end;

    procedure CreatFilesTask(AuthorCode: Code[40]; reference: Code[200]; TaskDate: Date; Departmen: Text; Receiver: Code[40]; Remarks: Text; Action: Text; DocTyp: Integer): code[40]
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
        //MembNoSeries.TestField(MembNoSeries."File Entry No.");
        // DocNo := NoSeriesMgt.GetNextNo(MembNoSeries."File Entry No.", 0D, True);
        //  TaskVolumes."Entry No." := DocNo;
        TaskVolumes."Author Code" := AuthorCode;
        TaskVolumes.Validate(TaskVolumes."Author Code");
        TaskVolumes.Reference := Reference;
        TaskVolumes."Task Date" := TaskDate;
        TaskVolumes.Receiver := Receiver;
        TaskVolumes.Department := Departmen;
        TaskVolumes.Action := Action;
        TaskVolumes."Task Status" := TaskVolumes."Task Status"::Open;
        // TaskVolumes.Feedback := FileTabes.Feedback;
        TaskVolumes.Remarks := Remarks;
        if TaskVolumes.Insert() then
            exit(DocNo);

    end;

    procedure SendAndNotifyReceiver(DocEntry: Code[40]): Text
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
        DocNo: Code[30];

    begin
        HRDiscipMemb.Reset();
        HRDiscipMemb.SetRange(HRDiscipMemb."Entry No.", DocEntry);
        if HRDiscipMemb.FindFirst() then begin
            repeat
                if Employee.Get(HRDiscipMemb."Receiver Code") then begin
                    AccName := '';
                    CompanIn.Get();
                    AccName := Employee."First Name";
                    if AccName = '' then
                        AccName := Employee."Middle Name";
                    msg := 'Dear ' + AccName + ', you have  been assigned task no. ' + ' ' + HRDiscipMemb."Entry No." + ' ' + 'and the task assigned date is ' + Format(HRDiscipMemb."Task Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                    EmailManager.Create(HRDiscipMemb."Reciever Mail", 'PBO Notifications', msg, true);
                    Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                end;
            until HRDiscipMemb.Next() = 0;
        end;
        DocNo := '';
        FileTabes.Reset();
        FileTabes.SetRange("Entry No.", DocEntry);
        if FileTabes.FindFirst() then begin
            TaskVolumes.Reset();
            TaskVolumes.Init();
            SeriesSetup.Get;
            SeriesSetup.TestField(SeriesSetup."Volume Entry No.");
            DocNo := NoSeriesMgt.GetNextNo(SeriesSetup."Volume Entry No.", 0D, True);
            TaskVolumes."File No." := FileTabes."Entry No.";
            TaskVolumes."Volume Entry No." := DocNo;
            TaskVolumes."Author Code" := FileTabes."Author Code";
            TaskVolumes.Validate(TaskVolumes."Author Code");
            TaskVolumes."Date Received" := Today;
            TaskVolumes."Incoming Date" := FileTabes."Incoming Date";
            TaskVolumes.Reference := FileTabes.Reference;
            TaskVolumes."Task Date" := FileTabes."Task Date";
            TaskVolumes."Receiver Code" := FileTabes."Receiver Code";
            TaskVolumes.Validate(TaskVolumes."Receiver Code");
            TaskVolumes.Department := FileTabes.Department;
            TaskVolumes.Validate(TaskVolumes.Department);
            TaskVolumes.Action := FileTabes.Action;
            TaskVolumes."Task Status" := FileTabes."Task Status"::Forwared;
            TaskVolumes.Feedback := FileTabes.Feedback;
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
                FileTabes.Feedback := '';
                FileTabes.Modify();
            end;
            Message('Email sent successfully');
        end;
        // CurrPage.Close();
        exit('Notified successfully');


    end;

    procedure ConfirmLogin(email: Text; Passcode: Code[40]) Status: Boolean;
    var
        myInt: Integer;
        PortalUser: Record "portal User";
    begin
        Status := false;
        PortalUser.Reset();
        PortalUser.SetRange("Authentication Email", email);
        if PortalUser.FindFirst() then begin
            if PortalUser."Password Value" = Passcode then
                Status := true
            else
                Status := false;
            exit(Status);
        end else
            exit(Status);


    end;

    procedure FnResetPassword(emailaddress: Text)
    var
        PortalUser: Record "portal User";
        RandomDigit: Text;
        Body: Text;

    begin
        PortalUser.Reset;
        PortalUser.SetRange("Authentication Email", emailaddress);
        // PortalUser.SetRange("Record Type", PortalUser."Record Type"::"Job Applicant");
        if PortalUser.FindSet then begin
            RandomDigit := CreateGuid;
            RandomDigit := DelChr(RandomDigit, '=', '{}-01');
            RandomDigit := CopyStr(RandomDigit, 1, 8);
            PortalUser."Password Value" := RandomDigit;
            PortalUser."Last Modified Date" := Today;
            PortalUser."Change Password" := false;
            PortalUser."Record Type" := PortalUser."record type"::"Job Applicant";
            if PortalUser.Modify(true) then begin
                SendEmail(emailaddress);
            end else begin
                Error("Password not reset, Kindly try again!")
            end;
        end else begin
            Error("Email Address is Missing1")
        end;
    end;

    procedure CreatePortalUser(Name: Text; IdNumber: Code[40]; emailaddress: Text)
    var
        myInt: Integer;
        RandomDigit: Text[50];
        entryno: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IDD: Integer;
        PortalUSer: Record "portal User";
    begin
        PortalUSer.Reset;
        PortalUSer.SetRange("Authentication Email", emailaddress);
        if not PortalUSer.FindSet then begin
            PortalUSer.Init;
            PortalUSer."User Name" := Name;
            PortalUSer."Full Name" := Name;
            PortalUSer."Id Number" := IdNumber;
            PortalUSer."Authentication Email" := emailaddress;
            PortalUSer.State := PortalUSer.State::Enabled;
            PortalUSer."Record Type" := PortalUSer."record type"::"Job Applicant";
            RandomDigit := CreateGuid;
            RandomDigit := DelChr(RandomDigit, '=', '{}-01');
            RandomDigit := CopyStr(RandomDigit, 1, 8);
            PortalUSer."Password Value" := RandomDigit;
            PortalUSer."Last Modified Date" := Today;
            if not PortalUSer.Insert(true) then begin
                Error("Account creation not successfull, Kindly contact ICT!")
            end;
        end;

    end;

    procedure SendEmail(emailaddress: Text)
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
        PortalUser.SetRange("Authentication Email", emailaddress);
        if PortalUser.FindSet then begin
            Subject := 'Portal Password';
            Body := 'Dear ' + PortalUser."Full Name" + ', your password for the account: ' + ' <strong>' + PortalUser."Authentication Email" + '</strong> has been reset successfully. Kindly use the password below to access your account<br> <strong>Password: ' + PortalUser."Password Value" + '</strong> <br>';
            Body := Body + ' ' + 'Kind Regards,<br> PBO' + '<br><br>';
            Body := Body + '[This email is automated. Kindly do not reply to it]<br><br>';
            SMTPMail.Create(PortalUser."Authentication Email", Subject, Body, true);
            Smail.Send(SMTPMail, Enum::"Email Scenario"::Default);
        end;
    end;

    procedure NotifyCommittee(MeetingCode: Code[20])
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

    begin
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
                        msg := 'Dear ' + AccName + ', you have  been Selected to be a Executive Commitee Of meeting no. ' + ' ' + MeetingCode + ' ' + 'and the meeting date is ' + Format(PBOMEetings."Meeting Date") + ' ' + 'Kindly for Further Information Contact the Head department. Thank you.';
                        EmailManager.Create(HRDiscipMemb.Email, 'Commitee Notifications', msg, true);
                        Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                    end;
                until HRDiscipMemb.Next() = 0;
        end;

    end;

}
