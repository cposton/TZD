program TZD;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    Windows,
    System.Generics.Collections,
    System.SysUtils,
    System.DateUtils,
    TZ in 'TZ.pas';

const
    DATE_TIME_FORMAT = 'yyyy-mm-dd hh:nn';

var
    OutputFile: TextFile;
    TimeZones: TList<TDynamicTimeZoneInformation>;
    TZ: TDynamicTimeZoneInformation;
    TestDateTime: TDateTime;
    UTCTime: TSystemTime;
    ConvertedTime: TSystemTime;
begin
    TimeZones := GetTimeZones;

    CreateDir('Output');

    try
        for TZ in TimeZones do
        begin
            Writeln('Processing ', TZ.TimeZoneKeyName, '...');

            AssignFile(OutputFile, 'Output\' + TZ.TimeZoneKeyName + '.txt');
            ReWrite(OutputFile);

            try
                TestDateTime := EncodeDateTime(2021, 1, 1, 0, 0, 0, 0);

                repeat
                    DateTimeToSystemTime(TestDateTime, UTCTime);

                    SystemTimeToTzSpecificLocalTimeEx(@TZ, UTCTime, ConvertedTime);

                    //TFormatSettings.Invariant
                    Writeln(OutputFile, FormatDateTime(DATE_TIME_FORMAT, SystemTimeToDateTime(UTCTime)), ',', FormatDateTime(DATE_TIME_FORMAT, SystemTimeToDateTime(ConvertedTime)));

                    TestDateTime := IncMinute(TestDateTime, 10);
                until (YearOf(TestDateTime) = 2032)
            finally
                CloseFile(OutputFile);
            end;
        end;
    except
        on E: Exception do
            Writeln(E.ClassName, ': ', E.Message);
    end;

end.
