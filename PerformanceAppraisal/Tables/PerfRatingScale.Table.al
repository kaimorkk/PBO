table 52193483 "Perf Rating Scale"
{
    // FRD 3 NB: "The review results are calculations for the KPIs against predefined rules".
    // Each row is one rating level. "Min Achievement %" converts a KPI achievement into a
    // suggested rating; Description is the rating category shown on the review.
    // Leave empty to fall back to the built-in 5-point bands in "Perf Score Calculation".
    Caption = 'Performance Rating Scale';
    DataClassification = CustomerContent;
    LookupPageId = "Perf Rating Scale";
    DrillDownPageId = "Perf Rating Scale";

    fields
    {
        field(1; Rating; Integer)
        {
            Caption = 'Rating';
            MinValue = 1;
            MaxValue = 5;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Rating Category';
        }
        field(3; "Min Achievement %"; Decimal)
        {
            Caption = 'Min. KPI Achievement %';
            DecimalPlaces = 0 : 2;
        }
    }

    keys
    {
        key(PK; Rating)
        {
            Clustered = true;
        }
        key(Key2; "Min Achievement %") { }
    }
}
