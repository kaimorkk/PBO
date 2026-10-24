codeunit 52193432 "PBO  Notifications"
{
    trigger OnRun()
    var
        myInt: Integer;
    begin
        UpdateEmployeesOnLeave(Today, Today);
        NotifyTaskDueDate();
    end;

    procedure UpdateEmployeesOnLeave(StartDate: Date; EndDate: Date) Data: Text
    var
        myInt: Integer;
        LeaveApplication: Record "HR Leave Application";
        HrEmployees: Record Employee;
        EmploReec: Record Employee;
    begin
        if StartDate = 0D then
            StartDate := Today;
        if EndDate = 0D then
            EndDate := Today;
        EmploReec.Reset();
        EmploReec.SetRange(Status, EmploReec.Status::Active);
        if EmploReec.FindSet() then begin
            repeat
                LeaveApplication.Reset();
                LeaveApplication.SetRange("Employee No", EmploReec."No.");
                LeaveApplication.SetFilter("Start Date", '<=%1', Today());
                LeaveApplication.SetFilter("End Date", '>=%1', Today());
                // LeaveApplication.SetRange(Status, LeaveApplication.Status::Approved);
                if LeaveApplication.FindFirst() then begin
                    HrEmployees.Reset();
                    HrEmployees.SetRange(Status, HrEmployees.Status::Active);
                    HrEmployees.SetRange("No.", LeaveApplication."Employee No");
                    if HrEmployees.FindSet() then begin
                        HrEmployees."On leave" := true;
                        HrEmployees.Remarks := LeaveApplication.Description;
                        HrEmployees.Modify();
                    end;
                end;
            until EmploReec.Next() = 0;
        end;
    end;

    procedure NotifyTaskDueDate()
    var
        CurrDate: Date;

        Emp: Record Employee;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailSubject: Text;
        EmailBody: Text;
        EmailRecepient: List of [Text];
        PRSET: record "HR setup";
        FilesTable: Record "Files Table";
        UserSet: Record "User Setup";
        HODEmail: Text;
        TaskVolumes: Record "Task Volumes";
    begin
        PRSET.Get();
        IF PRSET."Notify Vie Mail" = true then begin
            UserSet.Reset();
            UserSet.SetRange(HOD, true);
            if UserSet.FindFirst() then
                HODEmail := UserSet."E-Mail";
            CurrDate := Today;
            //1st
            FilesTable.Reset();
            FilesTable.SetRange("Task Status", FilesTable."Task Status"::Forwared);
            if FilesTable.FindSet() then begin
                repeat
                    if FilesTable."Due Date" = CurrDate then begin
                        TaskVolumes.Reset();
                        TaskVolumes.SetRange("Task Volume", FilesTable."Entry No.");
                        if TaskVolumes.FindSet() then begin
                            repeat
                                if TaskVolumes.Receiver <> '' then begin
                                    Emp.Reset();
                                    Emp.SetRange(Status, Emp.Status::Active);
                                    Emp.SetRange("No.", TaskVolumes.Receiver);
                                    if Emp.FindFirst() then begin
                                        EmailRecepient.Add(HODEmail);
                                        EmailRecepient.Add(Emp."Company E-Mail");
                                        EmailSubject := 'TASK REMINDER';
                                        EmailBody := 'This is to remind you that TASK: <b> No. ' + FilesTable."Entry No." + ' - ' + Format(FilesTable."File Type") + '</b>, is due Today: ' + Format(Today) + '.';
                                        EmailMessage.Create(
                                            EmailRecepient,
                                            EmailSubject,
                                            EmailBody,
                                            true
                                        );
                                        Email.Send(EmailMessage);
                                    end;
                                end;
                            until TaskVolumes.Next() = 0;
                        end;
                        // Emp.Reset();
                        // Emp.SetRange(Status, Emp.Status::Active);
                        // Emp.SetRange("No.", FilesTable."Author Code");
                        // if Emp.FindFirst() then begin
                        //     EmailRecepient.Add(HODEmail);
                        //     EmailRecepient.Add(Emp."Company E-Mail");
                        //     repeat
                        //         EmailSubject := 'TASK REMINDER';
                        //         EmailBody := 'This is to remind you that TASK: <b> No. ' + FilesTable."Entry No." + ' - ' + Format(FilesTable."File Type") + '</b>, is due Today: ' + Format(Today) + '.';
                        //         EmailMessage.Create(
                        //             EmailRecepient,
                        //             EmailSubject,
                        //             EmailBody,
                        //             true
                        //         );
                        //         Email.Send(EmailMessage);
                        //     until Emp.Next() = 0;

                        // end;
                    end;
                    //2nd
                    if FilesTable."Due Date" = CalcDate('1W', CurrDate) then begin
                        TaskVolumes.Reset();
                        TaskVolumes.SetRange("Task Volume", FilesTable."Entry No.");
                        if TaskVolumes.FindSet() then begin
                            repeat
                                if TaskVolumes.Receiver <> '' then begin
                                    Emp.Reset();
                                    Emp.SetRange(Status, Emp.Status::Active);
                                    Emp.SetRange("No.", TaskVolumes.Receiver);
                                    if Emp.FindFirst() then begin
                                        EmailRecepient.Add(HODEmail);
                                        EmailRecepient.Add(Emp."Company E-Mail");
                                        EmailSubject := 'TASK REMINDER';
                                        EmailBody := 'This is to remind you that TASK: <b> No. ' + FilesTable."Entry No." + ' - ' + Format(FilesTable."File Type") + '</b>, will be due on: ' + Format(FilesTable."Due Date") + '.';
                                        EmailMessage.Create(
                                            EmailRecepient,
                                            EmailSubject,
                                            EmailBody,
                                            true
                                        );
                                        Email.Send(EmailMessage);
                                    end;
                                end;
                            until TaskVolumes.Next() = 0;
                        end;
                        // Emp.Reset();
                        // Emp.SetRange(Status, Emp.Status::Active);
                        // Emp.SetRange("No.", FilesTable."Author Code");
                        // if Emp.FindSet() then begin
                        //     EmailRecepient.Add(HODEmail);
                        //     EmailRecepient.Add(Emp."Company E-Mail");
                        //     repeat
                        //         EmailSubject := 'TASK REMINDER';
                        //         EmailBody := 'This is to remind you that TASK: <b> No. ' + FilesTable."Entry No." + ' - ' + Format(FilesTable."File Type") + '</b>, Will be due on : ' + Format(FilesTable."Due Date") + '.';
                        //         EmailMessage.Create(
                        //             EmailRecepient,
                        //             EmailSubject,
                        //             EmailBody,
                        //             true
                        //         );
                        //         Email.Send(EmailMessage);
                        //     until Emp.Next() = 0;
                        // end;
                    end;
                    //3rd
                    if FilesTable."Due Date" = CalcDate('2W', CurrDate) then begin
                        TaskVolumes.Reset();
                        TaskVolumes.SetRange("Task Volume", FilesTable."Entry No.");
                        if TaskVolumes.FindSet() then begin
                            repeat
                                if TaskVolumes.Receiver <> '' then begin
                                    Emp.Reset();
                                    Emp.SetRange(Status, Emp.Status::Active);
                                    Emp.SetRange("No.", TaskVolumes.Receiver);
                                    if Emp.FindFirst() then begin
                                        EmailRecepient.Add(HODEmail);
                                        EmailRecepient.Add(Emp."Company E-Mail");
                                        EmailSubject := 'TASK REMINDER';
                                        EmailBody := 'This is to remind you that TASK: <b> No. ' + FilesTable."Entry No." + ' - ' + Format(FilesTable."File Type") + '</b>, will be due on: ' + Format(FilesTable."Due Date") + '.';
                                        EmailMessage.Create(
                                            EmailRecepient,
                                            EmailSubject,
                                            EmailBody,
                                            true
                                        );
                                        Email.Send(EmailMessage);
                                    end;
                                end;
                            until TaskVolumes.Next() = 0;
                        end;
                        // Emp.Reset();
                        // Emp.SetRange(Status, Emp.Status::Active);
                        // Emp.SetRange("No.", FilesTable."Author Code");
                        // if Emp.FindSet() then begin
                        //     EmailRecepient.Add(HODEmail);
                        //     EmailRecepient.Add(Emp."Company E-Mail");
                        //     repeat
                        //         EmailSubject := 'TASK REMINDER';
                        //         EmailBody := 'This is to remind you that TASK: <b> No. ' + FilesTable."Entry No." + ' - ' + Format(FilesTable."File Type") + '</b>, will be due on: ' + Format(FilesTable."Due Date") + '.';
                        //         EmailMessage.Create(
                        //                                 EmailRecepient,
                        //                                 EmailSubject,
                        //                                 EmailBody,
                        //                                 true
                        //                             );
                        //         Email.Send(EmailMessage);
                        //     until Emp.Next() = 0;
                        // end;
                    end;
                until FilesTable.Next() = 0;
            end;
        END;
    end;


}
