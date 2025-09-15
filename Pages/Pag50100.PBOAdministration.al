namespace PBO.PBO;
using System.Automation;
using System.Security.User;

page 50100 "PBO Administration"
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
                action("Successfull PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Successfull PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(Successful);
                    ToolTip = 'Executes the Successfull PBO Meetings action.';
                }
                action("Failled PBO Meetings")
                {
                    ApplicationArea = Basic;
                    Caption = 'Failled PBO Meetings';
                    RunObject = page "PBO Meeting List";
                    RunPageLink = "Meeting Status" = const(failled);
                    ToolTip = 'Executes the Failled PBO Meetings action.';
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

                    action("Task Locations")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Task Locations';
                        RunObject = page "Task Locations List";
                    }
                    action("Batch Number List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Batch No List';
                        RunObject = page "Batch No List";
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
