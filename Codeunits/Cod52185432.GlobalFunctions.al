namespace PBO.PBO;
codeunit 50001 "Global Functions"
{
    trigger OnRun()
    begin

    end;



    procedure DMUDateFormatDate(Realdate: date) dateText: Text;
    var
        Month: Integer;
        Day: Integer;
        year: Integer;

    begin
        IF RealDate <> 0D THEN BEGIN
            Day := DATE2DMY(RealDate, 1);
            Month := DATE2DMY(RealDate, 2);
            Year := DATE2DMY(RealDate, 3);
        END;

        DateText := FORMAT(Day) + '/' + Format(Month) + '/' + FORMAT(Year);

        IF RealDate = 0D THEN DateText := '';
    end;

    procedure DMUDateFormatDateTime(RealdateTime: DateTime) dateText: Text;
    var
        Month: Integer;
        Day: Integer;
        year: Integer;

    begin
        if RealdateTime <> 0DT then begin
            Day := DATE2DMY(DT2Date(RealdateTime), 1);
            Month := DATE2DMY(DT2Date(RealdateTime), 2);
            Year := DATE2DMY(DT2Date(RealdateTime), 3);

            DateText := FORMAT(Day) + '/' + Format(Month) + '/' + FORMAT(Year);
        end;

        IF RealdateTime = 0DT THEN DateText := '';
    end;

    procedure FormatDateFullMonth(Realdate: date) dateText: Text;
    var
        Month: Integer;
        FormatedMonth: Text;
        Day: Integer;
        year: Integer;

    begin
        IF RealDate <> 0D THEN BEGIN
            Day := DATE2DMY(RealDate, 1);
            Month := DATE2DMY(RealDate, 2);
            Year := DATE2DMY(RealDate, 3);
        END;

        IF Month = 1 THEN FormatedMonth := 'January';
        IF Month = 2 THEN FormatedMonth := 'February';
        IF Month = 3 THEN FormatedMonth := 'March';
        IF Month = 4 THEN FormatedMonth := 'April';
        IF Month = 5 THEN FormatedMonth := 'May';
        IF Month = 6 THEN FormatedMonth := 'June';
        IF Month = 7 THEN FormatedMonth := 'July';
        IF Month = 8 THEN FormatedMonth := 'August';
        IF Month = 9 THEN FormatedMonth := 'September';
        IF Month = 10 THEN FormatedMonth := 'October';
        IF Month = 11 THEN FormatedMonth := 'November';
        IF Month = 12 THEN FormatedMonth := 'December';

        DateText := FORMAT(Day) + ' ' + 'of' + ' ' + FormatedMonth + ' ' + FORMAT(Year);

        IF RealDate = 0D THEN DateText := '';
    end;


    // Loop through each day between the start and end dates
    // while StartDate <= EndDate do
    // begin
    //     if BaseCalender.GET(StartDate) then
    //     begin
    //         if BaseCalender.Nonworking = FALSE then
    //         begin
    //             NonWorkingDaysCount += 1;
    //         end;
    //     end;

    //     StartDate := StartDate + 1;
    // end;



    procedure FormatISODateTime(RealDateTime: DateTime): Text
    var
        TZDuration: Duration;
    begin
        if RealDateTime = 0DT then begin
            Exit('');
        end;

        TZDuration := 1000 * 60 * 60 * 3; // GMT + 3
        RealDateTime := RealDateTime + TZDuration;

        Exit(
            FormatISODate(DT2Date(RealDateTime)) + ' ' +
            FORMAT(RealDateTime, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>')
        );
    end;

    procedure RandomPIN(): Text
    var
        NewPin: Text;
        NewIntPin: Integer;
    begin


        NewPin := '';
        NewIntPin := Random(9);
        NewPin += Format(NewIntPin);
        NewIntPin := Random(9);
        NewPin += Format(NewIntPin);
        NewIntPin := Random(9);
        NewPin += Format(NewIntPin);
        NewIntPin := Random(9);
        NewPin += Format(NewIntPin);


        exit(NewPin);
    end;

    // local procedure GeneratePin(var CreatedPassword: Text; var HashedPassword: Text)
    // var
    //     ValidChar: array[21] of Char;
    // // SHA256Demo: Codeunit "Sky Mbanking";
    // begin
    //     CreatedPassword := CreateGuid;
    //     CreatedPassword := DelChr(CreatedPassword, '=', '{}-01');
    //     CreatedPassword := CopyStr(CreatedPassword, 1, 8);
    //     //MESSAGE(RandomDigit) ;
    //     HashedPassword := SHA256Demo.CalculateSHA256(CreatedPassword);
    // end;

    procedure FormatISODate(RealDate: date): Text
    begin
        if RealDate = 0D then begin
            Exit('');
        end;

        Exit(
            Format(DATE2DMY(RealDate, 3)) + '-' +
            Format(DATE2DMY(RealDate, 2)).PadLeft(2, '0') + '-' +
            Format(DATE2DMY(RealDate, 1)).PadLeft(2, '0')
        );
    end;

    procedure FormatDate(Realdate: date) dateText: Text;
    var
        Month: Integer;
        FormatedMonth: Text;
        Day: Integer;
        year: Integer;

    begin
        IF RealDate <> 0D THEN BEGIN
            Day := DATE2DMY(RealDate, 1);
            Month := DATE2DMY(RealDate, 2);
            Year := DATE2DMY(RealDate, 3);
        END;

        IF Month = 1 THEN FormatedMonth := 'Jan';
        IF Month = 2 THEN FormatedMonth := 'Feb';
        IF Month = 3 THEN FormatedMonth := 'Mar';
        IF Month = 4 THEN FormatedMonth := 'Apr';
        IF Month = 5 THEN FormatedMonth := 'May';
        IF Month = 6 THEN FormatedMonth := 'June';
        IF Month = 7 THEN FormatedMonth := 'July';
        IF Month = 8 THEN FormatedMonth := 'Aug';
        IF Month = 9 THEN FormatedMonth := 'Sept';
        IF Month = 10 THEN FormatedMonth := 'Oct';
        IF Month = 11 THEN FormatedMonth := 'Nov';
        IF Month = 12 THEN FormatedMonth := 'Dec';

        DateText := FORMAT(Day) + ' ' + FormatedMonth + ' ' + FORMAT(Year);

        IF RealDate = 0D THEN DateText := '';
    end;


}