codeunit 52193434 "Perf Letter Generation Mgt"
{
    // FRD 3.viii: "The system shall generate standard letters and memos, including
    // commendation letters for excellent performance and warning letters for poor
    // performance."
    // FRD 3.ix-x: Supervisors propose rewards/sanctions; HRAC reviews and moderates
    // before recommending to the appropriate authority.

    trigger OnRun()
    begin
    end;

    procedure GenerateStandardLetter(ReviewHeader: Record "Perf Review Header")
    var
        PerfSetup: Record "Perf Setup";
    begin
        PerfSetup.Get();
        // The overall score only exists once the supervisor has evaluated the employee.
        ReviewHeader.TestField("Supervisor Review Date");

        if ReviewHeader."Overall Score" >= PerfSetup."Commendation Letter Threshold" then
            RunLetterReport(ReviewHeader, LetterKind::Commendation)
        else
            if ReviewHeader."Overall Score" <= PerfSetup."Warning Letter Threshold" then
                RunLetterReport(ReviewHeader, LetterKind::Warning)
            else
                Message(NoLetterMsg, ReviewHeader."Overall Score", PerfSetup."Warning Letter Threshold", PerfSetup."Commendation Letter Threshold");
    end;

    local procedure RunLetterReport(ReviewHeader: Record "Perf Review Header"; Kind: Option Commendation,Warning)
    var
        RewardSanction: Record "Perf Reward Sanction";
    begin
        // Reprinting reuses the proposal created the first time instead of duplicating it.
        RewardSanction.SetRange("Review No.", ReviewHeader."No.");
        RewardSanction.SetRange("Auto-Generated", true);
        if Kind = Kind::Commendation then
            RewardSanction.SetRange(Type, RewardSanction.Type::Reward)
        else
            RewardSanction.SetRange(Type, RewardSanction.Type::Sanction);

        if not RewardSanction.FindFirst() then begin
            RewardSanction.Init();
            RewardSanction."Review No." := ReviewHeader."No.";
            RewardSanction."Employee No." := ReviewHeader."Employee No.";
            if Kind = Kind::Commendation then begin
                RewardSanction.Type := RewardSanction.Type::Reward;
                RewardSanction.Description := CommendationTxt;
            end else begin
                RewardSanction.Type := RewardSanction.Type::Sanction;
                RewardSanction.Description := WarningTxt;
            end;
            RewardSanction."Proposed by (Supervisor)" := ReviewHeader."Supervisor No.";
            RewardSanction."Proposed Date" := Today;
            RewardSanction."HRAC Status" := RewardSanction."HRAC Status"::Pending;
            RewardSanction."Auto-Generated" := true;
            RewardSanction.Insert(true);
        end;
        Commit();

        RewardSanction.SetRecFilter();
        Report.RunModal(Report::"Perf Appraisal Letter", true, false, RewardSanction);

        RewardSanction."Letter Generated" := true;
        RewardSanction.Modify(true);
    end;

    procedure ProposeReward(ReviewHeader: Record "Perf Review Header"; ProposedBy: Code[20]; Description: Text[250])
    begin
        InsertProposal(ReviewHeader, ProposedBy, Description, 0);
    end;

    procedure ProposeSanction(ReviewHeader: Record "Perf Review Header"; ProposedBy: Code[20]; Description: Text[250])
    begin
        InsertProposal(ReviewHeader, ProposedBy, Description, 1);
    end;

    local procedure InsertProposal(ReviewHeader: Record "Perf Review Header"; ProposedBy: Code[20]; Description: Text[250]; TypeOption: Option Reward,Sanction)
    var
        RewardSanction: Record "Perf Reward Sanction";
    begin
        RewardSanction.Init();
        RewardSanction."Review No." := ReviewHeader."No.";
        RewardSanction."Employee No." := ReviewHeader."Employee No.";
        RewardSanction.Type := TypeOption;
        RewardSanction.Description := Description;
        RewardSanction."Proposed by (Supervisor)" := ProposedBy;
        RewardSanction."Proposed Date" := Today;
        RewardSanction."HRAC Status" := RewardSanction."HRAC Status"::Pending;
        RewardSanction.Insert(true);
    end;

    /// <summary>
    /// FRD 3.x: Rewards and sanctions shall be reviewed/moderated by the HRAC and
    /// recommended to the appropriate authority.
    /// </summary>
    procedure ModerateByHRAC(var RewardSanction: Record "Perf Reward Sanction"; NewStatus: Enum "Perf HRAC Status"; Comments: Text[250]; RecommendTo: Text[100])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        EmployeeMgt.CheckCurrentUserIsHROfficial();
        if NewStatus = NewStatus::Pending then
            Error(SelectDecisionErr);
        if (NewStatus <> NewStatus::Rejected) and (RecommendTo = '') then
            Error(RecommendToRequiredErr);
        RewardSanction."HRAC Status" := NewStatus;
        RewardSanction."HRAC Comments" := Comments;
        RewardSanction."Recommended To" := RecommendTo;
        RewardSanction.Modify(true);
    end;

    /// <summary>
    /// Records the decision of the appropriate authority on an HRAC recommendation.
    /// </summary>
    procedure RecordFinalDecision(var RewardSanction: Record "Perf Reward Sanction"; Decision: Text[250])
    var
        EmployeeMgt: Codeunit "Perf Employee Mgt";
    begin
        EmployeeMgt.CheckCurrentUserIsHROfficial();
        if RewardSanction."HRAC Status" in [RewardSanction."HRAC Status"::Pending, RewardSanction."HRAC Status"::Rejected] then
            RewardSanction.FieldError("HRAC Status");
        if Decision = '' then
            Error(DecisionRequiredErr);
        RewardSanction."Final Decision" := Decision;
        RewardSanction."Final Decision By" := CopyStr(UserId(), 1, MaxStrLen(RewardSanction."Final Decision By"));
        RewardSanction."Decision Date" := Today;
        RewardSanction.Modify(true);
    end;

    var
        LetterKind: Option Commendation,Warning;
        CommendationTxt: Label 'Commendation for excellent performance.';
        WarningTxt: Label 'Warning for below-expectation performance.';
        NoLetterMsg: Label 'No standard letter applies. The overall score %1 is between the warning threshold (%2) and the commendation threshold (%3).', Comment = '%1 = score, %2 = warning threshold, %3 = commendation threshold';
        SelectDecisionErr: Label 'Set the HR Appraisal Committee Status to Approved, Moderated or Rejected first.';
        RecommendToRequiredErr: Label 'Enter the authority the HR Appraisal Committee recommends this to.';
        DecisionRequiredErr: Label 'Enter the final decision of the appropriate authority.';
}
