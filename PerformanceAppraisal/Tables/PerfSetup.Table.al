table 52193482 "Perf Setup"
{
    Caption = 'Performance Appraisal Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Self Assessment Weight %"; Decimal)
        {
            Caption = 'Self-Assessment Weight %';
            InitValue = 40;
        }
        field(3; "Supervisor Assessment Weight %"; Decimal)
        {
            Caption = 'Supervisor Assessment Weight %';
            InitValue = 60;
        }
        field(4; "Score Rounding Precision"; Decimal)
        {
            Caption = 'Score Rounding Precision';
            InitValue = 0.01;
        }
        field(5; "Reminder Days Before Deadline"; Integer)
        {
            Caption = 'Reminder Days Before Deadline';
            InitValue = 5;
        }
        field(6; "Commendation Letter Threshold"; Decimal)
        {
            Caption = 'Commendation Letter Score Threshold';
            InitValue = 4.5;
        }
        field(7; "Warning Letter Threshold"; Decimal)
        {
            Caption = 'Warning Letter Score Threshold';
            InitValue = 2;
        }
        field(8; "Goal No. Series"; Code[20])
        {
            Caption = 'Goal No. Series';
            TableRelation = "No. Series";
        }
        field(9; "Review No. Series"; Code[20])
        {
            Caption = 'Review No. Series';
            TableRelation = "No. Series";
        }
        field(10; "Notify Supervisor on Submit"; Boolean)
        {
            Caption = 'Notify Supervisor when Staff Submits';
            InitValue = true;
        }
        field(11; "Notify Employee on Return"; Boolean)
        {
            Caption = 'Notify Employee when Returned';
            InitValue = true;
        }
        field(12; "Enforce Approver Identity"; Boolean)
        {
            Caption = 'Enforce Approver Identity';
            InitValue = true;
            // When on, each workflow step can only be performed by the user linked
            // (Employee."User ID") to the employee holding that role.
        }
        field(13; "HR Manager No."; Code[20])
        {
            Caption = 'HR Manager (Employee No.)';
            TableRelation = Employee."No.";
        }
        field(14; "GM HR&A No."; Code[20])
        {
            Caption = 'GM HR & Administration (Employee No.)';
            TableRelation = Employee."No.";
        }
        field(15; "Send Email Alerts"; Boolean)
        {
            Caption = 'Send Email Alerts';
            InitValue = true;
        }
        field(20; "AI Enabled"; Boolean)
        {
            Caption = 'Enable AI Assistant';

            trigger OnValidate()
            begin
                // Target and review details leave Business Central for the AI provider, so HR must opt in.
                if "AI Enabled" and GuiAllowed() then
                    if not Confirm(AIConsentQst, false) then
                        Error('');
            end;
        }
        field(21; "AI Endpoint URL"; Text[250])
        {
            Caption = 'AI Endpoint URL';
            InitValue = 'https://api.anthropic.com/v1/messages';
        }
        field(22; "AI Model"; Text[100])
        {
            Caption = 'AI Model';
            InitValue = 'claude-opus-5-5';
        }
        field(23; "AI Use Refusal Fallback"; Boolean)
        {
            Caption = 'Use Refusal Fallback';
            InitValue = true;
            // Lets the API re-run a declined request on Anthropic's recommended fallback model.
        }
        field(24; "AI Max Suggested Targets"; Integer)
        {
            Caption = 'Max. AI Suggested Targets';
            InitValue = 6;
            MinValue = 1;
            MaxValue = 15;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// The API key is kept in isolated storage, never in the table, so it is not exposed
    /// through table data, configuration packages or exports.
    /// </summary>
    [NonDebuggable]
    procedure SetAIApiKey(NewApiKey: SecretText)
    begin
        if NewApiKey.IsEmpty() then begin
            if IsolatedStorage.Contains(AIApiKeyStorageTok, DataScope::Module) then
                IsolatedStorage.Delete(AIApiKeyStorageTok, DataScope::Module);
            exit;
        end;
        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(AIApiKeyStorageTok, NewApiKey, DataScope::Module)
        else
            IsolatedStorage.Set(AIApiKeyStorageTok, NewApiKey, DataScope::Module);
    end;

    [NonDebuggable]
    procedure GetAIApiKey() ApiKey: SecretText
    begin
        if not IsolatedStorage.Get(AIApiKeyStorageTok, DataScope::Module, ApiKey) then
            Error(AIApiKeyMissingErr);
    end;

    procedure HasAIApiKey(): Boolean
    begin
        exit(IsolatedStorage.Contains(AIApiKeyStorageTok, DataScope::Module));
    end;

    var
        AIApiKeyStorageTok: Label 'PerfAIApiKey', Locked = true;
        AIApiKeyMissingErr: Label 'No AI API key has been entered on the Performance Appraisal Setup page.';
        AIConsentQst: Label 'When you use the AI assistant, target, workplan and review details (job title, KRAs, ratings and comments, but not employee names) are sent to the configured AI provider for processing. Do you want to enable it?';
}
