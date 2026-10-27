codeunit 52193439 "Perf AI Mgt"
{
    // AI assistant for the appraisal process, backed by the Anthropic Claude Messages API.
    // Everything it produces is a draft: target suggestions are confirmed on a dialog and review
    // feedback is only written into blank fields, so staff and supervisors stay accountable.
    // Employee names and numbers are never sent; only job context, targets, ratings and comments.

    /// <summary>
    /// FRD 2.v: proposes individual targets cascaded from the approved workplan objectives,
    /// shows them for review and inserts the rows the user keeps.
    /// </summary>
    procedure SuggestGoalLines(GoalHeader: Record "Perf Goal Header")
    var
        TempSuggestion: Record "Perf AI Goal Suggestion" temporary;
        GoalLine: Record "Perf Goal Line";
        SuggestionsPage: Page "Perf AI Goal Suggestions";
        InsertedCount: Integer;
    begin
        GoalHeader.TestStatusOpen();
        GoalHeader.TestField("Employee No.");
        GoalHeader.TestField("Workplan No.");

        GetGoalSuggestions(GoalHeader, TempSuggestion);
        if TempSuggestion.IsEmpty() then
            Error(NoSuggestionsErr);

        SuggestionsPage.SetSuggestions(TempSuggestion);
        if SuggestionsPage.RunModal() <> Action::OK then
            exit;

        TempSuggestion.SetRange(Select, true);
        if TempSuggestion.FindSet() then
            repeat
                GoalLine.Init();
                GoalLine."Goal No." := GoalHeader."No.";
                GoalLine."Line No." := 0;
                GoalLine.InitFromHeader();
                GoalLine."Key Result Area" := TempSuggestion."Key Result Area";
                GoalLine."Target Description" := TempSuggestion."Target Description";
                GoalLine."Measurement Criteria" := TempSuggestion."Measurement Criteria";
                GoalLine."Target Value" := TempSuggestion."Target Value";
                GoalLine."Weightage %" := TempSuggestion."Weightage %";
                if TempSuggestion."Workplan Line No." <> 0 then
                    GoalLine.Validate("Workplan Line No.", TempSuggestion."Workplan Line No.");
                GoalLine.Insert(true);
                InsertedCount += 1;
            until TempSuggestion.Next() = 0;

        GoalHeader.CalcFields("Total Weightage %");
        Message(TargetsInsertedMsg, InsertedCount, GoalHeader."Total Weightage %");
    end;

    /// <summary>
    /// Drafts the supervisor's appraisal narrative, per-KRA comments and training needs from the
    /// achievements and ratings. Existing comments and training needs are left untouched.
    /// </summary>
    procedure DraftReviewFeedback(var ReviewHeader: Record "Perf Review Header")
    var
        ReviewLine: Record "Perf Review Line";
        Result: JsonObject;
        Lines: JsonArray;
        LineToken: JsonToken;
        LineObject: JsonObject;
        FilledCount: Integer;
        LF: Text[1];
    begin
        ReviewHeader.TestField(Status, ReviewHeader.Status::"Self-Assessment Submitted");
        ReviewLine.SetRange("Review No.", ReviewHeader."No.");
        if ReviewLine.IsEmpty() then
            Error(NoReviewLinesErr, ReviewHeader."No.");

        Result := GenerateJson(ReviewFeedbackSystemPrompt(), BuildReviewContext(ReviewHeader), ReviewFeedbackSchema());

        Lines := GetArray(Result, 'lines');
        foreach LineToken in Lines do begin
            LineObject := LineToken.AsObject();
            if ReviewLine.Get(ReviewHeader."No.", GetInteger(LineObject, 'line_no')) then
                if FillBlankLineFeedback(ReviewLine, LineObject) then begin
                    ReviewLine.Modify(true);
                    FilledCount += 1;
                end;
        end;

        LF[1] := 10;
        ReviewHeader."AI Feedback Draft" := CopyStr(
            StrSubstNo(FeedbackDraftTxt, GetText(Result, 'overall_summary'), GetText(Result, 'strengths'), GetText(Result, 'development_areas'), LF),
            1, MaxStrLen(ReviewHeader."AI Feedback Draft"));
        ReviewHeader.Modify(true);

        Message(FeedbackDraftedMsg, FilledCount);
    end;

    procedure TestConnection()
    var
        Reply: Text;
    begin
        Reply := GenerateText('You are a connectivity check.', 'Reply with exactly: OK', 64);
        Message(ConnectionOkMsg, GetModel(), Reply);
    end;

    local procedure GetGoalSuggestions(GoalHeader: Record "Perf Goal Header"; var TempSuggestion: Record "Perf AI Goal Suggestion" temporary)
    var
        PerfSetup: Record "Perf Setup";
        Result: JsonObject;
        Targets: JsonArray;
        TargetToken: JsonToken;
        TargetObject: JsonObject;
        AllowedLineNos: List of [Integer];
        WorkplanLineNo: Integer;
        EntryNo: Integer;
    begin
        PerfSetup.Get();
        Result := GenerateJson(GoalSuggestionSystemPrompt(), BuildGoalContext(GoalHeader, PerfSetup, AllowedLineNos), GoalSuggestionSchema());

        Targets := GetArray(Result, 'targets');
        foreach TargetToken in Targets do begin
            TargetObject := TargetToken.AsObject();
            EntryNo += 1;
            TempSuggestion.Init();
            TempSuggestion."Entry No." := EntryNo;
            // Only keep a workplan link the model was actually offered, so validation on insert cannot fail.
            WorkplanLineNo := GetInteger(TargetObject, 'workplan_line_no');
            if AllowedLineNos.Contains(WorkplanLineNo) then
                TempSuggestion."Workplan Line No." := WorkplanLineNo;
            TempSuggestion."Key Result Area" := CopyStr(GetText(TargetObject, 'key_result_area'), 1, MaxStrLen(TempSuggestion."Key Result Area"));
            TempSuggestion."Target Description" := CopyStr(GetText(TargetObject, 'target_description'), 1, MaxStrLen(TempSuggestion."Target Description"));
            TempSuggestion."Measurement Criteria" := CopyStr(GetText(TargetObject, 'measurement_criteria'), 1, MaxStrLen(TempSuggestion."Measurement Criteria"));
            TempSuggestion."Target Value" := GetDecimal(TargetObject, 'target_value');
            TempSuggestion."Weightage %" := GetDecimal(TargetObject, 'weightage_percent');
            TempSuggestion.Rationale := CopyStr(GetText(TargetObject, 'rationale'), 1, MaxStrLen(TempSuggestion.Rationale));
            TempSuggestion.Insert();
            if EntryNo >= PerfSetup."AI Max Suggested Targets" then
                break;
        end;
    end;

    local procedure FillBlankLineFeedback(var ReviewLine: Record "Perf Review Line"; LineObject: JsonObject) Changed: Boolean
    begin
        if ReviewLine."Supervisor Comments" = '' then begin
            ReviewLine."Supervisor Comments" := CopyStr(GetText(LineObject, 'supervisor_comment'), 1, MaxStrLen(ReviewLine."Supervisor Comments"));
            Changed := ReviewLine."Supervisor Comments" <> '';
        end;
        if ReviewLine."Training Need" = '' then begin
            ReviewLine."Training Need" := CopyStr(GetText(LineObject, 'training_need'), 1, MaxStrLen(ReviewLine."Training Need"));
            Changed := Changed or (ReviewLine."Training Need" <> '');
        end;
    end;

    local procedure BuildGoalContext(GoalHeader: Record "Perf Goal Header"; PerfSetup: Record "Perf Setup"; var AllowedLineNos: List of [Integer]): Text
    var
        Employee: Record Employee;
        WorkplanLine: Record "Perf Corporate Workplan Line";
        GoalLine: Record "Perf Goal Line";
        Context: JsonObject;
        Objectives: JsonArray;
        ExistingTargets: JsonArray;
        Item: JsonObject;
        ContextText: Text;
    begin
        GoalHeader.CalcFields("Total Weightage %");
        Employee.Get(GoalHeader."Employee No.");
        Context.Add('job_title', Employee."Job Title");
        Context.Add('grade', Employee."Perf Grade");
        Context.Add('goal_level', Format(GoalHeader.Level));
        Context.Add('directorate', GoalHeader."Directorate Code");
        Context.Add('department', GoalHeader."Department Code");
        Context.Add('period_start', Format(GoalHeader."Start Date", 0, 9));
        Context.Add('period_end', Format(GoalHeader."End Date", 0, 9));
        Context.Add('remaining_weightage_percent', 100 - GoalHeader."Total Weightage %");
        Context.Add('max_targets', PerfSetup."AI Max Suggested Targets");

        WorkplanLine.SetRange("Workplan No.", GoalHeader."Workplan No.");
        if GoalHeader.Level = GoalHeader.Level::Directorate then
            WorkplanLine.SetRange("Cascaded to Directorate", true)
        else
            WorkplanLine.SetRange("Cascaded to Dept.", true);
        if WorkplanLine.FindSet() then
            repeat
                Clear(Item);
                Item.Add('workplan_line_no', WorkplanLine."Line No.");
                Item.Add('strategic_objective', WorkplanLine."Objective Description");
                Item.Add('strategic_initiative', WorkplanLine."Strategic Initiative");
                Item.Add('kpi', WorkplanLine."KPI Description");
                Item.Add('target_value', WorkplanLine."Target Value");
                Item.Add('responsible_directorate', WorkplanLine."Responsible Directorate");
                Item.Add('responsible_department', WorkplanLine."Responsible Department");
                Objectives.Add(Item);
                AllowedLineNos.Add(WorkplanLine."Line No.");
            until WorkplanLine.Next() = 0;
        if Objectives.Count() = 0 then
            Error(NoCascadedObjectivesErr, GoalHeader."Workplan No.", GoalHeader.Level);
        Context.Add('workplan_objectives', Objectives);

        GoalLine.SetRange("Goal No.", GoalHeader."No.");
        if GoalLine.FindSet() then
            repeat
                Clear(Item);
                Item.Add('key_result_area', GoalLine."Key Result Area");
                Item.Add('target_description', GoalLine."Target Description");
                Item.Add('weightage_percent', GoalLine."Weightage %");
                ExistingTargets.Add(Item);
            until GoalLine.Next() = 0;
        Context.Add('existing_targets', ExistingTargets);

        Context.WriteTo(ContextText);
        exit(ContextText);
    end;

    local procedure BuildReviewContext(ReviewHeader: Record "Perf Review Header"): Text
    var
        Employee: Record Employee;
        ReviewLine: Record "Perf Review Line";
        RatingScale: Record "Perf Rating Scale";
        MitigatingFactor: Record "Perf Mitigating Factor";
        Context: JsonObject;
        Lines: JsonArray;
        Scale: JsonArray;
        Factors: JsonArray;
        Item: JsonObject;
        ContextText: Text;
    begin
        if Employee.Get(ReviewHeader."Employee No.") then begin
            Context.Add('job_title', Employee."Job Title");
            Context.Add('grade', Employee."Perf Grade");
        end;
        Context.Add('period_type', Format(ReviewHeader."Period Type"));
        Context.Add('review_start', Format(ReviewHeader."Review Start Date", 0, 9));
        Context.Add('review_end', Format(ReviewHeader."Review End Date", 0, 9));
        Context.Add('self_assessment_score', ReviewHeader."Self Assessment Score");

        if RatingScale.FindSet() then
            repeat
                Clear(Item);
                Item.Add('rating', RatingScale.Rating);
                Item.Add('description', RatingScale.Description);
                Item.Add('min_achievement_percent', RatingScale."Min Achievement %");
                Scale.Add(Item);
            until RatingScale.Next() = 0;
        Context.Add('rating_scale', Scale);

        ReviewLine.SetRange("Review No.", ReviewHeader."No.");
        if ReviewLine.FindSet() then
            repeat
                Clear(Item);
                Item.Add('line_no', ReviewLine."Line No.");
                Item.Add('key_result_area', ReviewLine."Key Result Area");
                Item.Add('target_description', ReviewLine."Target Description");
                Item.Add('measurement_criteria', ReviewLine."Measurement Criteria");
                Item.Add('weightage_percent', ReviewLine."Weightage %");
                Item.Add('target_value', ReviewLine."Target Value");
                Item.Add('actual_achievement', ReviewLine."Actual Achievement");
                Item.Add('achievement_percent', ReviewLine."Achievement %");
                Item.Add('self_rating', ReviewLine."Self Rating");
                Item.Add('supervisor_rating', ReviewLine."Supervisor Rating");
                Item.Add('employee_comments', ReviewLine."Employee Comments");
                Item.Add('existing_supervisor_comments', ReviewLine."Supervisor Comments");
                Lines.Add(Item);
            until ReviewLine.Next() = 0;
        Context.Add('review_lines', Lines);

        MitigatingFactor.SetRange("Review No.", ReviewHeader."No.");
        if MitigatingFactor.FindSet() then
            repeat
                Clear(Item);
                Item.Add('type', Format(MitigatingFactor."Factor Type"));
                Item.Add('description', MitigatingFactor.Description);
                Item.Add('corrective_action', MitigatingFactor."Corrective Action");
                Factors.Add(Item);
            until MitigatingFactor.Next() = 0;
        Context.Add('mitigating_factors', Factors);

        Context.WriteTo(ContextText);
        exit(ContextText);
    end;

    local procedure GoalSuggestionSystemPrompt(): Text
    begin
        exit(
            'You help staff of a public-sector organisation draft individual performance targets for their annual ' +
            'performance contract. Targets must cascade from the approved corporate workplan objectives you are given, ' +
            'fit the employee''s job title, grade and unit, and be SMART: specific, measurable, achievable, relevant and time-bound ' +
            'within the appraisal period. ' +
            'Rules: link every target to one of the given workplan_line_no values, preferring objectives whose responsible ' +
            'directorate or department matches the employee; do not repeat existing_targets; suggest at most max_targets targets; ' +
            'make the weightage_percent of your targets add up to remaining_weightage_percent; give target_value as a number ' +
            'in the unit named by measurement_criteria; keep every text field under 240 characters; write rationale as one short ' +
            'sentence explaining the link to the objective. Write in clear British English.');
    end;

    local procedure ReviewFeedbackSystemPrompt(): Text
    begin
        exit(
            'You help a supervisor draft appraisal feedback for an employee''s performance review. Base every statement on the ' +
            'targets, achievements, ratings, comments and mitigating factors provided; do not invent facts, and do not mention ' +
            'scores that are not in the data. Be fair, specific and constructive, and use a professional tone suitable for an ' +
            'official appraisal record. Where supervisor_rating is 0 the supervisor has not rated yet, so rely on achievement_percent ' +
            'against the rating_scale. ' +
            'For each review line give a supervisor_comment of one or two sentences and a training_need that names a concrete ' +
            'course or development activity, or an empty string when performance on that line needs no development. ' +
            'Keep every per-line field under 240 characters and overall_summary, strengths and development_areas under 600 ' +
            'characters each. Use the line_no values exactly as given. Write in clear British English.');
    end;

    local procedure GoalSuggestionSchema() Schema: JsonObject
    begin
        Schema.ReadFrom(
            '{"type":"object","additionalProperties":false,"required":["targets"],"properties":{"targets":{"type":"array","items":' +
            '{"type":"object","additionalProperties":false,' +
            '"required":["workplan_line_no","key_result_area","target_description","measurement_criteria","target_value","weightage_percent","rationale"],' +
            '"properties":{"workplan_line_no":{"type":"integer"},"key_result_area":{"type":"string"},"target_description":{"type":"string"},' +
            '"measurement_criteria":{"type":"string"},"target_value":{"type":"number"},"weightage_percent":{"type":"number"},' +
            '"rationale":{"type":"string"}}}}}}');
    end;

    local procedure ReviewFeedbackSchema() Schema: JsonObject
    begin
        Schema.ReadFrom(
            '{"type":"object","additionalProperties":false,"required":["overall_summary","strengths","development_areas","lines"],' +
            '"properties":{"overall_summary":{"type":"string"},"strengths":{"type":"string"},"development_areas":{"type":"string"},' +
            '"lines":{"type":"array","items":{"type":"object","additionalProperties":false,' +
            '"required":["line_no","supervisor_comment","training_need"],' +
            '"properties":{"line_no":{"type":"integer"},"supervisor_comment":{"type":"string"},"training_need":{"type":"string"}}}}}}');
    end;

    /// <summary>
    /// Sends one request whose answer is constrained to the JSON schema and returns the parsed object.
    /// </summary>
    procedure GenerateJson(SystemPrompt: Text; UserPrompt: Text; Schema: JsonObject) Result: JsonObject
    var
        OutputFormat: JsonObject;
        ResultText: Text;
    begin
        OutputFormat.Add('type', 'json_schema');
        OutputFormat.Add('schema', Schema);
        ResultText := SendMessage(SystemPrompt, UserPrompt, OutputFormat, DefaultMaxTokens());
        if not Result.ReadFrom(ResultText) then
            Error(InvalidJsonErr);
    end;

    procedure GenerateText(SystemPrompt: Text; UserPrompt: Text; MaxTokens: Integer): Text
    var
        NoFormat: JsonObject;
    begin
        exit(SendMessage(SystemPrompt, UserPrompt, NoFormat, MaxTokens));
    end;

    [NonDebuggable]
    local procedure SendMessage(SystemPrompt: Text; UserPrompt: Text; OutputFormat: JsonObject; MaxTokens: Integer): Text
    var
        PerfSetup: Record "Perf Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Window: Dialog;
        Body: JsonObject;
        BodyText: Text;
        ResponseText: Text;
    begin
        PerfSetup.Get();
        CheckAIReady(PerfSetup);

        Body := BuildRequestBody(PerfSetup, SystemPrompt, UserPrompt, OutputFormat, MaxTokens);
        Body.WriteTo(BodyText);
        Content.WriteFrom(BodyText);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.Method := 'POST';
        Request.SetRequestUri(GetEndpoint(PerfSetup));
        Request.Content := Content;
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('x-api-key', PerfSetup.GetAIApiKey());
        RequestHeaders.Add('anthropic-version', ApiVersionTok);
        if PerfSetup."AI Use Refusal Fallback" then
            RequestHeaders.Add('anthropic-beta', FallbackBetaTok);

        Client.Timeout(RequestTimeoutMs());
        if GuiAllowed() then
            Window.Open(WorkingMsg);
        if not Client.Send(Request, Response) then begin
            if GuiAllowed() then
                Window.Close();
            Error(ConnectionErr, GetLastErrorText());
        end;
        if GuiAllowed() then
            Window.Close();

        Response.Content.ReadAs(ResponseText);
        if not Response.IsSuccessStatusCode() then
            Error(ApiErr, Response.HttpStatusCode(), GetApiErrorMessage(ResponseText));
        exit(GetResponseText(ResponseText));
    end;

    local procedure BuildRequestBody(PerfSetup: Record "Perf Setup"; SystemPrompt: Text; UserPrompt: Text; OutputFormat: JsonObject; MaxTokens: Integer) Body: JsonObject
    var
        OutputConfig: JsonObject;
        Messages: JsonArray;
        UserMessage: JsonObject;
    begin
        Body.Add('model', GetModel());
        Body.Add('max_tokens', MaxTokens);
        Body.Add('system', SystemPrompt);
        // Thinking stays adaptive (the model default); effort keeps cost and latency proportionate.
        OutputConfig.Add('effort', 'medium');
        if OutputFormat.Keys().Count() > 0 then
            OutputConfig.Add('format', OutputFormat);
        Body.Add('output_config', OutputConfig);
        if PerfSetup."AI Use Refusal Fallback" then
            Body.Add('fallbacks', 'default');
        UserMessage.Add('role', 'user');
        UserMessage.Add('content', UserPrompt);
        Messages.Add(UserMessage);
        Body.Add('messages', Messages);
    end;

    local procedure GetResponseText(ResponseText: Text) Result: Text
    var
        ResponseObject: JsonObject;
        ContentBlocks: JsonArray;
        BlockToken: JsonToken;
        Block: JsonObject;
    begin
        if not ResponseObject.ReadFrom(ResponseText) then
            Error(InvalidJsonErr);
        // Check why the model stopped before trusting the content.
        case GetText(ResponseObject, 'stop_reason') of
            'refusal':
                Error(RefusalErr);
            'max_tokens':
                Error(TruncatedErr);
        end;
        ContentBlocks := GetArray(ResponseObject, 'content');
        foreach BlockToken in ContentBlocks do begin
            Block := BlockToken.AsObject();
            if GetText(Block, 'type') = 'text' then
                Result += GetText(Block, 'text');
        end;
        if Result = '' then
            Error(EmptyResponseErr);
    end;

    local procedure GetApiErrorMessage(ResponseText: Text): Text
    var
        ResponseObject: JsonObject;
        ErrorToken: JsonToken;
    begin
        if ResponseObject.ReadFrom(ResponseText) then
            if ResponseObject.Get('error', ErrorToken) then
                if ErrorToken.IsObject() then
                    exit(GetText(ErrorToken.AsObject(), 'message'));
        exit(CopyStr(ResponseText, 1, 1000));
    end;

    local procedure CheckAIReady(PerfSetup: Record "Perf Setup")
    begin
        if not PerfSetup."AI Enabled" then
            Error(AIDisabledErr);
        if not PerfSetup.HasAIApiKey() then
            Error(AIApiKeyMissingErr);
    end;

    procedure IsAIEnabled(): Boolean
    var
        PerfSetup: Record "Perf Setup";
    begin
        if not PerfSetup.Get() then
            exit(false);
        exit(PerfSetup."AI Enabled");
    end;

    // Fields added to an existing setup record start blank, so fall back to the defaults.
    local procedure GetEndpoint(PerfSetup: Record "Perf Setup"): Text
    begin
        if PerfSetup."AI Endpoint URL" <> '' then
            exit(PerfSetup."AI Endpoint URL");
        exit(DefaultEndpointTok);
    end;

    local procedure GetModel(): Text
    var
        PerfSetup: Record "Perf Setup";
    begin
        if PerfSetup.Get() then
            if PerfSetup."AI Model" <> '' then
                exit(PerfSetup."AI Model");
        exit(DefaultModelTok);
    end;

    local procedure DefaultMaxTokens(): Integer
    begin
        exit(16000);
    end;

    local procedure RequestTimeoutMs(): Integer
    begin
        exit(300000);
    end;

    local procedure GetArray(Source: JsonObject; KeyName: Text): JsonArray
    var
        Token: JsonToken;
        EmptyArray: JsonArray;
    begin
        if Source.Get(KeyName, Token) then
            if Token.IsArray() then
                exit(Token.AsArray());
        exit(EmptyArray);
    end;

    local procedure GetText(Source: JsonObject; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        if Source.Get(KeyName, Token) then
            if Token.IsValue() then
                if not Token.AsValue().IsNull() then
                    exit(Token.AsValue().AsText());
        exit('');
    end;

    local procedure GetDecimal(Source: JsonObject; KeyName: Text): Decimal
    var
        Token: JsonToken;
    begin
        if Source.Get(KeyName, Token) then
            if Token.IsValue() then
                if not Token.AsValue().IsNull() then
                    exit(Token.AsValue().AsDecimal());
        exit(0);
    end;

    local procedure GetInteger(Source: JsonObject; KeyName: Text): Integer
    var
        Token: JsonToken;
    begin
        if Source.Get(KeyName, Token) then
            if Token.IsValue() then
                if not Token.AsValue().IsNull() then
                    exit(Token.AsValue().AsInteger());
        exit(0);
    end;

    var
        ApiVersionTok: Label '2026-10-21', Locked = true;
        FallbackBetaTok: Label 'server-side-fallback-2026-07-01', Locked = true;
        DefaultEndpointTok: Label 'https://api.anthropic.com/v1/messages', Locked = true;
        DefaultModelTok: Label 'claude-opus-5-5', Locked = true;
        FeedbackDraftTxt: Label 'Summary: %1%4%4Strengths: %2%4%4Development areas: %3', Comment = '%1 = summary, %2 = strengths, %3 = development areas, %4 = line break';
        WorkingMsg: Label 'Asking the AI assistant. This can take up to a minute...';
        TargetsInsertedMsg: Label '%1 AI-suggested target(s) were added. Total weightage is now %2%. Review the wording, values and weightage before you submit.', Comment = '%1 = count, %2 = total weightage';
        FeedbackDraftedMsg: Label 'The AI draft feedback has been added, and comments or training needs were filled on %1 line(s) that were blank. Review and edit them before you submit the supervisor review.', Comment = '%1 = count';
        ConnectionOkMsg: Label 'Connected to %1. Reply: %2', Comment = '%1 = model, %2 = reply';
        NoSuggestionsErr: Label 'The AI assistant did not return any target suggestions.';
        NoReviewLinesErr: Label 'Review %1 has no lines. Choose Get Approved Targets first.', Comment = '%1 = review no.';
        NoCascadedObjectivesErr: Label 'Workplan %1 has no objectives cascaded to %2 level to base targets on.', Comment = '%1 = workplan no., %2 = level';
        AIDisabledErr: Label 'The AI assistant is not enabled. Turn on Enable AI Assistant on the Performance Appraisal Setup page.';
        AIApiKeyMissingErr: Label 'No AI API key has been entered on the Performance Appraisal Setup page.';
        ConnectionErr: Label 'Could not reach the AI service: %1\Check the endpoint URL, the server''s internet access, and that Allow HttpClient Requests is turned on for this extension.', Comment = '%1 = error text';
        ApiErr: Label 'The AI service returned error %1: %2', Comment = '%1 = HTTP status code, %2 = message';
        RefusalErr: Label 'The AI service declined this request. Complete the fields manually.';
        TruncatedErr: Label 'The AI response was cut off before it finished. Try again with fewer lines.';
        EmptyResponseErr: Label 'The AI service returned an empty response.';
        InvalidJsonErr: Label 'The AI service returned a response that could not be read.';
}
