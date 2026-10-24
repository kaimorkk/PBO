codeunit 52193437 "Perf Score Calculation"
{
    // FRD 3: "The review results are calculations for the KPIs against predefined rules
    // to arrive at the performance measurement." Weighting between self and supervisor
    // assessment is configurable in Perf Setup (Figure 2: "The formula to calculate
    // aggregate score to be confirmed"); rating bands come from "Perf Rating Scale".

    trigger OnRun()
    begin
    end;

    procedure CalculateSelfScores(var ReviewHeader: Record "Perf Review Header")
    var
        ReviewLine: Record "Perf Review Line";
        PerfSetup: Record "Perf Setup";
        SelfTotal: Decimal;
    begin
        GetSetup(PerfSetup);
        ReviewLine.SetRange("Review No.", ReviewHeader."No.");
        if ReviewLine.IsEmpty() then
            Error(NoLinesErr, ReviewHeader."No.");
        ReviewLine.SetRange("Self Rating", 0);
        if ReviewLine.FindFirst() then
            Error(SelfRatingMissingErr, ReviewLine."Key Result Area");

        ReviewLine.SetRange("Self Rating");
        if ReviewLine.FindSet() then
            repeat
                SelfTotal += ReviewLine."Self Rating" * ReviewLine."Weightage %" / 100;
            until ReviewLine.Next() = 0;

        ReviewHeader."Self Assessment Score" := Round(SelfTotal, PerfSetup."Score Rounding Precision");
        ReviewHeader.Modify(true);
    end;

    procedure CalculateFinalScores(var ReviewHeader: Record "Perf Review Header")
    var
        ReviewLine: Record "Perf Review Line";
        PerfSetup: Record "Perf Setup";
        WeightedTotal: Decimal;
        SelfWeight: Decimal;
        SupWeight: Decimal;
    begin
        GetSetup(PerfSetup);
        if PerfSetup."Self Assessment Weight %" + PerfSetup."Supervisor Assessment Weight %" <> 100 then
            Error(WeightSetupErr);
        SelfWeight := PerfSetup."Self Assessment Weight %" / 100;
        SupWeight := PerfSetup."Supervisor Assessment Weight %" / 100;

        ReviewLine.SetRange("Review No.", ReviewHeader."No.");
        ReviewLine.SetRange("Supervisor Rating", 0);
        if ReviewLine.FindFirst() then
            Error(SupervisorRatingMissingErr, ReviewLine."Key Result Area");

        ReviewLine.SetRange("Supervisor Rating");
        if ReviewLine.FindSet(true) then
            repeat
                ReviewLine."Final Score" :=
                    Round(
                        ((ReviewLine."Self Rating" * SelfWeight) + (ReviewLine."Supervisor Rating" * SupWeight))
                        * (ReviewLine."Weightage %" / 100),
                        PerfSetup."Score Rounding Precision");
                ReviewLine.Modify(true);

                WeightedTotal += ReviewLine."Final Score";
            until ReviewLine.Next() = 0;

        ReviewHeader."Overall Score" := Round(WeightedTotal, PerfSetup."Score Rounding Precision");
        ReviewHeader."Rating Category" := GetRatingCategory(ReviewHeader."Overall Score");
        ReviewHeader.Modify(true);
    end;

    /// <summary>
    /// Converts a KPI achievement % into a rating using "Perf Rating Scale". Returns 0 when
    /// no scale has been set up, so the employee rates manually.
    /// </summary>
    procedure GetRatingForAchievement(AchievementPct: Decimal): Decimal
    var
        RatingScale: Record "Perf Rating Scale";
    begin
        RatingScale.SetCurrentKey("Min Achievement %");
        RatingScale.SetFilter("Min Achievement %", '<=%1', AchievementPct);
        if RatingScale.FindLast() then
            exit(RatingScale.Rating);
        exit(0);
    end;

    procedure GetRatingCategory(Score: Decimal): Text[50]
    var
        RatingScale: Record "Perf Rating Scale";
    begin
        if not RatingScale.IsEmpty() then begin
            RatingScale.SetFilter(Rating, '..%1', Round(Score, 1));
            if RatingScale.FindLast() then
                exit(RatingScale.Description);
            RatingScale.Reset();
            RatingScale.FindFirst();
            exit(RatingScale.Description);
        end;

        // Default rating bands out of 5, aligned to Perf Review Line rating scale (1-5).
        case true of
            Score >= 4.5:
                exit('Outstanding');
            Score >= 3.5:
                exit('Exceeds Expectations');
            Score >= 2.5:
                exit('Meets Expectations');
            Score >= 1.5:
                exit('Below Expectations');
            else
                exit('Unsatisfactory');
        end;
    end;

    local procedure GetSetup(var PerfSetup: Record "Perf Setup")
    begin
        if not PerfSetup.Get() then begin
            PerfSetup.Init();
            PerfSetup.Insert(true);
        end;
    end;

    var
        NoLinesErr: Label 'Review %1 has no lines. Use Get Approved Targets first.', Comment = '%1 = review no.';
        SelfRatingMissingErr: Label 'Enter a self rating for Key Result Area "%1".', Comment = '%1 = KRA';
        SupervisorRatingMissingErr: Label 'Enter a supervisor rating for Key Result Area "%1".', Comment = '%1 = KRA';
        WeightSetupErr: Label 'Self-Assessment Weight %% and Supervisor Assessment Weight %% in Performance Appraisal Setup must add up to 100.';
}
