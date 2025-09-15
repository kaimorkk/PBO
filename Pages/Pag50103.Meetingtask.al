namespace PBO.PBO;
using Microsoft.HumanResources.Employee;
using Microsoft.Foundation.Company;
using System.Email;


page 50103 "Meeting task"
{
    ApplicationArea = All;
    Caption = 'Meeting Task';
    PageType = ListPart;
    PromotedActionCategories = 'New,Report,Process,Notification';
    SourceTable = "Meeting Task";

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                Caption = 'General';

                field("Commitee Code"; Rec."Commitee Code")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field("Employee No"; Rec."Employee No")
                {
                    ToolTip = 'Specifies the value of the Employee No. field.', Comment = '%';
                }
                field(Names; Rec.Names)
                {
                    ToolTip = 'Specifies the value of the Full Name field.', Comment = '%';
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the value of the Email field.', Comment = '%';
                }
                field(Task; Rec.Task)
                {
                    ToolTip = 'Specifies the value of the Remarks field.', Comment = '%';
                    MultiLine = true;

                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Send Notification")

            {
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ApplicationArea = all;
                trigger OnAction()
                var
                    myInt: Integer;
                    HRDiscipMemb: Record "Meeting Task";
                    Employee: Record Employee;
                    AccName: Text;
                    CompanIn: Record "Company Information";
                    msg: Text;
                    EmailManager: Codeunit "Email Message";
                    Email: Codeunit Email;
                begin
                    if not Confirm('Do you want to send notification?') then exit;
                    HRDiscipMemb.Reset();
                    HRDiscipMemb.SetRange(HRDiscipMemb."Commitee Code", Rec."Commitee Code");
                    if HRDiscipMemb.Find('-') then
                        repeat
                            if Employee.Get(HRDiscipMemb."Employee No") then begin
                                AccName := '';
                                CompanIn.Get();
                                AccName := Employee."First Name";
                                if AccName = '' then
                                    AccName := Employee."Middle Name";
                                msg := 'Dear ' + AccName + '<br><>br'', you have  been assigned  the follwowing task ' + HRDiscipMemb.Task + ' by  meeting no. ' + ' ' + Rec."Commitee Code" + ' ' + '' + 'Kindly for Further Information Contact the Head department. Thank you.';
                                EmailManager.Create(HRDiscipMemb.Email, 'Commitee Notifications', msg, true);
                                Email.Send(EmailManager, Enum::"Email Scenario"::Default);
                            end;
                        until HRDiscipMemb.Next() = 0;
                    Message('Email sent successfully');
                end;
            }
        }


    }

}
