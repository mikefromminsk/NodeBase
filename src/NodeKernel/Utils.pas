unit Utils;

interface

uses
  Windows, ImageHlp, Classes, SysUtils, StrUtils, Math, Dialogs, ExtCtrls,
  Messages;

type
  AString = Array of String;
  AInteger = Array of Integer;

  ARange = Array[0..2] of Integer;

function slice(Text: String; Delimeter: String): AString;
procedure slice_params(Text: String; Delimeter: String; var Names, Values: AString);
function IntToStr4(Num: Integer): String;
function StrToInt4(Str: String): Integer;
function FloatToStr8(Num: Double): String;
function StrToFloat8(Str: String): Double;
function EncodeStr(Str: String; Position: Integer = 1): String;
function DecodeStr(Str: String): String;
function PosI(Index: Integer; Substr: String; S: String): Integer;
function Index(const Substr: Array of String; Str: String): Integer;
function NextIndex(Index: Integer; const Substr: Array of String; Str: String): Integer;
function GetFunctionList(const FileName: string; var FuncName: AString): Integer;
function GetProcAddress(Handle: Integer; FuncName: String): Integer;
function ToFileSystemName(var Indexes: AString): String;
function LoadFromFile(FileName: String): String;
function SaveToFile(FileName: String; var Data: String): Integer;
function CreateDir(Indexes: AString): String;


function Random(Range: Integer): Integer; overload;
function Random(Arr: AInteger; var InnerIndex: Integer): Integer;  overload;
function Random(Arr: AInteger): Integer; overload;
function Random(const Arr: array of integer): Integer; overload;
function RandomRange(Range: ARange): Integer;
function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer;


var
  RandomVariable: Integer;

implementation


function slice(Text: String; Delimeter: String): AString;
var
  Index: Integer;
begin
  SetLength(Result, 0);
  Index := Pos(Delimeter, Text);
  while Index <> 0 do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Copy(Text, 1, Index - 1);
    Delete(Text, 1, Index + Length(Delimeter) - 1);
    Index := Pos(Delimeter, Text);
  end;
  if Text <> '' then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Text;
  end;
end;

procedure slice_params(Text: String; Delimeter: String; var Names, Values: AString);
var
  i, PosValue: Integer;
  Arr   : AString;
begin
  Arr := slice(Text, Delimeter);
  SetLength(Names, Length(Arr));
  SetLength(Values, Length(Arr));
  for i:=0 to High(Arr) do
  begin
    PosValue := Pos('=', Arr[i]);
    if PosValue = 0 then
      Names[i] := Arr[i]
    else
    begin
      Names[i] := Copy(Arr[i], 1, PosValue - 1);
      Values[i] := Copy(Arr[i], PosValue + 1, MaxInt);
    end;
  end;
end;

function GetProcAddress(Handle: Integer; FuncName: String): Integer;
begin
  Result := Integer(Windows.GetProcAddress(Handle, PChar(FuncName)));
end;

function StrToInt4(Str: String): Integer;
begin//optimize to asm
  Result := Ord(Str[1]) shl 24 + Ord(Str[2]) shl 16 +
            Ord(Str[3]) shl 8  + Ord(Str[4]);
end;

function IntToStr4(Num: Integer): String;
begin//optimize to asm
  Result := Chr((Num and $FF000000) shr 24) + Chr((Num and $00FF0000) shr 16) +
            Chr((Num and $0000FF00) shr 8)  + Chr((Num and $000000FF));
end;

function FloatToStr8(Num: Double): String;
var N: record
        case byte of
        1: (L, R: Integer);
        2: (X: Double);
        end;
begin//optimize to asm
  N.X := Num;
  Result := IntToStr4(N.L) + IntToStr4(N.R);
end;

function StrToFloat8(Str: String): Double;
var N: record
        case byte of
        1: (L, R: Integer);
        2: (X: Double);
        end;
begin//optimize to asm
  N.L := StrToInt4(Copy(Str, 1, 4));
  N.R := StrToInt4(Copy(Str, 5, 4));
  Result := N.X;
end;

function PosI(Index: Integer; Substr: String; S: String): Integer;
begin
  Delete(S, 1, Index);
  Result := Pos(Substr, S);
  if Result <> 0 then
    Inc(Result, Index)
  else
    Result := High(Integer);
end;

function Index(const Substr: Array of String; Str: String): Integer;
begin
  Result := NextIndex(0, Substr, Str);
end;

function NextIndex(Index: Integer; const Substr: Array of String; Str: String): Integer;
var
  I, PosIndex: Integer;
begin
  Result := High(Integer);
  for I := Low(Substr) to High(Substr) do
  begin
    PosIndex := PosI(Index, Substr[I], Str);
    if PosIndex < Result then
      Result := PosIndex;
  end;
end;

function EncodeStr(Str: String; Position: Integer = 1): String;
var i: Integer;
begin
  Result := Copy(Str, 1, Position - 1);
  for i:=Position to Length(Str) do
    if Str[i] in [#48..#57, #65..#90, #97..#122]  //'@', '^', '.', '?', ':', '=', '&', ';', '#', '|'
    then Result := Result + Str[i]
    else Result := Result + '%' + IntToHex(Ord(Str[i]), 2);
end;

function DecodeStr(Str: String): String;
var
  i: integer;
  ESC: string[2];
  CharCode: integer;
begin
  Result := '';
  i := 1;
  while i <= Length(Str) do
  begin
    if Str[i] <> '%' then
      Result := Result + Str[i]
    else
    begin
      Inc(i);
      ESC := Copy(Str, i, 2);
      Inc(i, 1);
      CharCode := StrToIntDef('$' + ESC, -1);
      if (CharCode >= 0) and (CharCode <= 255) then
        Result := Result + Chr(CharCode);
    end;
    Inc(i);
  end;
end;


function EnumSymbols(SymbolName: PChar; SymbolAddress, SymbolSize: ULONG;
  Strings: Pointer): Bool; stdcall;
begin
  TStrings(Strings).Add(SymbolName);
  Result := True;
end;

function GetFunctionList(const FileName: string; var FuncName: AString): Integer;
var
  hProcess: THandle;
  VersionInfo: TOSVersionInfo;
  Strings: TStrings;
begin
  Result := 0;
  Strings := TStringList.Create;
  SymSetOptions(SYMOPT_UNDNAME or SYMOPT_DEFERRED_LOADS);
  VersionInfo.dwOSVersionInfoSize := SizeOf(VersionInfo);
  if not GetVersionEx(VersionInfo) then Exit;
  if VersionInfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS
  then hProcess := GetCurrentProcessId
  else hProcess := GetCurrentProcess;
  if not SymInitialize(hProcess, nil, True) then Exit;
  try
    Result := LoadLibrary(PChar(FileName));
    if Result = 0 then Exit;
    if not SymLoadModule(hProcess, 0, PChar(FileName), nil, Result, 0) then Exit;
      try if not SymEnumerateSymbols(hProcess, Result, EnumSymbols, Strings) then Exit;
      finally SymUnloadModule(hProcess, Result); end;
  finally
    SymCleanup(hProcess);
    FuncName := slice(Strings.Text, #13#10);
    Strings.Free;
  end;
end;


//NodeUtils
function ToFileSystemName(var Indexes: AString): String;
var          //c:\data\@\1\
  i, j: Integer;
  Index: String;
const
  IllegalCharacters = [#0..#32, '/', '\', ':', '*', '?', '@', '"', '<', '>', '|'];
  IllegalFileNames: array[0..0] of String = ('con') ;
begin
  Result := '';
  for i:=0 to High(Indexes) do
  begin
    Index := Indexes[i];
    if Length(Index) = 1 then
    begin
      if Index[1] in IllegalCharacters then
        Indexes[i] := IntToHex(Ord(Index[1]), 2);
    end
    else
    begin
      for j:=0 to High(IllegalFileNames) do
        if Index = IllegalFileNames[i] then
          Indexes[i] := Indexes[i] + '1';
    end;
    Result := Indexes[i] + '\' + Result;
  end;
end;


function CreateDir(Indexes: AString): String;
var i: Integer;  //c:\data\@\1\
begin
  Result := '';
  for i:=High(Indexes) downto 0 do
  begin
    Result := Result + Indexes[i];
    SysUtils.CreateDir(Result);
    Result := Result + '\';
  end;
end;

function SaveToFile(FileName: String; var Data: String): Integer;
var OutFile: TextFile;
begin
  AssignFile(OutFile, FileName);
  Rewrite(OutFile);
  WriteLn(OutFile, Data);
  CloseFile(OutFile);
end;

function LoadFromFile(FileName: String): String;
var
  InFile: TextFile;
  Buf: String;
begin
  Result := '';
  if FileExists(FileName) then
  begin
    AssignFile(InFile, FileName);
    Reset(InFile);
    while not Eof(InFile) do
    begin
      Readln(InFile, Buf);
      Result := Result + Buf + #10;
    end;
    CloseFile(InFile);
  end;
end;


function Random(Range: Integer): Integer; overload;
begin
  Inc(RandomVariable);
  if Range = 0 then
    Result := 0
  else
    Result := RandomVariable mod Range;
end;

function Random(Arr: AInteger; var InnerIndex: Integer): Integer;  overload;
var i: Integer;
begin
  InnerIndex := Random(MaxInt) mod SumInt(Arr);
  for i:=0 to High(Arr) do
  begin
    if InnerIndex - Arr[i] < 0 then
    begin
      Result := i;
      Exit;
    end;
    InnerIndex := InnerIndex - Arr[i];
  end;
end;

function Random(Arr: AInteger): Integer; overload;
var InnerIndex: Integer;
begin
  Result := Random(Arr, InnerIndex);
end;

function RandomRange(Range: ARange): Integer;
var
  MaxRange, MinRange: Integer;
  BeginRange, CenterRange, EndRange: Integer;
begin
  BeginRange  := Range[0];
  CenterRange := Range[1];
  EndRange    := Range[2];
  repeat
    MaxRange := Max(CenterRange - BeginRange, EndRange - CenterRange);
    //MinRange := Min(CenterRange - BeginRange, EndRange - CenterRange);
    Result := Round(Tan(PI * (Random(MaxInt) / MaxInt - 0.5)));
    Result := Result mod (MaxRange + 1);
    Result := Result + CenterRange;
  until (Result >= BeginRange) and (Result <= EndRange);
end;

function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function Random(const Arr: array of integer): Integer; overload;
var
  i, InnerIndex: Integer;
  DynArr: AInteger;
begin
  SetLength(DynArr, Length(Arr));
  for i := 0{Low(Arr)} to High(Arr) do
    DynArr[i] := Arr[i];
  Result := Random(DynArr, InnerIndex);
  SetLength(DynArr, 0);
end;



initialization
  RandomVariable := 1;
end.
