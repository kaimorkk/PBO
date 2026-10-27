page 52193475 "Perf Setup Card"
{
    Caption = 'Performance Appraisal Setup';
    PageType = Card;
    SourceTable = "Perf Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Scoring)
            {
                Caption = 'Scoring Formula';
                field("Self Assessment Weight %"; Rec."Self Assessment Weight %") { ApplicationArea = All; }
                field("Supervisor Assessment Weight %"; Rec."Supervisor Assessment Weight %") { ApplicationArea = All; }
                field("Score Rounding Precision"; Rec."Score Rounding Precision") { ApplicationArea = All; }
            }
            group(Roles)
            {
                Caption = 'Roles';
                field("HR Manager No."; Rec."HR Manager No.") { ApplicationArea = All; }
                field("GM HR&A No."; Rec."GM HR&A No.") { ApplicationArea = All; }
                field("Enforce Approver Identity"; Rec."Enforce Approver Identity")
                {
                    ApplicationArea = All;
                    ToolTip = 'When on, each step can only be performed by the user linked (Employee User ID) to the staff member, HOD, next level supervisor, CEO (Is CEO), HR Manager or GM HR&A.';
                }
            }
            group(Letters)
            {
                Caption = 'Letters';
                field("Commendation Letter Threshold"; Rec."Commendation Letter Threshold") { ApplicationArea = All; }
                field("Warning Letter Threshold"; Rec."Warning Letter Threshold") { ApplicationArea = All; }
            }
            group(Numbering)
            {
                Caption = 'No. Series';
                field("Goal No. Series"; Rec."Goal No. Series") { ApplicationArea = All; }
                field("Review No. Series"; Rec."Review No. Series") { ApplicationArea = All; }
            }
            group(Notifications)
            {
                Caption = 'Notifications';
                field("Send Email Alerts"; Rec."Send Email Alerts") { ApplicationArea = All; }
                field("Reminder Days Before Deadline"; Rec."Reminder Days Before Deadline") { ApplicationArea = All; }
                field("Notify Supervisor on Submit"; Rec."Notify Supervisor on Submit") { ApplicationArea = All; }
                field("Notify Employee on Return"; Rec."Notify Employee on Return") { ApplicationArea = All; }
            }
            group(AIAssistant)
            {
                Caption = 'AI Assistant';
                field("AI Enabled"; Rec."AI Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Lets staff draft targets from the workplan, and supervisors draft appraisal feedback, with an AI model. Users always review the drafts before anything is submitted.';
                }
                field(AIApiKey; ApiKeyText)
                {
                    Caption = 'API Key';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'The API key for the AI provider. It is kept in isolated storage, not in the setup table. Clear the field to remove the key.';

                    trigger OnValidate()
                    begin
                        Rec.SetAIApiKey(ApiKeyText);
                        SetApiKeyPlaceholder();
                    end;
                }
                field("AI Endpoint URL"; Rec."AI Endpoint URL") { ApplicationArea = All; }
                field("AI Model"; Rec."AI Model") { ApplicationArea = All; }
                field("AI Use Refusal Fallback"; Rec."AI Use Refusal Fallback")
                {
                    ApplicationArea = All;
                    ToolTip = 'If the model declines a request, the AI service re-runs it on its recommended fallback model instead of returning an error. Turn off for models that do not support fallbacks.';
                }
                field("AI Max Suggested Targets"; Rec."AI Max Suggested Targets") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(RatingScale)
            {
                Caption = 'Rating Scale';
                ApplicationArea = All;
                Image = SetupList;
                RunObject = page "Perf Rating Scale";
            }
            action(AppraisalPeriods)
            {
                Caption = 'Appraisal Periods';
                ApplicationArea = All;
                Image = Period;
                RunObject = page "Perf Appraisal Period List";
            }
        }
        area(Processing)
        {
            action(TestAIConnection)
            {
                Caption = 'Test AI Connection';
                ApplicationArea = All;
                Image = TestFile;
                Enabled = Rec."AI Enabled";

                trigger OnAction()
                var
                    PerfAIMgt: Codeunit "Perf AI Mgt";
                begin
                    CurrPage.SaveRecord();
                    PerfAIMgt.TestConnection();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
        SetApiKeyPlaceholder();
    end;

    local procedure SetApiKeyPlaceholder()
    begin
        // Never show the stored key; a placeholder only signals that one exists.
        if Rec.HasAIApiKey() then
            ApiKeyText := '**********'
        else
            ApiKeyText := '';
    end;

    var
        [NonDebuggable]
        ApiKeyText: Text;
}
