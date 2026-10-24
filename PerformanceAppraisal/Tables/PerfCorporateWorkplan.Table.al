table 52193473 "Perf Corporate Workplan"
{
    // FRD 2.i-iv: the approved Corporate Annual Workplan is uploaded, reviewed by the CEO
    // (objectives, KPIs, strategic initiatives) and cascaded to Directorates, then to
    // Departments. Directorate-level targets can be linked once cascaded to Directorates,
    // department-level targets once cascaded to Departments.
    Caption = 'Corporate Annual Workplan';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Corp. Workplan List";
    DrillDownPageId = "Perf Corp. Workplan List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(3; "Fiscal Year"; Integer)
        {
            Caption = 'Fiscal Year';
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(6; "Strategic Plan Reference"; Code[20])
        {
            Caption = 'Strategic Plan Reference';
        }
        field(7; "Performance Contract Ref."; Code[20])
        {
            Caption = 'Performance Contract Reference';
        }
        field(8; "Approved by CEO"; Boolean)
        {
            Caption = 'Approved by CEO';
            Editable = false;
        }
        field(9; "CEO Approval Date"; Date)
        {
            Caption = 'CEO Approval Date';
            Editable = false;
        }
        field(10; "CEO User ID"; Code[50])
        {
            Caption = 'CEO User ID';
            TableRelation = User."User Name";
            Editable = false;
        }
        field(11; Status; Option)
        {
            Caption = 'Status';
            // Members are appended only, so stored values keep their meaning.
            // Process order: Open -> Approved -> Cascaded to Directorates -> Cascaded to Departments.
            OptionMembers = Open,"Cascaded to Directorates",Approved,"Cascaded to Departments";
            OptionCaption = 'Open,Cascaded to Directorates,Approved by CEO,Cascaded to Departments';
            Editable = false;
        }
        field(12; "Uploaded Document"; BLOB)
        {
            Caption = 'Uploaded Workplan Document';
        }
        field(13; "No. of Objectives"; Integer)
        {
            Caption = 'No. of Objectives';
            FieldClass = FlowField;
            CalcFormula = count("Perf Corporate Workplan Line" where("Workplan No." = field("No.")));
            Editable = false;
        }
        field(14; "Uploaded File Name"; Text[250])
        {
            Caption = 'Uploaded File Name';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Fiscal Year") { }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            "No." := 'WP-' + Format("Fiscal Year");
        end;
    end;

    trigger OnDelete()
    var
        WorkplanLine: Record "Perf Corporate Workplan Line";
    begin
        TestField(Status, Status::Open);
        WorkplanLine.SetRange("Workplan No.", "No.");
        WorkplanLine.DeleteAll(true);
    end;

    procedure ApproveByCEO()
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        // TestField(Status, Status::Open);
        // EmployeeMgt.CheckCurrentUserIsCEO();
        // CalcFields("No. of Objectives");
        // if "No. of Objectives" = 0 then
        // Error(NoObjectivesErr, "No.");

        "Approved by CEO" := true;
        "CEO Approval Date" := Today;
        "CEO User ID" := CopyStr(UserId(), 1, MaxStrLen("CEO User ID"));
        Status := Status::Approved;
        Modify(true);
    end;

    /// <summary>
    /// Flags the objectives as cascaded and creates one Directorate-level goal document per
    /// Responsible Directorate, prefilled with that directorate's objectives. Returns the
    /// number of directorate documents created.
    /// </summary>
    procedure CascadeToDirectorates() DocsCreated: Integer
    var
        WorkplanLine: Record "Perf Corporate Workplan Line";
        GoalHeader: Record "Perf Goal Header";
    begin
        TestField(Status, Status::Approved);
        WorkplanLine.SetRange("Workplan No.", "No.");
        WorkplanLine.SetRange("Responsible Directorate", '');
        if not WorkplanLine.IsEmpty() then
            Error(MissingDirectorateErr);

        WorkplanLine.SetRange("Responsible Directorate");
        WorkplanLine.ModifyAll("Cascaded to Directorate", true);
        Status := Status::"Cascaded to Directorates";
        Modify(true);

        WorkplanLine.SetCurrentKey("Workplan No.", "Line No.");
        if WorkplanLine.FindSet() then
            repeat
                if not GoalDocExists(GoalHeader.Level::Directorate, WorkplanLine."Responsible Directorate") then begin
                    CreateGoalDoc(GoalHeader.Level::Directorate, '', WorkplanLine."Responsible Directorate", true);
                    DocsCreated += 1;
                end;
            until WorkplanLine.Next() = 0;
    end;

    /// <summary>
    /// Flags the objectives as cascaded and creates one Department-level goal document per
    /// Responsible Department, prefilled with that department's objectives. Returns the
    /// number of department documents created.
    /// </summary>
    procedure CascadeToDepartments() DocsCreated: Integer
    var
        WorkplanLine: Record "Perf Corporate Workplan Line";
        GoalHeader: Record "Perf Goal Header";
    begin
        TestField(Status, Status::"Cascaded to Directorates");
        // Objectives without a Responsible Department stay at directorate level only.
        WorkplanLine.SetRange("Workplan No.", "No.");
        WorkplanLine.SetFilter("Responsible Department", '<>%1', '');
        if WorkplanLine.IsEmpty() then
            Error(MissingDepartmentErr);

        WorkplanLine.ModifyAll("Cascaded to Dept.", true);
        Status := Status::"Cascaded to Departments";
        Modify(true);

        WorkplanLine.SetCurrentKey("Workplan No.", "Line No.");
        if WorkplanLine.FindSet() then
            repeat
                if not GoalDocExists(GoalHeader.Level::Department, WorkplanLine."Responsible Department") then begin
                    CreateGoalDoc(GoalHeader.Level::Department, WorkplanLine."Responsible Department", WorkplanLine."Responsible Directorate", true);
                    DocsCreated += 1;
                end;
            until WorkplanLine.Next() = 0;
    end;

    local procedure GoalDocExists(Level: Enum "Perf Goal Level"; OrgUnitCode: Code[20]): Boolean
    var
        GoalHeader: Record "Perf Goal Header";
    begin
        GoalHeader.SetRange("Workplan No.", "No.");
        GoalHeader.SetRange(Level, Level);
        if Level = Level::Directorate then
            GoalHeader.SetRange("Directorate Code", OrgUnitCode)
        else
            GoalHeader.SetRange("Department Code", OrgUnitCode);
        exit(not GoalHeader.IsEmpty());
    end;

    local procedure CreateGoalDoc(Level: Enum "Perf Goal Level"; DepartmentCode: Code[20]; DirectorateCode: Code[20]; Depmetnes: Boolean)
    var
        GoalHeader: Record "Perf Goal Header";
        GoalLine: Record "Perf Goal Line";
        WorkplanLine: Record "Perf Corporate Workplan Line";
        Period: Record "Perf Appraisal Period";
        Head: Record Employee;
    begin
        GoalHeader.Init();
        GoalHeader.Level := Level;
        GoalHeader."Department WP" := Depmetnes;
        GoalHeader."Directorates WP" := Depmetnes;
        GoalHeader."Department Code" := DepartmentCode;
        GoalHeader."Directorate Code" := DirectorateCode;
        GoalHeader."Workplan No." := "No.";
        GoalHeader."Performance Contract Ref." := "Performance Contract Ref.";
        GoalHeader."Strategic Plan Reference" := "Strategic Plan Reference";
        // The document is owned by the Head of Directorate/Department, if one is set up.
        if Level = Level::Directorate then begin
            Head.SetRange("Perf Directorate Code", DirectorateCode);
            Head.SetRange("Perf Is Head of Directorate", true);
        end else begin
            Head.SetRange("Global Dimension 1 Code", DepartmentCode);
            Head.SetRange("Perf Is HOD", true);
        end;
        if Head.FindFirst() then begin
            GoalHeader."Employee No." := Head."No.";
            GoalHeader."Employee Name" := CopyStr(Head.FullName(), 1, MaxStrLen(GoalHeader."Employee Name"));
            GoalHeader."Supervisor No." := Head."Perf Supervisor No.";
        end;
        Period.SetRange(Closed, false);
        Period.SetFilter("Start Date", '<=%1', "Start Date");
        Period.SetFilter("End Date", '>=%1', "Start Date");
        if ("Start Date" <> 0D) and Period.FindFirst() then begin
            GoalHeader."Period Code" := Period.Code;
            GoalHeader."Start Date" := Period."Start Date";
            GoalHeader."End Date" := Period."End Date";
        end else begin
            GoalHeader."Start Date" := "Start Date";
            GoalHeader."End Date" := "End Date";
        end;
        GoalHeader.Insert(true);

        WorkplanLine.SetRange("Workplan No.", "No.");
        if Level = Level::Directorate then
            WorkplanLine.SetRange("Responsible Directorate", DirectorateCode)
        else
            WorkplanLine.SetRange("Responsible Department", DepartmentCode);
        if WorkplanLine.FindSet() then
            repeat
                GoalLine.Init();
                GoalLine."Goal No." := GoalHeader."No.";
                GoalLine."Line No." := 0;
                GoalLine."Workplan No." := "No.";
                GoalLine."Workplan Line No." := WorkplanLine."Line No.";
                GoalLine."Key Result Area" := WorkplanLine."Objective Description";
                GoalLine."Target Description" := WorkplanLine."Strategic Initiative";
                GoalLine."Measurement Criteria" := WorkplanLine."KPI Description";
                GoalLine."Target Value" := WorkplanLine."Target Value";
                GoalLine."Weightage %" := WorkplanLine."Weightage %";
                GoalLine.Insert(true);
            until WorkplanLine.Next() = 0;
    end;

    /// <summary>
    /// FRD Figure 1 "Recommend" decision: when Heads of Directorates/Departments do not
    /// recommend the cascaded objectives, the workplan goes back to the CEO for revision.
    /// </summary>
    procedure ReturnForRevision()
    var
        WorkplanLine: Record "Perf Corporate Workplan Line";
        GoalHeader: Record "Perf Goal Header";
    begin
        if Status = Status::Open then
            exit;
        // Directorate and department documents generated by the cascade are discarded while
        // still untouched by the approval flow; anything already submitted blocks the revision.
        GoalHeader.SetRange("Workplan No.", "No.");
        GoalHeader.SetRange(Status, GoalHeader.Status::Open);
        GoalHeader.DeleteAll(true);
        GoalHeader.SetRange(Status);
        if not GoalHeader.IsEmpty() then
            Error(GoalsLinkedErr, "No.");

        WorkplanLine.SetRange("Workplan No.", "No.");
        WorkplanLine.ModifyAll("Cascaded to Directorate", false);
        WorkplanLine.ModifyAll("Cascaded to Dept.", false);
        "Approved by CEO" := false;
        "CEO Approval Date" := 0D;
        "CEO User ID" := '';
        Status := Status::Open;
        Modify(true);
    end;

    procedure UploadDocument()
    var
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
    begin
        TestField(Status, Status::Open);
        if not UploadIntoStream(UploadTitleTxt, '', '', FileName, InStr) then
            exit;
        "Uploaded Document".CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        "Uploaded File Name" := CopyStr(FileName, 1, MaxStrLen("Uploaded File Name"));
        Modify(true);
    end;

    procedure DownloadDocument()
    var
        InStr: InStream;
        FileName: Text;
    begin
        CalcFields("Uploaded Document");
        if not "Uploaded Document".HasValue() then
            Error(NoDocumentErr, "No.");
        "Uploaded Document".CreateInStream(InStr);
        FileName := "Uploaded File Name";
        if FileName = '' then
            FileName := "No.";
        DownloadFromStream(InStr, '', '', '', FileName);
    end;

    procedure IsReadyForTargetSetting(Level: Enum "Perf Goal Level"): Boolean
    begin
        case Level of
            Level::Directorate:
                exit(Status in [Status::"Cascaded to Directorates", Status::"Cascaded to Departments"]);
            else
                exit(Status = Status::"Cascaded to Departments");
        end;
    end;

    var
        NoObjectivesErr: Label 'Workplan %1 has no objectives. Enter the objectives and KPIs before CEO approval.', Comment = '%1 = workplan no.';
        MissingDirectorateErr: Label 'Every objective must have a Responsible Directorate before it can be cascaded to Directorates.';
        MissingDepartmentErr: Label 'At least one objective must have a Responsible Department before the workplan can be cascaded to Departments.';
        GoalsLinkedErr: Label 'Workplan %1 cannot be returned for revision because individual targets are already linked to it.', Comment = '%1 = workplan no.';
        NoDocumentErr: Label 'No workplan document has been uploaded for %1.', Comment = '%1 = workplan no.';
        UploadTitleTxt: Label 'Upload Approved Corporate Annual Workplan';
}
