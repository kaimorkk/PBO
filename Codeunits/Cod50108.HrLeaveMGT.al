 
codeunit 50108 "HR Leave Jnl Management"
{
    Permissions = tabledata "Insurance Journal Template" = imd,
                  tabledata "Insurance Journal Batch" = imd;

    trigger OnRun()
    begin
        Error('');
    end;

    var
        Text000: Label 'Leave';
        Text001: Label 'Leave Journal';
        Text002: Label 'DEFAULT';
        Text003: Label 'Default Journal';
        OldInsuranceNo: Code[20];
        OldFANo: Code[20];
        OpenFromBatch: Boolean;


    procedure TemplateSelection(FormID: Integer; var InsuranceJnlLine: Record "HR Leave Journal Line"; var JnlSelected: Boolean)
    var
        InsuranceJnlTempl: Record "HR Leave Journal Template";
        InsuranceJnlBatch: Record "HR Leave Journal Batch";
        JornTmp: Record "HR Leave Journal Template";
    begin
        JnlSelected := true;

        InsuranceJnlTempl.Reset();
        // InsuranceJnlTempl.SetRange("Form ID", FormID);
        insuranceJnlTempl.SetRange(name, Text000);
        case InsuranceJnlTempl.Count of

            0:

                begin
                    // JornTmp.Reset();
                    // JornTmp.SetRange(JornTmp.Name, 'LEAVE');
                    // JornTmp.DeleteAll(true);
                    // InsuranceJnlLine.SetRange("Journal Template Name", Text000);
                    // InsuranceJnlLine.DeleteAll(true);
                    // InsuranceJnlBatch.SetRange("Journal Template Name", Text000);
                    // InsuranceJnlBatch.DeleteAll();
                    InsuranceJnlTempl.Init();
                    InsuranceJnlTempl.Name := Text000;
                    InsuranceJnlTempl.Description := Text001;
                    InsuranceJnlTempl.Validate("Form ID");
                    InsuranceJnlTempl.Insert();
                    Commit();
                end;

            1:
                InsuranceJnlTempl.Find('-');
            else
                JnlSelected := Page.RunModal(0, InsuranceJnlTempl) = Action::LookupOK;
        end;
        if JnlSelected then begin
            InsuranceJnlLine.FilterGroup := 2;
            InsuranceJnlLine.SetRange("Journal Template Name", InsuranceJnlTempl.Name);
            InsuranceJnlLine.FilterGroup := 0;
            if OpenFromBatch then begin
                InsuranceJnlLine."Journal Template Name" := '';
                Page.Run(InsuranceJnlTempl."Form ID", InsuranceJnlLine);
            end;
        end;
    end;


    procedure TemplateSelectionFromBatch(var InsuranceJnlBatch: Record "HR Leave Journal Batch")
    var
        InsuranceJnlLine: Record "HR Leave Journal Line";
        InsuranceJnlTempl: Record "HR Leave Journal Template";
        JnlSelected: Boolean;
    begin
        OpenFromBatch := true;
        InsuranceJnlTempl.Get(InsuranceJnlBatch."Journal Template Name");
        InsuranceJnlTempl.TestField("Form ID");
        InsuranceJnlBatch.TestField(Name);

        InsuranceJnlLine.FilterGroup := 2;
        InsuranceJnlLine.SetRange("Journal Template Name", InsuranceJnlTempl.Name);
        InsuranceJnlLine.FilterGroup := 0;

        InsuranceJnlLine."Journal Template Name" := '';
        InsuranceJnlLine."Journal Batch Name" := InsuranceJnlBatch.Name;
        Page.Run(InsuranceJnlTempl."Form ID", InsuranceJnlLine);
    end;


    procedure OpenJournal(var CurrentJnlBatchName: Code[10]; var InsuranceJnlLine: Record "HR Leave Journal Line")
    begin
        CheckTemplateName(InsuranceJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        InsuranceJnlLine.FilterGroup := 2;
        InsuranceJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        InsuranceJnlLine.FilterGroup := 0;
    end;


    procedure OpenJnlBatch(var InsuranceJnlBatch: Record "HR Leave Journal Batch")
    var
        InsuranceJnlTemplate: Record "HR Leave Journal Template";
        InsuranceJnlLine: Record "HR Leave Journal Line";
        JnlSelected: Boolean;
    begin
        if InsuranceJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        InsuranceJnlBatch.FilterGroup(2);
        if InsuranceJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            InsuranceJnlBatch.FilterGroup(0);
            exit;
        end;
        InsuranceJnlBatch.FilterGroup(0);

        if not InsuranceJnlBatch.Find('-') then begin
            if not InsuranceJnlTemplate.Find('-') then
                TemplateSelection(0, InsuranceJnlLine, JnlSelected);
            if InsuranceJnlTemplate.Find('-') then
                CheckTemplateName(InsuranceJnlTemplate.Name, InsuranceJnlBatch.Name);
        end;
        InsuranceJnlBatch.Find('-');
        JnlSelected := true;
        if InsuranceJnlBatch.GetFilter("Journal Template Name") <> '' then
            InsuranceJnlTemplate.SetRange(Name, InsuranceJnlBatch.GetFilter("Journal Template Name"));
        case InsuranceJnlTemplate.Count of
            1:
                InsuranceJnlTemplate.Find('-');
            else
                JnlSelected := Page.RunModal(0, InsuranceJnlTemplate) = Action::LookupOK;
        end;
        if not JnlSelected then
            Error('');

        InsuranceJnlBatch.FilterGroup(2);
        InsuranceJnlBatch.SetRange("Journal Template Name", InsuranceJnlTemplate.Name);
        InsuranceJnlBatch.FilterGroup(0);
    end;


    procedure CheckName(CurrentJnlBatchName: Code[10]; var InsuranceJnlLine: Record "HR Leave Journal Line")
    var
        InsuranceJnlBatch: Record "HR Leave Journal Batch";
    begin
        InsuranceJnlBatch.Get(InsuranceJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;


    procedure SetName(CurrentJnlBatchName: Code[10]; var InsuranceJnlLine: Record "HR Leave Journal Line")
    begin
        InsuranceJnlLine.FilterGroup := 2;
        InsuranceJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        InsuranceJnlLine.FilterGroup := 0;
        if InsuranceJnlLine.Find('-') then;
    end;


    procedure LookupName(var CurrentJnlBatchName: Code[10]; var InsuranceJnlLine: Record "HR Leave Journal Line"): Boolean
    var
        InsuranceJnlBatch: Record "HR Leave Journal Batch";
    begin
        Commit();

        InsuranceJnlBatch."Journal Template Name" := InsuranceJnlLine.GetRangeMax("Journal Template Name");
        InsuranceJnlBatch.Name := InsuranceJnlLine.GetRangeMax("Journal Batch Name");
        InsuranceJnlBatch.FilterGroup(2);
        InsuranceJnlBatch.SetRange("Journal Template Name", InsuranceJnlBatch."Journal Template Name");
        InsuranceJnlBatch.FilterGroup(0);
        if Page.RunModal(0, InsuranceJnlBatch) = Action::LookupOK then begin
            CurrentJnlBatchName := InsuranceJnlBatch.Name;
            SetName(CurrentJnlBatchName, InsuranceJnlLine);
        end;
    end;


    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        InsuranceJnlBatch: Record "HR Leave Journal Batch";
    begin
        if not InsuranceJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            InsuranceJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
            if not InsuranceJnlBatch.Find('-') then begin
                InsuranceJnlBatch.Init();
                InsuranceJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                InsuranceJnlBatch.SetupNewBatch();
                InsuranceJnlBatch.Name := Text002;
                InsuranceJnlBatch.Description := Text003;
                InsuranceJnlBatch.Insert(true);
                Commit();
            end;
            CurrentJnlBatchName := InsuranceJnlBatch.Name;
        end;
    end;


    procedure GetDescriptions(InsuranceJnlLine: Record "HR Leave Journal Line"; var InsuranceDescription: Text[30]; var FADescription: Text[30])
    var
        Insurance: Record "HR Leave Application";
        FA: Record Employee;
    begin
        if InsuranceJnlLine."Document No." <> OldInsuranceNo then begin
            InsuranceDescription := '';
            if InsuranceJnlLine."Document No." <> '' then
                if Insurance.Get(InsuranceJnlLine."Document No.") then
                    InsuranceDescription := Insurance.Description;
            OldInsuranceNo := InsuranceJnlLine."Document No.";
        end;
        if InsuranceJnlLine."Staff No." <> OldFANo then begin
            FADescription := '';
            if InsuranceJnlLine."Staff No." <> '' then
                if FA.Get(InsuranceJnlLine."Staff No.") then
                    FADescription := FA."First Name";
            OldFANo := FA."No.";
        end;
    end;
}
