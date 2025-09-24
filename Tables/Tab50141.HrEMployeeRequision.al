 
   
table 50141 "HR Employee Requisitions"
{
 
    Caption = 'HR Employee Requisitions';
    DataClassification = CustomerContent;
    fields
    {
        field(2; "Job ID"; Code[20])
        {
            NotBlank = true;
            // TableRelation = "HR Jobs"."Job ID" where(Status = const(Approved));
            Caption = 'Job ID';
            trigger OnValidate()
            begin
                // HRJobs.Reset();
                // HRJobs.SetRange("Job ID", rec."Job ID");
                // if HRJobs.FindFirst() then begin
                //     "Job Description" := HRJobs."Job Description";
                //     "Vacant Positions" := HRJobs."Vacant Positions";
                //     "Job Grade" := HRJobs.Grade;
                //     "Global Dimension 2 Code" := HRJobs."Global Dimension 2 Code";
                //     "Job Supervisor/Manager" := HRJobs."Supervisor/Manager";
                //     HRJobs."Responsibility Center" := "Responsibility Center";
                // end;
            end;

        }
        field(3; "Requisition Date"; Date)
        {
            Caption = 'Requisition Date';
            trigger OnValidate()
            begin
                // if (Rec."Requisition Date" - Today) < 0 then
                //     Message('Days in the past are not allowed');
            end;
        }
        field(4; Priority; Option)
        {
            OptionCaption = ' ,High,Medium,Low';
            OptionMembers = " ",High,Medium,Low;
            Caption = 'Priority';
        }
        field(5; Positions; Integer)
        {
            Caption = 'Positions';
        }
        field(6; Approved; Boolean)
        {
            Caption = 'Approved';
            trigger OnValidate()
            begin
                "Date Approved" := Today;
            end;
        }
        field(7; "Date Approved"; Date)
        {
            Caption = 'Date Approved';
        }
        field(8; "Job Description"; Text[200])
        {
            Editable = false;
            Caption = 'Job Description';
        }
        field(9; Stage; Code[20])
        {
            FieldClass = FlowFilter;
            Caption = 'Stage';
        }
        field(10; Score; Decimal)
        {
            FieldClass = Normal;
            Caption = 'Score';
        }
        field(11; "Stage Code"; Code[20])
        {
            Caption = 'Stage Code';
        }
        field(12; Qualified; Boolean)
        {
            FieldClass = Normal;
            Caption = 'Qualified';
        }
        field(13; "Job Supervisor/Manager"; Code[20])
        {
            Caption = 'Job Supervisor/Manager';
        }
        field(14; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Directorates';
            FieldClass = Normal;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            trigger OnValidate()
            var
                myInt: Integer;
                DimensionValue: Record "Dimension Value";
            begin
                DimensionValue.Reset();
                DimensionValue.SetRange(Code, Rec."Global Dimension 2 Code");
                if DimensionValue.FindFirst() then
                    "Directorates Name" := DimensionValue.Name;

            end;
        }
        field(17; "Turn Around Time"; Integer)
        {
            Editable = false;
            Caption = 'Turn Around Time';
        }
        field(21; "Grace Period"; Integer)
        {
            Caption = 'Grace Period';
        }
        field(25; Closed; Boolean)
        {
            Editable = true;
            Caption = 'Closed';
        }
        field(26; "Requisition Type"; Option)
        {
            OptionCaption = ' ,Internal,External,Both';
            OptionMembers = " ",Internal,External,Both;
            Caption = 'Requisition Type';
        }
        field(27; "Closing Date"; Date)
        {
            Editable = true;
            Caption = 'Closing Date';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                rec.TestField("Opening Date");

                if "Closing Date" < "Opening Date" then
                    Error('Closing date cannot be less than opening date');
                if "Closing Date" < Today then
                    Error('This job cannot be advertised,Kindly check on the closing date');

            end;

        }
        field(28; Status; Option)
        {
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New,"Pending Approval",Approved,Rejected;
            Caption = 'Status';
        }
        field(38; "Required Positions"; Decimal)
        {
            Caption = 'Required Positions';
            trigger OnValidate()
            begin
                if "Required Positions" > "Vacant Positions" then
                    Error('Required positions exceed the total  no of Vacant Positions');

                if "Required Positions" <= 0 then
                    Error('Required positions cannot be Less Than or Equal to Zero');
            end;
        }
        field(39; "Vacant Positions"; Decimal)
        {
            Editable = false;
            Caption = 'Vacant Positions';
        }
        field(3949; "Reason for Request(Other)"; Text[250])
        {
            Caption = 'Reason for Request(Other)';
        }
        field(3950; "Any Additional Information"; Text[250])
        {
            Caption = 'Any Additional Information';
        }
        field(3958; "Job Grade"; Text[100])
        {
            TableRelation = "HR Lookup Values".Code where(Type = const(Grade));
            Caption = 'Job Grade';
        }
        field(3964; "Type of Contract Required"; Option)
        {
            //TableRelation = "HR Lookup Values".Code where(Type = filter("Contract Type"));
            Caption = 'Type of Contract Required';
            OptionCaption = 'Permanent and Pensionable,Contract,Casual,Internship,Attachment';
            OptionMembers = Permanent,Contract,Casual,Internship,Attachment;
        }
        field(3965; "Reason For Request"; Option)
        {
            OptionMembers = "New Vacancy",Replacement,Retirement,Retrenchment,Demise,Other;
            Caption = 'Reason For Request';
        }
        field(3966; Requestor; Code[50])
        {
            // Editable = fal/se;
            Caption = 'Requestor';
        }
        field(3967; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
        }
        field(3968; "Requisition No."; Code[50])
        {
            // Editable = false;
            TableRelation = "HR Employee Requisitions"."Requisition No.";
            Caption = 'Requisition No.';
            trigger OnValidate()
            var
                myInt: Integer;
                Requisions: Record "HR Employee Requisitions";
            begin
                Requisions.Reset();
                Requisions.SetRange("Requisition No.", Rec."Requisition No.");
                if Requisions.Find('-') then begin
                    rec."Job ID" := Requisions."Job ID";
                    rec.Validate("Job ID");
                    rec."Requisition Date" := Requisions."Requisition Date";
                    rec.Priority := Requisions.Priority;
                    rec."Required Positions" := Requisions."Required Positions";
                end;

            end;
        }
        field(3969; "Responsibility Center"; Code[10])
        {
            TableRelation = "Responsibility Center".Code;
            //TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            Caption = 'Department';
            //CaptionClass = '1,1,2';

            trigger OnValidate()
            var
                myInt: Integer;
                Responsblece: Record "Responsibility Center";
            begin
                Responsblece.Reset();
                Responsblece.SetRange(Code, Rec."Responsibility Center");
                if Responsblece.FindFirst() then
                    "Department Name" := Responsblece.Name;

            end;
        }
        field(3970; "Shortlisting Comittee"; Code[20])
        {
            Caption = 'Shortlisting Comittee';
        }
        field(3971; Advertised; Boolean)
        {
            Editable = false;
            Caption = 'Advertised';
        }
        field(50001; "Opening Date"; Date)
        {
            Caption = 'Opening Date';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if rec."Opening Date" < Today then
                    Error('You cannot back date the opening date for this job');

            end;

        }
        field(50002; "Interviews Closed"; Boolean)
        {
            Caption = 'Interviews Closed';
        }
        field(50003; "Employee No"; Code[50])
        {
            Caption = 'Employee No';
        }
        field(50004; "Full Name"; Text[150])
        {
            Caption = 'Full Name';
        }
        field(50005; MyRecId; RecordId)
        {
            Caption = 'MyRecId';
        }
        field(50006; "Close Comments"; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(50007; "Expected Experience"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Expected Experience';

        }
        field(50008; "Department Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50009; "Directorates Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Requisition No.")
        {
            Clustered = true;
        }
        key(Key2; "Job ID") { }
        key(Key3; "Job Description") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Requisition No.", "Job ID", "Job Description") { }
    }

    trigger OnDelete()
    begin

        if Status <> Status::New then
            Error('You cannot delete this record if its status is' + ' ' + Format(Status));
    end;

    trigger OnInsert()
    var
        Employees: Record Employee;
    begin
        //GENERATE DOCUMENT NUMBER
        if "Requisition No." = '' then begin
            HRSetup.Get();
            // HRSetup.TestField(HRSetup."Employee Requisition Nos.");
            // NoSeriesMgt.InitSeries(HRSetup."Employee Requisition Nos.", xRec."No. Series", 0D, "Requisition No.", "No. Series");
        end;

        userSetup.Reset();
        userSetup.SetRange(userSetup."User ID", UserId);
        if userSetup.Find('-') then begin
            // mDivision := userSetup."Global Dimension 2 Code";
            mResponsibility := userSetup."Responsibility Center";
            Employees.Reset();
            Employees.SetRange("User ID", userSetup."User ID");
            if Employees.Find('-') then begin
                rec."Global Dimension 2 Code" := Employees."Global Dimension 2 Code";
                rec.Validate(rec."Global Dimension 2 Code");
                // rec."Responsibility Center" := Employees."Responsibility Center";
                rec.Validate(rec."Responsibility Center");


            end;
        end;

        //POPULATE FIELDS
        Requestor := UserId;
        "Requisition Date" := Today;
        "Responsibility Center" := mResponsibility;
        "Global Dimension 2 Code" := mDivision;


        MyRecRef.GetTable(Rec);
        MyRecId := MyRecRef.RecordId;
    end;

    trigger OnModify()
    begin
        userSetup.Reset();
        userSetup.SetRange(userSetup."User ID", UserId);
        if userSetup.Find('-') then begin
            mDivision := userSetup."Global Dimension 1 Code";
            mResponsibility := userSetup."Responsibility Center";
        end;
    end;

    var
        HRSetup: Record "HR Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        // HRJobs: Record "HR Jobs";
        HREmployeeReq: Record "HR Employee Requisitions";
        userSetup: Record "User Setup";
        mDivision: Code[50];
        mResponsibility: Code[50];
        MyRecRef: RecordRef;
}
