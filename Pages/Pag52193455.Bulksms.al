
page 52193455 "Bulk sms"
{
    SourceTable = "Sms Header";
    ApplicationArea = All;
    Caption = 'PBO Bulk Sms';
    PageType = Card;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Report,Process,Workflow Process,Manager Details';

    layout
    {
        area(Content)
        {
            group(General)
            {


                field(No; Rec.No)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Date Entered"; Rec."Date Entered")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Time Entered"; Rec."Time Entered")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Entered By"; Rec."Entered By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("SMS Type"; Rec."SMS Type")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("SMS Status"; Rec."SMS Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = all;
                    Caption = 'Department';
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = Basic;
                    Editable = Mssage;
                    MultiLine = true;
                }
            }
            part(Control1000000012; "Sms Lines")
            {
                Caption = 'Bulk SMS Lines';
                Editable = BulkSMSLines;
                SubPageLink = No = field(No);
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Send)
            {
                ApplicationArea = Basic;
                Image = PutawayLines;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MessageTyp: Enum "Message Type";
                begin
                    ///Kyalo Code from Old System for Sending SMS 
  //*******************************************************************************************************
                    if Confirm('Are you sure you would like to send the SMS(ES)?', false) = true then begin
                        MessageTyp := MessageTyp::Other;
                        BulkHeader.Reset;
                        BulkHeader.SetRange(BulkHeader.No, Rec.No);
                        if BulkHeader.Find('-') then begin
                            //ALL
                            //DIMENSION
                            if BulkHeader."SMS Type" = BulkHeader."sms type"::Other then begin
                                rec.TestField(Message);
                                BulkLines.Reset;
                                BulkLines.SetRange("Sms sent", false);
                                BulkLines.SetRange(BulkLines.No, Rec.No);
                                if BulkLines.Find('-') then begin
                                    repeat
                                        Vend.Reset;
                                        Vend.SetRange(Vend."No.", BulkLines."Client No");
                                        if Vend.Find('-') then begin
                                            //sms
                                            SureFactory.SendPboComSMS(BulkLines."Phone No", rec.Message, BulkLines."Client No", MessageTyp);
                                            BulkLines."Sms sent" := true;
                                            BulkLines.Modify();

                                        end;
                                    until BulkLines.Next = 0;
                                    BulkHeader.Status := BulkHeader.Status::Approved;
                                    BulkHeader.Modify();
                                end;
                            end;
                        end;
                        Message('Done!');

                    end;
                end;

            }
            action("Load All Employees")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var

                    myInt: Integer;
                    CustomerRec: Record Employee;
                    GreenSmsLines: Record "Sms Lines";
                    LineN: Integer;
                begin
                    GreenSmsLines.Reset();
                    GreenSmsLines.SetRange(No, rec.No);
                    if GreenSmsLines.FindSet() then
                        GreenSmsLines.DeleteAll();
                    CustomerRec.Reset();
                    CustomerRec.SetRange("Global Dimension 1 Code", rec."Global Dimension 1 Code");
                    if CustomerRec.Find('-') then
                        repeat

                            LineN := 0;
                            GreenSmsLines.Reset();
                            if GreenSmsLines.FindSet() then
                                LineN := GreenSmsLines.Count;
                            GreenSmsLines.Init();
                            GreenSmsLines."Client No" := CustomerRec."No.";
                            GreenSmsLines.No := rec.No;
                            GreenSmsLines."entry No" := LineN + 1;
                            GreenSmsLines.Validate(GreenSmsLines."Client No");
                            GreenSmsLines."Phone No" := CustomerRec."Phone No.";
                            GreenSmsLines.Insert();
                        until CustomerRec.Next() = 0;

                end;
            }

        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        UpdateControl();
    end;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        UpdateControl();
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        UpdateControl();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

    end;

    var
        BulkHeader: Record "Sms Header";
        SureFactory: Codeunit "Hr Portal";
        BulkLines: Record "Sms Lines";
        FName: Text;
        Vend: Record Employee;
        OustBalc: Decimal;
        SMSMessage: Record "SMS Messages";
        memberApplication: Record Employee;
        iEntryNo: Integer;
        msg: Text;
        //  StatusPermissions: Record "Status Change Permision";
        ApprovalEntries: Page "Approval Entries";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","None",JV,"Member Closure","Account Opening",Batches,"Payment Voucher","Petty Cash",Requisition,Loan,Interbank,Imprest,Checkoff,"FOSA Account Opening",StandingOrder,HRJob,HRLeave,"HRTransport Request",HRTraining,"HREmp Requsition",MicroTrans,"Account Reactivation",Overdraft,ImprestSurrender,"MSacco Applications","MSacco PinChange","MSacco PhoneChange","MSacco TransChange",BulkSMS;
        text001: label 'Status must be Open';
        text002: label 'Status must be Pending';
        Mssage: Boolean;
        UseHeader: Boolean;
        BulkSMSLines: Boolean;

    procedure UpdateControl()
    begin
        if Rec.Status = Rec.Status::Open then begin
            Mssage := true;
            UseHeader := true;
            BulkSMSLines := true;
        end;
        if Rec.Status = Rec.Status::Pending then begin
            Mssage := false;
            UseHeader := false;
            BulkSMSLines := false;
        end;
        if Rec.Status = Rec.Status::Rejected then begin
            Mssage := false;
            UseHeader := false;
            BulkSMSLines := false;
        end;
        if Rec.Status = Rec.Status::Approved then begin
            Mssage := false;
            UseHeader := false;
            BulkSMSLines := false;
        end;
    end;
}
