page 52193471 "Perf Review Header Card"
{
    Caption = 'Performance Review';
    PageType = Document;
    SourceTable = "Perf Review Header";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; Editable = IsOpen; }
                field("Goal No."; Rec."Goal No.") { ApplicationArea = All; Editable = IsOpen; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Supervisor No."; Rec."Supervisor No.") { ApplicationArea = All; Editable = IsOpen; }
                field("Next Level Supervisor No."; Rec."Next Level Supervisor No.") { ApplicationArea = All; Editable = IsOpen; }
                field("Period Code"; Rec."Period Code") { ApplicationArea = All; Editable = IsOpen; }
                field("Period Type"; Rec."Period Type") { ApplicationArea = All; Editable = false; }
                field("Review Start Date"; Rec."Review Start Date") { ApplicationArea = All; Editable = false; }
                field("Review End Date"; Rec."Review End Date") { ApplicationArea = All; Editable = false; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
            group(Scores)
            {
                Caption = 'Results';
                field("Self Assessment Score"; Rec."Self Assessment Score") { ApplicationArea = All; }
                field("Overall Score"; Rec."Overall Score") { ApplicationArea = All; }
                field("Rating Category"; Rec."Rating Category") { ApplicationArea = All; }
                field("Self Assessment Date"; Rec."Self Assessment Date") { ApplicationArea = All; }
                field("Supervisor Review Date"; Rec."Supervisor Review Date") { ApplicationArea = All; }
                field("Next Level Approval Date"; Rec."Next Level Approval Date") { ApplicationArea = All; }
            }
            part(Lines; "Perf Review Line Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Review No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Feedback)
            {
                Caption = 'Supervisor Feedback / Objection';
                field("Supervisor Return Comments"; Rec."Supervisor Return Comments")
                {
                    ApplicationArea = All;
                    Editable = IsAwaitingSupervisor;
                    MultiLine = true;
                    ToolTip = 'The supervisor enters what must be amended before choosing Return to Employee.';
                }
                field("AI Feedback Draft"; Rec."AI Feedback Draft")
                {
                    ApplicationArea = All;
                    Visible = AIEnabled;
                    Editable = IsAwaitingSupervisor;
                    MultiLine = true;
                    ToolTip = 'Appraisal narrative drafted by the AI assistant. AI-generated content may be incorrect; edit it so it reflects your own assessment.';
                }
                field("Employee Objection"; Rec."Employee Objection") { ApplicationArea = All; }
                field("Objection Comments"; Rec."Objection Comments")
                {
                    ApplicationArea = All;
                    Editable = IsAwaitingNextLevel;
                    MultiLine = true;
                    ToolTip = 'If the employee disagrees with the supervisor''s results, enter the objection here and choose Raise Objection.';
                }
                field("Escalation Resolution"; Rec."Escalation Resolution")
                {
                    ApplicationArea = All;
                    Editable = IsEscalated;
                    MultiLine = true;
                }
            }
            group(Consolidation)
            {
                Caption = 'HR Consolidation / Committee';
                field("HR Consolidation Date"; Rec."HR Consolidation Date") { ApplicationArea = All; }
                field("Submitted to GM HR&A"; Rec."Submitted to GM HR&A") { ApplicationArea = All; }
                field("Submitted to GM HR&A Date"; Rec."Submitted to GM HR&A Date") { ApplicationArea = All; }
                field("Submitted to HRAC Date"; Rec."Submitted to HRAC Date") { ApplicationArea = All; }
                field("HRAC Recommendation"; Rec."HRAC Recommendation")
                {
                    ApplicationArea = All;
                    Editable = IsWithHRAC;
                    MultiLine = true;
                }
                field("Submitted to ED"; Rec."Submitted to ED") { ApplicationArea = All; }
            }
            part(Rewards; "Perf Reward Sanction List")
            {
                ApplicationArea = All;
                Caption = 'Proposed Rewards / Sanctions';
                SubPageLink = "Review No." = field("No.");
                Editable = HasScore;
            }
            part(Mitigating; "Perf Mitigating Factor List")
            {
                ApplicationArea = All;
                Caption = 'Mitigating Factors for Non-Performance';
                SubPageLink = "Review No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(EmployeeActions)
            {
                Caption = 'Employee';
                action(GetApprovedTargets)
                {
                    Caption = 'Get Approved Targets';
                    ApplicationArea = All;
                    Image = GetLines;
                    Enabled = IsOpen;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Rec.CreateLinesFromGoal();
                        CurrPage.Update(false);
                    end;
                }
                action(SubmitSelfAssessment)
                {
                    Caption = 'Submit Self-Assessment';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = IsSelfAssessing;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.SubmitSelfAssessment(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(RaiseObjection)
                {
                    Caption = 'Raise Objection';
                    ApplicationArea = All;
                    Image = Warning;
                    Enabled = IsAwaitingNextLevel;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.RaiseObjection(Rec, Rec."Objection Comments");
                        CurrPage.Update(false);
                    end;
                }
            }
            group(SupervisorActions)
            {
                Caption = 'Supervisor';
                action(DraftFeedbackWithAI)
                {
                    Caption = 'Draft Feedback with AI';
                    ApplicationArea = All;
                    Image = SparkleFilled;
                    Enabled = IsAwaitingSupervisor and AIEnabled;
                    Visible = AIEnabled;
                    ToolTip = 'Drafts an appraisal summary, and fills blank supervisor comments and training needs, from the achievements and ratings. Existing comments are not changed.';

                    trigger OnAction()
                    var
                        PerfAIMgt: Codeunit "Perf AI Mgt";
                    begin
                        CurrPage.SaveRecord();
                        PerfAIMgt.DraftReviewFeedback(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(ReturnToEmployee)
                {
                    Caption = 'Return to Employee with Comments';
                    ApplicationArea = All;
                    Image = Reject;
                    Enabled = IsAwaitingSupervisor;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.ReturnToEmployee(Rec, Rec."Supervisor Return Comments");
                        CurrPage.Update(false);
                    end;
                }
                action(SubmitSupervisorReview)
                {
                    Caption = 'Submit Supervisor Review';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = IsAwaitingSupervisor;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.SubmitSupervisorReview(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(GenerateLetter)
                {
                    Caption = 'Generate Commendation/Warning Letter';
                    ApplicationArea = All;
                    Image = PrintCover;
                    Enabled = HasScore;

                    trigger OnAction()
                    var
                        LetterMgt: Codeunit "Perf Letter Generation Mgt";
                    begin
                        LetterMgt.GenerateStandardLetter(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(NextLevelActions)
            {
                Caption = 'Next Level Supervisor / GM HR';
                action(ApproveNextLevel)
                {
                    Caption = 'Approve (Next Level Supervisor)';
                    ApplicationArea = All;
                    Image = Approve;
                    Enabled = IsAwaitingNextLevel;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        ReviewApprovalMgt.ApproveByNextLevelSupervisor(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(UpholdResults)
                {
                    Caption = 'Resolve Objection: Uphold Results';
                    ApplicationArea = All;
                    Image = Approve;
                    Enabled = IsEscalated;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.ResolveObjection(Rec, Rec."Escalation Resolution", true);
                        CurrPage.Update(false);
                    end;
                }
                action(ReturnToHOD)
                {
                    Caption = 'Resolve Objection: Return to HOD for Review';
                    ApplicationArea = All;
                    Image = Undo;
                    Enabled = IsEscalated;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.ResolveObjection(Rec, Rec."Escalation Resolution", false);
                        CurrPage.Update(false);
                    end;
                }
                action(EscalateToGMHR)
                {
                    Caption = 'Escalate to GM HR';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = Rec.Status = Rec.Status::"Escalated to Next Level Supervisor";

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.EscalateToGMHR(Rec, Rec."Escalation Resolution");
                        CurrPage.Update(false);
                    end;
                }
            }
            group(HRActions)
            {
                Caption = 'HR';
                action(ForwardToHRManager)
                {
                    Caption = 'Consolidate (HR Manager)';
                    ApplicationArea = All;
                    Image = Completed;
                    Enabled = Rec.Status = Rec.Status::"Approved by Next Level Supervisor";

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        ReviewApprovalMgt.ForwardToHRManager(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(SubmitToGMHRandA)
                {
                    Caption = 'Submit to GM HR&A';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = (Rec.Status = Rec.Status::"Consolidated by HR") and not Rec."Submitted to GM HR&A";

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        ReviewApprovalMgt.SubmitToGMHRandA(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(SubmitToHRAC)
                {
                    Caption = 'Submit to HR Appraisal Committee (EPMC)';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = (Rec.Status = Rec.Status::"Submitted to GM HR&A") or ((Rec.Status = Rec.Status::"Consolidated by HR") and Rec."Submitted to GM HR&A");

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        ReviewApprovalMgt.SubmitToHRAC(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(SubmitToED)
                {
                    Caption = 'Record HRAC Recommendation && Submit to ED';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = IsWithHRAC;

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        CurrPage.SaveRecord();
                        ReviewApprovalMgt.RecordHRACRecommendationAndSubmitToED(Rec, Rec."HRAC Recommendation");
                        CurrPage.Update(false);
                    end;
                }
                action(CloseReview)
                {
                    Caption = 'Close Review';
                    ApplicationArea = All;
                    Image = Close;
                    Enabled = Rec.Status = Rec.Status::"Recommendation Submitted to ED";

                    trigger OnAction()
                    var
                        ReviewApprovalMgt: Codeunit "Perf Review Approval Mgt";
                    begin
                        ReviewApprovalMgt.CloseReview(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SubmitSelfAssessment_Promoted; SubmitSelfAssessment) { }
                actionref(DraftFeedbackWithAI_Promoted; DraftFeedbackWithAI) { }
                actionref(SubmitSupervisorReview_Promoted; SubmitSupervisorReview) { }
                actionref(ReturnToEmployee_Promoted; ReturnToEmployee) { }
                actionref(ApproveNextLevel_Promoted; ApproveNextLevel) { }
                actionref(RaiseObjection_Promoted; RaiseObjection) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        PerfAIMgt: Codeunit "Perf AI Mgt";
    begin
        AIEnabled := PerfAIMgt.IsAIEnabled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlState();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetControlState();
        IsOpen := true;
    end;

    local procedure SetControlState()
    begin
        IsOpen := Rec.Status = Rec.Status::Open;
        IsSelfAssessing := Rec.Status in [Rec.Status::Open, Rec.Status::"Returned to Employee"];
        IsAwaitingSupervisor := Rec.Status = Rec.Status::"Self-Assessment Submitted";
        IsAwaitingNextLevel := Rec.Status = Rec.Status::"Supervisor Review Submitted";
        IsEscalated := Rec.Status in [Rec.Status::"Escalated to Next Level Supervisor", Rec.Status::"Escalated to GM HR"];
        IsWithHRAC := Rec.Status = Rec.Status::"Submitted to HRAC";
        HasScore := Rec."Supervisor Review Date" <> 0D;
        CurrPage.Lines.Page.SetEditMode(IsSelfAssessing, IsAwaitingSupervisor);
    end;

    var
        IsOpen: Boolean;
        IsSelfAssessing: Boolean;
        IsAwaitingSupervisor: Boolean;
        IsAwaitingNextLevel: Boolean;
        IsEscalated: Boolean;
        IsWithHRAC: Boolean;
        HasScore: Boolean;
        AIEnabled: Boolean;
}
