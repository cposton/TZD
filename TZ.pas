unit TZ;

interface

uses
    Windows,
    System.Generics.Collections,
    System.SysUtils;

function SystemTimeToTzSpecificLocalTimeEx(lpTimeZoneInformation: PTimeZoneInformation; var lpUniversalTime, lpLocalTime: TSystemTime): BOOL; stdcall;
function EnumDynamicTimeZoneInformation(dwIndex: DWORD; lpTimeZoneInformation: PDynamicTimeZoneInformation): DWORD; stdcall;

function ConvertTime(AUTCTime: TDateTime; ATimeZone: TDynamicTimeZoneInformation): TDateTime;
function GetTimeZones: TList<TDynamicTimeZoneInformation>;

implementation

function SystemTimeToTzSpecificLocalTimeEx(lpTimeZoneInformation: PTimeZoneInformation; var lpUniversalTime, lpLocalTime: TSystemTime): BOOL; stdcall; external kernel32 name 'SystemTimeToTzSpecificLocalTimeEx';
function EnumDynamicTimeZoneInformation(dwIndex: DWORD; lpTimeZoneInformation: PDynamicTimeZoneInformation): DWORD; stdcall; external advapi32 name 'EnumDynamicTimeZoneInformation';

function ConvertTime(AUTCTime: TDateTime; ATimeZone: TDynamicTimeZoneInformation): TDateTime;
var
    UTCTime: TSystemTime;
    ConvertedTime: TSystemTime;
begin
    DateTimeToSystemTime(AUTCTime, UTCTime);

    SystemTimeToTzSpecificLocalTimeEx(@ATimeZone, UTCTime, ConvertedTime);

    Result := SystemTimeToDateTime(ConvertedTime);
end;

function GetTimeZones: TList<TDynamicTimeZoneInformation>;
var
    Index: Integer;
    R: DWORD;
    TZI: TDynamicTimeZoneInformation;
begin
    Index := 0;
    Result := TList<TDynamicTimeZoneInformation>.Create;

    repeat
        R := EnumDynamicTimeZoneInformation(Index, @TZI);

        if R = ERROR_SUCCESS then
        begin
            Result.Add(TZI);
        end
        else if R <> ERROR_NO_MORE_ITEMS then
        begin
            Writeln('Failed ' + IntToStr(R));
        end;

        Inc(Index);
    until (R = ERROR_NO_MORE_ITEMS);
end;

end.

