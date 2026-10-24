namespace PBO.PBO;
using System.Automation;
using Microsoft.HumanResources.Employee;
using System.Security.User;

page 50000 "PBO Administration"
{
    ApplicationArea = All;
    Caption = 'PBO Administration';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                part(Control1907662708; "Approvals Activities")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action("Login Register Report")
            {
                ApplicationArea = all;
                RunObject = report "Login Register Report";
            }
            action("Task Tracking Report")
            {
                ApplicationArea = all;
                RunObject = report "Task Tracking Report";

            }
            action("PBO Meeting Card Report")
            {
                ApplicationArea = all;
                RunObject = report "PBO Meeting Card Report";

            }

        }
        area(Sections)
        {
            group("PBO Meetings")
            {
                action("Open PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Open PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(Open);
                    ToolTip = 'Executes the Open PBO Meetings action.';
                }
                action("pending PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Pending PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(pending);
                    ToolTip = 'Executes the pending PBO List action.';
                }
                action("Proceeding PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Proceeding PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(proceeding);
                    ToolTip = 'Executes the Proceeding List action.';
                }
                action("Successful PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Successful PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(Successful);
                    ToolTip = 'Executes the Successfull PBO Meetings action.';
                }
                action("Failed PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Failed PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(failled);
                    ToolTip = 'Executes the Failled PBO Meetings action.';
                }
            }
            group(perfomanceAppraisal)
            {
                Caption = 'Performance Appraisal';
                action("Perf Corp. Workplan List")
                {
                    ApplicationArea = all;
                    RunObject = page "Perf Corp. Workplan List";
                    Caption = 'Corporate Annual Workplans';
                }
                action("Perf Goal Header List")
                {
                    ApplicationArea = all;
                    RunObject = page "Perf Goal Header List";
                    Caption = 'Individual Performance Goals';
                }

                action("Perf Mitigating Factor List")
                {
                    ApplicationArea = all;
                    RunObject = page "Perf Migating Factor List St.";
                    Caption = 'Mitigating Factors';
                }
                action("Perf Review Header List")
                {
                    ApplicationArea = all;
                    RunObject = page "Perf Review Header List";
                    Caption = 'Performance Reviews';
                }

                action("Perf Reward Sanction List St.")
                {
                    ApplicationArea = all;
                    Caption = 'Rewards and Sanctions';
                    RunObject = page "Perf Reward Sanction List St.";
                }
                group("Appraisal Reports")
                {
                    Caption = 'Appraisal Reports';
                    action("Perf Appraisal Status Report")
                    {
                        ApplicationArea = all;
                        Caption = 'Appraisal Status Report';
                        RunObject = report "Perf Appraisal Status Report";
                    }
                    action("Perf Appraisal Coverage Rprt")
                    {
                        ApplicationArea = all;
                        Caption = 'Staff Appraisal Coverage Report';
                        RunObject = report "Perf Appraisal Coverage Rprt";
                    }
                    action("Perf Target Setting Report")
                    {
                        ApplicationArea = all;
                        Caption = 'Target Setting Report';
                        RunObject = report "Perf Target Setting Report";
                    }
                    action("Perf Periodic Evaluation Rprt")
                    {
                        ApplicationArea = all;
                        Caption = 'Periodic Evaluation Report';
                        RunObject = report "Perf Periodic Evaluation Rprt";
                    }
                    action("Perf Score Report")
                    {
                        ApplicationArea = all;
                        Caption = 'Performance Score Report';
                        RunObject = report "Perf Score Report";
                    }
                    action("Perf Employee Performance Rprt")
                    {
                        ApplicationArea = all;
                        Caption = 'Employee Performance Report';
                        RunObject = report "Perf Employee Performance Rprt";
                    }
                    action("Perf Competency Analysis Rprt")
                    {
                        ApplicationArea = all;
                        Caption = 'Competency Analysis Report';
                        RunObject = report "Perf Competency Analysis Rprt";
                    }
                    action("Perf Training Needs Report")
                    {
                        ApplicationArea = all;
                        Caption = 'Training Needs Report';
                        RunObject = report "Perf Training Needs Report";
                    }
                    action("Perf Rewards Sanctions Report")
                    {
                        ApplicationArea = all;
                        Caption = 'Rewards and Sanctions Report';
                        RunObject = report "Perf Rewards Sanctions Report";
                    }
                }
                group("Appraisal Setups")
                {
                    Caption = 'Appraisal Setups';
                    action("Perf Setup Card")
                    {
                        ApplicationArea = all;
                        Caption = 'Performance Appraisal Setup';
                        RunObject = page "Perf Setup Card";
                    }
                    action("Perf Appraisal Period List")
                    {
                        ApplicationArea = all;
                        Caption = 'Appraisal Periods';
                        RunObject = page "Perf Appraisal Period List";
                    }
                    action("Perf Rating Scale")
                    {
                        ApplicationArea = all;
                        Caption = 'Performance Rating Scale';
                        RunObject = page "Perf Rating Scale";
                    }
                }
            }
            group("Task Management")
            {
                group("Tasks")
                {
                    action("Task Details List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open Task Details';
                        RunObject = page "Tasks List";
                        RunPageLink = "Task Status" = filter(Open);
                    }
                    action("Forwarded Task List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Forwarded Task List';
                        RunObject = page "Tasks List";
                        RunPageLink = "Task Status" = filter(Forwared);
                    }
                    action("Archived Task List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archived Task List';
                        RunObject = page "Tasks List";
                        RunPageLink = "Task Status" = filter(Archived);
                    }


                    action("Track Forwarded Task")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Track Forwarded Task';
                        RunObject = page "Track Forward List";
                        RunPageLink = "Task Status" = filter(Forwared);

                    }
                    action("Task Locations")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Task Locations';
                        RunObject = page "Task Locations List";
                    }
                }

                group("Task Tracking")
                {
                    action("Open Task Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open Task Tracker List';
                        RunObject = page "Task Tracker List";
                        RunPageView = where("Task Request Status" = filter(Open));
                    }
                    action("Task Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Task Requests';
                        RunObject = page "Task Tracker List";
                        RunPageView = where("Task Request Status" = filter(Requested));
                    }
                    action("Issued Tasks")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Tasks';
                        RunObject = page "Task Tracker List";
                        RunPageView = where("Task Request Status" = filter(Issued));
                    }
                    action("Received Tasks")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Received Tasks';
                        RunObject = page "Task Tracker List";
                        RunPageView = where("Task Request Status" = filter(Received));
                    }
                    // action("Forwarded Tasks")
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Forwarded Tasks';
                    //     RunObject = page "Task Tracker List";
                    //     RunPageView = where("Task Request Status" = filter(Forwarded));
                    // }
                    action("Closed Task Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Closed Task Request';
                        RunObject = page "Task Tracker List";
                        RunPageView = where("Task Request Status" = filter(Closed));
                    }
                    action("Overdue Task Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Overdue Tasks Requests';
                        RunObject = page "Task Tracker List";
                        RunPageView = where(Overdue = const(true));
                    }
                    // action("Task List")
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Task Tracker List';
                    //     RunObject = page "Task Tracker List";
                    //     RunPageView = where(Status = filter(<> archived));
                    // }
                }
                group("Task Batching & Archiving")
                {
                    Visible = false;
                    action("Batching & Archiving Process")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open Task Batch';
                        RunObject = page "Batching Process List";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Batches Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Task Batch Pending Approval';
                        RunObject = page "Batching Process List";
                        RunPageView = where(Status = const(Pending));
                    }
                    action("Rejected Batches")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Rejected Task Batch';
                        RunObject = page "Batching Process List";
                        RunPageView = where(Status = const(Rejected));
                    }
                    action("Approved Batches")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved Task Batch';
                        RunObject = page "Batching Process List";
                        RunPageView = where(Status = const(Approved));
                    }
                    action("Archived Task Volumes")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archived Tasks Volumes';
                        //RunObject = page "Batching Lines";
                        RunObject = page "Batching Lines List";
                    }
                }
                group("Task Configurations.")
                {
                    action("User Station List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'User Stations';
                        RunObject = page "User Station List";
                    }
                    action("Task Movement Remarks")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Task Movement Remarks';
                        RunObject = page "Task MVT Remarks";
                    }
                    action("Task Stations")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Task Stations';
                        RunObject = page "Task Stations";
                    }
                }
                group("Register")
                {
                    action("Login Register")
                    {
                        ApplicationArea = all;
                        RunObject = page "Login Register List";

                    }
                }
            }
            group("HR Leave Management")
            {
                Caption = 'HR Leave Management';
                Image = HumanResources;
                group("HR Leave Application")
                {
                    action("HR Leave Application New")
                    {
                        ApplicationArea = Basic;
                        Caption = 'HR Leave Application New';
                        RunObject = page "HR Leave Applications List";
                        RunPageLink = Status = const(New);
                        ToolTip = 'Executes the HR Leave Application action.';
                    }
                    action("HR Leave Application Pending")
                    {
                        ApplicationArea = Basic;
                        Caption = 'HR Leave Application Pending';
                        RunObject = page "HR Leave Applications List";
                        RunPageLink = Status = const("Pending Approval");
                        ToolTip = 'Executes the HR Leave Application action.';
                    }
                    action("HR Leave Application Approved")
                    {
                        ApplicationArea = Basic;
                        Caption = 'HR Leave Application Approved';
                        RunObject = page "HR Leave Applications List";
                        RunPageLink = Status = const(Approved);
                        ToolTip = 'Executes the HR Leave Application action.';
                    }
                    action("HR Leave Application Rejected")
                    {
                        ApplicationArea = Basic;
                        Caption = 'HR Leave Application Rejected';
                        RunObject = page "HR Leave Applications List";
                        RunPageLink = Status = const(Rejected);
                        ToolTip = 'Executes the HR Leave Application action.';
                    }
                }
                action("HR Leave Reimbursment ")
                {
                    ApplicationArea = Basic;
                    Caption = 'HR Leave Reimbursment ';
                    RunObject = page "HR Leave Reimbursment List";
                    ToolTip = 'Executes the HR Leave Reimbursment  action.';
                }
                action("HR Leave Types")
                {
                    ApplicationArea = Basic;
                    Caption = 'HR Leave Types';
                    RunObject = page "HR Leave Types";
                    ToolTip = 'Executes the HR Leave Types action.';
                }
                action("Leave Adjustment")
                {
                    ApplicationArea = all;
                    RunObject = page "HR Leave Journal Lines";
                    Caption = 'Hr Leave Adjustment';
                }
                action("Leave Periods")
                {
                    ApplicationArea = all;
                    RunObject = page "HR Leave Period List";
                    Caption = 'Leave Periods';
                }
                action("All Employees")
                {
                    ApplicationArea = all;
                    RunObject = page "PBO Staff List";
                    Caption = 'PBO Staff List';
                }
                action("Leave Management")
                {
                    ApplicationArea = all;
                    RunObject = page "HR Leave Applications List";
                }
            }
            group(Setups)
            {
                action("User Setup")
                {
                    ApplicationArea = all;
                    RunObject = page "User Setup";
                    Caption = 'User Setup';
                }
                action("Hr Setup")
                {
                    ApplicationArea = all;
                    Caption = 'Hr Setup';
                    RunObject = page "Hr Setup";
                }
                action(users)
                {
                    ApplicationArea = all;
                    Caption = 'Users';
                    RunObject = page Users;
                }
                action(workflows)
                {
                    ApplicationArea = all;
                    Caption = 'Workflow';
                    RunObject = page Workflow;
                }
                action("Sms messages")
                {
                    ApplicationArea = all;
                    RunObject = page "SMS Messages";
                    Caption = 'Sms Messages';
                }
                action("Bulk SMS")
                {
                    ApplicationArea = all;
                    RunObject = page "PBO Sms List";
                    Caption = 'PBO Sms List';
                }
            }
        }
    }

}
profile "administration Rolecenter"
{
    Caption = 'PBO Administration';
    RoleCenter = "PBO Administration";
    profileDescription = 'PBO Administration';
}
