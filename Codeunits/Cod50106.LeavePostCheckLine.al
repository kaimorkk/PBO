 
 
codeunit 50106 "HR Leave Jnl.- Check Line"
{
    TableNo = "HR Leave Journal Line";

    trigger OnRun()
    var
        TempJnlLineDim: Record "Journal Line Dimension" temporary;
    begin
        GLSetup.Get();
        if Rec."Shortcut Dimension 1 Code" <> '' then begin
            TempJnlLineDim."Table ID" := Database::"HR Leave Journal Line";
            TempJnlLineDim."Journal Template Name" := Rec."Journal Template Name";
            TempJnlLineDim."Journal Batch Name" := Rec."Journal Batch Name";
            TempJnlLineDim."Journal Line No." := Rec."Line No.";
            TempJnlLineDim."Dimension Code" := GLSetup."Global Dimension 1 Code";
            TempJnlLineDim."Dimension Value Code" := Rec."Shortcut Dimension 1 Code";
            TempJnlLineDim.Insert();
        end;
        if Rec."Shortcut Dimension 2 Code" <> '' then begin
            TempJnlLineDim."Table ID" := Database::"HR Leave Journal Line";
            TempJnlLineDim."Journal Template Name" := Rec."Journal Template Name";
            TempJnlLineDim."Journal Batch Name" := Rec."Journal Batch Name";
            TempJnlLineDim."Journal Line No." := Rec."Line No.";
            TempJnlLineDim."Dimension Code" := GLSetup."Global Dimension 2 Code";
            TempJnlLineDim."Dimension Value Code" := Rec."Shortcut Dimension 2 Code";
            TempJnlLineDim.Insert();
        end;
        RunCheck(Rec, TempJnlLineDim);
    end;

    var
        Text000: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text001: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        GLSetup: Record "General Ledger Setup";
        FASetup: Record "HR Setup";
        DimMgt: Codeunit DimensionManagement;
        CallNo: Integer;
        Text002: Label 'The Posting Date Must be within the open leave periods';
        Text003: Label 'The Posting Date Must be within the allowed Setup date';
        LeaveEntries: Record "HR Leave Ledger Entries";
        Text004: Label 'The Allocation of Leave days has been done for the period';


    procedure RunCheck(var InsuranceJnlLine: Record "HR Leave Journal Line"; var JnlLineDim: Record "Journal Line Dimension")
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        begin
            if InsuranceJnlLine."Leave Entry Type" = InsuranceJnlLine."Leave Entry Type"::Negative then
                InsuranceJnlLine.TestField(InsuranceJnlLine."Leave Period");

            InsuranceJnlLine.TestField(InsuranceJnlLine."Document No.");
            InsuranceJnlLine.TestField(InsuranceJnlLine."Posting Date");
            InsuranceJnlLine.TestField(InsuranceJnlLine."Staff No.");
            CallNo := 1;

            // if not DimMgt.CheckJnlLineDimComb(JnlLineDim) then
            //   Error(
            //     Text000,
            //     InsuranceJnlLine.TableCaption,InsuranceJnlLine."Journal Template Name",InsuranceJnlLine."Journal Batch Name",InsuranceJnlLine."Line No.",
            //     DimMgt.GetDimCombErr);

            // TableID[1] := Database::Table39005571;
            No[1] := InsuranceJnlLine."Leave Period";
            // if not DimMgt.CheckJnlLineDimValuePosting(JnlLineDim,TableID,No) then
            //   if InsuranceJnlLine."Line No." <> 0 then
            //     Error(
            //       Text001,
            //       InsuranceJnlLine.TableCaption,InsuranceJnlLine."Journal Template Name",InsuranceJnlLine."Journal Batch Name",InsuranceJnlLine."Line No.",
            //       DimMgt.GetDimValuePostingErr)
            //   else
            //     Error(DimMgt.GetDimValuePostingErr);
        end;
        ValidatePostingDate(InsuranceJnlLine);
    end;


    procedure ValidatePostingDate(var InsuranceJnlLine: Record "HR Leave Journal Line")
    begin
        begin
            if InsuranceJnlLine."Leave Entry Type" = InsuranceJnlLine."Leave Entry Type"::Negative then
                InsuranceJnlLine.TestField(InsuranceJnlLine."Leave Period");
            InsuranceJnlLine.TestField(InsuranceJnlLine."Document No.");
            InsuranceJnlLine.TestField(InsuranceJnlLine."Posting Date");
            InsuranceJnlLine.TestField(InsuranceJnlLine."Staff No.");
            if (InsuranceJnlLine."Posting Date" < InsuranceJnlLine."Leave Period Start Date") or
               (InsuranceJnlLine."Posting Date" > InsuranceJnlLine."Leave Period End Date") then
                // ERROR(FORMAT(Text002));

                FASetup.Get();
            if (FASetup."Leave Posting Period[FROM]" <> 0D) and (FASetup."Leave Posting Period[TO]" <> 0D) then;
            ////IF ("Posting Date"<FASetup."Leave Posting Period[FROM]") OR
            //// ("Posting Date">FASetup."Leave Posting Period[TO]")  THEN
            //// ERROR(FORMAT(Text003));


            /*         LeaveEntries.RESET;
                LeaveEntries.SETRANGE(LeaveEntries."Leave Type","Leave Type");
               IF LeaveEntries.FIND('-') THEN BEGIN
            IF LeaveEntries."Leave Entry Type"=LeaveEntries."Leave Entry Type"::"Leave Allocation" THEN BEGIN
            IF (LeaveEntries."Posting Date"<"Leave Period Start Date") OR
                (LeaveEntries."Posting Date">"Leave Period End Date")  THEN
                ERROR(FORMAT(Text004));
                        END;
              END;
               */
        end;

    end;
}
