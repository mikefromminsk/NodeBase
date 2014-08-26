unit NodeUtils;

interface

uses
  Windows, ImageHlp, Classes, SysUtils, StrUtils, Math, Dialogs, ExtCtrls,
  Messages;

type
  RunThread = class(TThread)
  public
    Node: Pointer;
    procedure Execute; override;
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

  MTimerList = class
  public
    TimerList: TList;
    constructor Create();
    procedure CallOnTimer(Sender : TObject);
    procedure Add(Handle: Integer; TimeOfLife: Cardinal);
  end;


function IntToStr4(Num: Integer): String;
function StrToInt4(Str: String): Integer;
function FloatToStr8(Num: Double): String;
function StrToFloat8(Str: String): Double;
function EncodeName(Str: String; Position: Integer = 1): String;
function DecodeName(Str: String): String;
function PosI(Index: Integer; Substr: String; S: String): Integer;
function NextIndex(Index: Integer; const Substr: array of string; S: String): Integer;
function GetImageFunctionList(const FileName: string; Strings: TStrings): Integer;
function GetProcAddress(Handle: Integer; FuncName: String): Integer;
function CopyMem(S: String; Index, Count: Integer): String;
function PosMem(Index: Integer; SubStr, S: String): Integer;
function CutString(var Str: String; Mask: String): String;
procedure WaitThread(Handle: Integer; Time: Cardinal);
procedure RunInThread(Node: Pointer);

var
  TimerList: MTimerList;

implementation

uses
  NodeBaseKernel;


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

function NextIndex(Index: Integer; const Substr: array of string; S: String): Integer;
var
  I, PosIndex: Integer;
begin
  Result := High(Integer);
  for I := Low(Substr) to High(Substr) do
  begin
    PosIndex := PosI(Index, Substr[I], S);
    if PosIndex < Result then
      Result := PosIndex;
  end;
end;

function EncodeName(Str: String; Position: Integer = 1): String;
var i: Integer;
begin
  Result := Copy(Str, 1, Position - 1);
  for i:=Position to Length(Str) do
    if Str[i] in [#48..#57, #65..#90, #97..#122]  //'@', '^', '.', '?', ':', '=', '&', ';', '#', '|'
    then Result := Result + Str[i]
    else Result := Result + '%' + IntToHex(Ord(Str[i]), 2);
end;

function DecodeName(Str: String): String;
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

function GetImageFunctionList(const FileName: string; Strings: TStrings): Integer;
var
  hProcess: THandle;
  VersionInfo: TOSVersionInfo;
begin
  Strings.Clear;
  Result := 0;
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
  finally SymCleanup(hProcess); end;
end;



procedure RunThread.Execute;
begin
  if Node <> nil then
    Base.Run(Node);
end;

constructor RunThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := True;
  Node := nil;
end;

destructor RunThread.Destroy;
begin
  inherited Destroy;
end;

procedure RunInThread(Node: Pointer);
var Thread: RunThread;
begin
  Thread := RunThread.Create();
  Thread.Node := Node;
  Thread.Resume;
  WaitThread(Thread.Handle, 1000);
end;

constructor MTimerList.Create();
begin
  TimerList := TList.Create;
end;

procedure WaitThread(Handle: Integer; Time: Cardinal);
begin
  WaitForSingleObject(Handle, Time);
end;

procedure MTimerList.CallOnTimer(Sender : TObject);
var Code: Cardinal;
begin
  if (GetExitCodeThread((Sender as TTimer).Tag, Code)) and (Code = STILL_ACTIVE) then
    TerminateThread((Sender as TTimer).Tag, 0);
  TimerList.Delete(TimerList.IndexOf(Sender as TTimer));
  (Sender as TTimer).Free;
end;

procedure MTimerList.Add(Handle: Integer; TimeOfLife: Cardinal);
var Timer: TTimer;
begin
  Timer := TTimer.Create(nil);
  Timer.Tag := Handle;
  Timer.OnTimer := CallOnTimer;
  Timer.Interval := TimeOfLife;
  TimerList.Add(Timer);
  Timer.Enabled := True;
end;



function PosMem(Index: Integer; SubStr, S: String): Integer;
var
  i, j: Integer;
begin
  if Index < 1 then
    Index := 1;
  if Index <= Length(S) then
  if Length(SubStr) > 0 then
  for i:=Index to Length(S) do
    if S[i] = SubStr[1] then
    begin
      Result := i;
      for j:=1 to Length(SubStr) do
        if S[i+j-2] <> SubStr[j] then
          Break;
      if j = Length(SubStr) then
        Exit;
    end;
  Result := 0;
end;

function CopyMem(S: String; Index, Count: Integer): String;
var
  i, Len: Integer;
begin
  Len := Length(S);
  if Index < 1 then
    Index := 1;
  if Count = High(Integer) then
    Count := High(Integer) - Index + 1;
  if Index <= Len then
  for i:=Index to Index+Count-1 do
    if i <= Len then
      Result := Result + S[i]
    else
      Break;
end;

function CutString(var Str: String; Mask: String): String;
var
  LMask, RMask: String;
  Index, Count: Integer;
  LTag, RTag: String;
  PosLTag, PosRTag: Integer;
  PosDelim: Integer;
begin
  Result := '';
  if Mask = '' then Exit;
  Result := Str;
  if PosMem(1, '*', Mask) = 0 then
  begin
    Mask := '*' + Mask;
    PosDelim := 1;
  end
  else
    PosDelim := PosMem(1, '*', Mask);
  LMask := Copy(Mask, 1, PosDelim-1);
  RMask := Copy(Mask, PosDelim + 1, High(Integer));
  Index := StrToIntDef(LMask, Low(Integer));
  Count := StrToIntDef(RMask, High(Integer));
  LTag := IfThen(Index = Low(Integer), LMask);
  RTag := IfThen(Count = High(Integer), RMask);
  PosLTag := PosMem(1, LTag, Result);
  PosRTag := PosMem(PosLTag, RTag, Result);
  if PosRTag = 0 then
    PosRTag := High(Integer);
  Delete(Str, Max(Max(Index, PosLTag),1), Min(Count, PosRTag));
  if PosLTag <> 0 then
    Inc(PosLTag, Length(LTag));
  if PosRTag <> 0 then
    Dec(PosRTag, Length(RTag));
  Result := CopyMem(Result, Max(Index, PosLTag), Min(Count, PosRTag));
end;

initialization
  TimerList := MTimerList.Create;
end.

