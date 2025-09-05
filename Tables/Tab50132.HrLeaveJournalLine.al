table 50132 "HR Leave Journal Line"
{
    Caption = 'HR Journal Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            TableRelation = "HR Leave Journal Template".Name;
            Caption = 'Journal Template Name';
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "HR Leave Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
        field(4; "Leave Period"; Code[20])
        {
            Caption = 'Leave Period';
            // TableRelation = "HR Leave Periods";
            trigger OnValidate()
            var
                myInt: Integer;
                LeaveP: Record "HR Leave Periods";
            begin


            end;

        }
        field(6; "Staff No."; Code[20])
        {
            Caption = 'Staff No.';
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if "Staff No." = '' then begin
                    "Staff Name" := '';
                    exit;
                end;
                FA.Get("Staff No.");
                "Staff Name" := FA.FullName();
            end;
        }
        field(7; "Staff Name"; Text[120])
        {
            Caption = 'Staff Name';
            Editable = false;
        }
        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(9; "Leave Entry Type"; Option)
        {
            Caption = 'Leave Entry Type';
            Editable = true;
            OptionCaption = 'Positive,Negative,Reimbursement';
            OptionMembers = Positive,Negative,Reimbursement;
        }
        field(10; "Leave Approval Date"; Date)
        {
            Caption = 'Leave Approval Date';
            Editable = false;
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(12; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
        }
        field(13; "No. of Days"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'No. of Days';
            Editable = true;

            trigger OnValidate()
            begin
                if LeaveType.Get("Leave Type") then
                    if (LeaveType."Fixed Days" = true) then
                        if "No. of Days" > LeaveType.Days then
                            Error(Text001, "Leave Type");
            end;
        }
        field(14; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(20; "Index Entry"; Boolean)
        {
            Caption = 'Index Entry';
        }
        field(21; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(22; "Leave Type"; Code[20])
        {
            Editable = true;
            TableRelation = "HR Leave Types".Code;
            Caption = 'Leave Type';

        }
        field(23; "Leave Recalled No."; Code[20])
        {
            Caption = 'Leave Application No.';

        }
        field(26; "Leave Period Start Date"; Date)
        {
            TableRelation = "HR Leave Periods"."Starting Date";
            Caption = 'Leave Period Start Date';

        }
        field(27; "Leave Period End Date"; Date)
        {
            Caption = 'Leave Period End Date';
        }
        field(28; "Positive Transaction Type"; Option)
        {
            OptionCaption = ' ,Leave Allocation,Leave Recall,OverTime';
            OptionMembers = " ","Leave Allocation","Leave Recall",OverTime;
            Caption = 'Positive Transaction Type';
        }
        field(29; "Negative Transaction Type"; Option)
        {
            OptionCaption = ' ,Leave Taken,Leave Forfeited ';
            OptionMembers = " ","Leave Taken","Leave Forfeited ";
            Caption = 'Negative Transaction Type';
        }
        field(30; "Leave Application No."; Code[20])
        {
            Caption = 'Leave Application No.';
            TableRelation = "HR Leave Application"."Application Code";

            trigger OnValidate()
            begin
                if "Leave Application No." = '' then begin
                    CreateDim(Database::Insurance, "Leave Application No.");
                    exit;
                end;
                Insurance.Reset();
                Insurance.SetRange(Insurance."Application Code", "Leave Application No.");
                if Insurance.Find('-') then begin
                    //Insurance.GET("Leave Application No.");
                    //Insurance.TESTFIELD(Blocked,FALSE);
                    Description := Insurance."Applicant Comments";
                    "Leave Approval Date" := Insurance."Start Date";
                    "No. of Days" := Insurance."Approved days";
                    "Leave Type" := Insurance."Leave Type";
                end;
                CreateDim(Database::Insurance, "Leave Application No.");
            end;
        }
        field(31; Batched; Boolean)
        {
            Caption = 'Batched';
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Posting Date")
        {
            MaintainSqlIndex = false;
        }
    }

    fieldgroups { }


    trigger OnInsert()
    begin

        HRLeavePeriods.Reset();
        if HRLeavePeriods.Find('-') then begin
            "Leave Period Start Date" := HRLeavePeriods."Starting Date";
            Validate("Leave Period Start Date");
            if HRLeavePeriods.Find('+') then begin
                "Leave Period End Date" := HRLeavePeriods."Starting Date";
                Validate("Leave Period End Date");
            end else
                Error('No leave periods have been defined');
        end else
            Error('No leave periods have been defined');
    end;

    var
        Insurance: Record "HR Leave Application";
        FA: Record Employee;
        InsuranceJnlTempl: Record "HR Leave Journal Template";
        InsuranceJnlBatch: Record "HR Leave Journal Batch";
        InsuranceJnlLine: Record "HR Leave Journal Line";
        //NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        LeaveType: Record "HR Leave Types";
        Text001: Label 'You can not post more than maximum days allowed for this leave type %1';
        LeavePeriod: Record "HR Leave Types";
        HRLeaveTypes: Record "HR Leave Periods";
        HR: Record "HR Setup";
        HRLeavePeriods: Record "HR Leave Periods";


    procedure SetUpNewLine(LastInsuranceJnlLine: Record "HR Leave Journal Line")
    begin
        /*InsuranceJnlTempl.GET("Journal Template Name");
        InsuranceJnlBatch.GET("Journal Template Name","Journal Batch Name");
        InsuranceJnlLine.SETRANGE("Journal Template Name","Journal Template Name");
        InsuranceJnlLine.SETRANGE("Journal Batch Name","Journal Batch Name");
        IF InsuranceJnlLine.FIND('-') THEN BEGIN
          "Posting Date" := LastInsuranceJnlLine."Posting Date";
          "Document No." := LastInsuranceJnlLine."Document No.";
        END ELSE BEGIN
          "Posting Date" := WORKDATE;
          IF InsuranceJnlBatch."No. Series" <> '' THEN BEGIN
            CLEAR(NoSeriesMgt);
            "Document No." := NoSeriesMgt.TryGetNextNo(InsuranceJnlBatch."No. Series","Posting Date");
          END;
        END;
        "Source Code" := InsuranceJnlTempl."Source Code";
        "Reason Code" := InsuranceJnlBatch."Reason Code";
        "Posting No. Series" := InsuranceJnlBatch."Posting No. Series";
        */

    end;


    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        /*TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        DimMgt.GetDefaultDim(
          TableID,No,"Source Code",
          "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        IF "Line No." <> 0 THEN
          DimMgt.UpdateJnlLineDefaultDim(
            DATABASE::Table5635,
            "Journal Template Name","Journal Batch Name","Line No.",0,
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
          */

    end;


    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        /*DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        IF "Line No." <> 0 THEN BEGIN
          DimMgt.SaveJnlLineDim(
            DATABASE::Table5635,"Journal Template Name",
            "Journal Batch Name","Line No.",0,FieldNumber,ShortcutDimCode);
          IF MODIFY THEN;
        END ELSE
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
         */

    end;


    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        /*DimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
        IF "Line No." <> 0 THEN BEGIN
          DimMgt.SaveJnlLineDim(
            DATABASE::Table5635,"Journal Template Name",
            "Journal Batch Name","Line No.",0,FieldNumber,ShortcutDimCode);
          MODIFY;
        END ELSE
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
        */

    end;


    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        /*IF "Line No." <> 0 THEN
          DimMgt.ShowJnlLineDim(
            DATABASE::Table5635,"Journal Template Name",
            "Journal Batch Name","Line No.",0,ShortcutDimCode)
        ELSE
          DimMgt.ShowTempDim(ShortcutDimCode);
        */

    end;


    procedure ValidateOpenPeriod(LeavePeriod: Record "HR Leave Periods")
    var
        Rec1: Record "HR Leave Periods";
    begin
        /*WITH LeavePeriod DO
        BEGIN
         Rec1.RESET;
        IF Rec1.FIND('-')THEN BEGIN
        "Leave Period Start Date":=Rec1."Starting Date";
        VALIDATE("Leave Period Start Date");    `
        END;
        END;*/

    end;
}
