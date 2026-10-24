report 52193435 "Perf Appraisal Letter"
{
    // FRD 3.viii: standard commendation letter (excellent performance) and warning letter
    // (poor performance), one per Reward/Sanction proposal raised from a review.
    // The RDLC layout is generated on first build; design the letterhead in Report Builder.
    Caption = 'Performance Appraisal Letter';
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './PBO/PerformanceAppraisal/Layouts/PerfAppraisalLetter.rdlc';

    dataset
    {
        dataitem(RewardSanction; "Perf Reward Sanction")
        {
            RequestFilterFields = "Entry No.", "Review No.";

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddress; CompanyInfo.Address) { }
            column(CompanyCity; CompanyInfo.City) { }
            column(LetterDate; Format(Today, 0, 4)) { }
            column(LetterTitle; LetterTitle) { }
            column(LetterBody; LetterBody) { }
            column(EmployeeNo; "Employee No.") { }
            column(EmployeeName; EmployeeName) { }
            column(JobTitle; JobTitle) { }
            column(ReviewNo; "Review No.") { }
            column(PeriodCode; ReviewHeader."Period Code") { }
            column(OverallScore; ReviewHeader."Overall Score") { }
            column(RatingCategory; ReviewHeader."Rating Category") { }
            column(ProposalDescription; Description) { }
            column(SignatoryTitle; SignatoryTitleTxt) { }

            trigger OnAfterGetRecord()
            var
                Employee: Record Employee;
            begin
                Clear(ReviewHeader);
                if ReviewHeader.Get("Review No.") then;
                EmployeeName := '';
                JobTitle := '';
                if Employee.Get("Employee No.") then begin
                    EmployeeName := Employee.FullName();
                    JobTitle := Employee."Job Title";
                end;

                if Type = Type::Reward then begin
                    LetterTitle := CommendationTitleTxt;
                    LetterBody := StrSubstNo(CommendationBodyTxt, ReviewHeader."Period Code", ReviewHeader."Overall Score", ReviewHeader."Rating Category");
                end else begin
                    LetterTitle := WarningTitleTxt;
                    LetterBody := StrSubstNo(WarningBodyTxt, ReviewHeader."Period Code", ReviewHeader."Overall Score", ReviewHeader."Rating Category");
                end;
            end;
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        ReviewHeader: Record "Perf Review Header";
        EmployeeName: Text;
        JobTitle: Text;
        LetterTitle: Text;
        LetterBody: Text;
        CommendationTitleTxt: Label 'LETTER OF COMMENDATION';
        WarningTitleTxt: Label 'LETTER OF WARNING';
        CommendationBodyTxt: Label 'Following your performance appraisal for the period %1, you attained an overall score of %2 (%3). Management commends you for your excellent performance and dedication, and encourages you to maintain this high standard.', Comment = '%1 = period, %2 = score, %3 = rating category';
        WarningBodyTxt: Label 'Following your performance appraisal for the period %1, you attained an overall score of %2 (%3), which is below the expected standard. You are hereby warned and required to improve your performance. Your supervisor will agree with you on corrective actions, including any mentorship or training support.', Comment = '%1 = period, %2 = score, %3 = rating category';
        SignatoryTitleTxt: Label 'General Manager, Human Resources & Administration';
}
