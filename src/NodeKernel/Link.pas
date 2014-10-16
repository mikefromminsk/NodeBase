unit Link;

// ver 3


interface

uses
  SysUtils, Utils, Classes, Dialogs;

const
  sID         = '@';
  sSource     = '^';
  sVars       = '$';
  sType       = ':';
  sParams     = '?';
  sParamValue = '=';
  sParamAnd   = '&';
  sParamEnd   = ';';
  sValue      = '#';
  sTrue       = '>';
  sElse       = '|';
  sNext       = #10;
  sLocal      = #10#10;

  sFile = '/';
  sData = '!';
  sDecimalSeparator = ',';

  Count = 10;
  SysChars: array[1..Count] of String =
    (sID, sSource, sVars, sType, sParams, sValue, sTrue, sElse, sNext, sLocal);
    
  iName    = 0;
  iID      = 1;
  iSource  = 2;
  iVars    = 3;
  iType    = 4;
  iParams  = 5;
  iValue   = 6;
  iTrue    = 7;
  iElse    = 8;
  iNext    = 9;
  iLocal   = 10;

type

  CString = array[0..Count] of String;

  TLink = class
  public

    Name        : String;
    ID          : String;
    Source      : TLink;
    Vars        : TMap;
    FType       : TLink;
    Params      : Array of TLink;
    Value       : TLink;
    FTrue       : TLink;
    FElse       : TLink;
    Next        : TLink;
    Local       : Array of TLink;
    constructor Create; overload;
    constructor Create(Str: string); overload;
    constructor UserParse(Str: String);  //рекурсивную для пользователя
    procedure rec(var Str: String; Link: TLink);
    constructor BaseParse(Str: String);  //более простую для базы
    destructor Destroy; override;
  end;

implementation

constructor TLink.Create;
begin
  Vars := TMap.Create;
end;

constructor TLink.Create(Str: string);
begin
  ID := Str;
end;

function ToStrings(Str: string): CString;
var
  i, NameEnd: Integer;
  Indexes: array[1..Count + 1] of Integer;
begin
  NameEnd := 1;
  Indexes[High(Indexes)] := Length(Str) + 1;
  for i:=1 to Count do
    Indexes[i] := Pos(SysChars[i], Str);
  for i:=1 to Count do
    if Indexes[i] <> 0 then
    begin
      NameEnd := i;
      Break;
    end;
  for i:=Count downto NameEnd do
    if Indexes[i] = 0 then
      Indexes[i] := Indexes[i + 1]
    else if Indexes[i] > Indexes[i + 1] then
      Indexes[i] := Indexes[i + 1];
  Result[0] := Copy(Str, 1, Indexes[NameEnd] - Length(SysChars[NameEnd]));
  for i:=NameEnd to Count do
    Result[i] := Copy(Str, Indexes[i] + Length(SysChars[i]), Indexes[i + 1] - (Indexes[i] + Length(SysChars[i])));
end;

constructor TLink.BaseParse(Str: String);
//Name@ID^Source$Names=Values:FType?Params#Value>FTrue|FElse
//Next
//
//Local
var
  i: Integer;
  Strings: CString;
  Arr   : AString;
begin
  Create;
  Strings := ToStrings(Str);

  Name := Strings[iName];
  ID   := Strings[iID];
  if Strings[iSource] <> '' then
    Source  := TLink.BaseParse(Strings[iSource]);
  if Strings[iVars] <> '' then
    Vars := TMap.Create(AnsiUpperCase(Strings[iVars]), sParamAnd);
  if Strings[iType] <> '' then
    FType := TLink.BaseParse(Strings[iType]);
  if Strings[iParams] <> '' then
  begin
    Arr := slice(Strings[iParams], sParamAnd);
    SetLength(Params, Length(Arr));
    for i:=0 to High(Arr) do
      Params[i] := TLink.BaseParse(Arr[i]);
  end;
  if Strings[iValue] <> '' then
    Value := TLink.BaseParse(Strings[iValue]);
  if Strings[iTrue] <> '' then
    FTrue := TLink.BaseParse(Strings[iTrue]);
  if Strings[iElse] <> '' then
    FElse := TLink.BaseParse(Strings[iElse]);
  if Strings[iNext] <> '' then
    Next  := TLink.BaseParse(Strings[iNext]);
  if Strings[iLocal] <> '' then
  begin
    Arr := slice(Strings[iLocal], sLocal);
    SetLength(Local, Length(Arr));
    for i:=0 to High(Arr) do
      Local[i] := TLink.BaseParse(Arr[i]);
  end;
end;

procedure TLink.rec(var Str: String; Link: TLink);
var
  PosMin: Integer;
  Name: String;
  SysChar: Char;
begin
  while Str <> '' do
  begin
    PosMin := Index([sParams, sParamAnd, sParamEnd], Str);
    if PosMin = MaxInt
    then SysChar := #0
    else SysChar := Str[PosMin];
    Name := Copy(Str, 1, PosMin - 1);
    SetLength(Link.Params, Length(Link.Params) + 1);
    Link.Params[High(Link.Params)] := TLink.UserParse(Name);
    Delete(Str, 1, PosMin);
    case SysChar of
      sParams:   rec(Str, Link.Params[High(Link.Params)]);
      sParamEnd: Exit;
    end;
  end;
end;

constructor TLink.UserParse(Str: String);
//Name@ID^Source$Names=Values:FType?Params#Value>FTrue|FElse
//Next
//
//Local
var
  i, PosValue: Integer;
  Strings: CString;
  Arr   : AString;
begin
  Create;
  PosValue := Pos(sParamValue, Str);
  i := Pos(sParams, Str);
  if ((PosValue <> 0) and (i = 0)) or
     ((PosValue <> 0) and (i <> 0) and (PosValue < i)) then
    Str[PosValue] := sValue;

  Strings := ToStrings(Str);

  Name := Strings[iName];
  ID   := Strings[iID];
  if Strings[iSource] <> '' then
    Source  := TLink.UserParse(Strings[iSource]);
  if Strings[iVars] <> '' then
    Vars := TMap.Create(AnsiUpperCase(Strings[iVars]), sParamAnd);
  if Strings[iType] <> '' then
    FType := TLink.UserParse(Strings[iType]);
  if Strings[iParams] <> '' then
    rec(Strings[iParams], Self);
  if Strings[iValue] <> '' then
    Value := TLink.UserParse(Strings[iValue]);
  if Strings[iTrue] <> '' then
    FTrue := TLink.UserParse(Strings[iTrue]);
  if Strings[iElse] <> '' then
    FElse := TLink.UserParse(Strings[iElse]);
  if Strings[iNext] <> '' then
    Next  := TLink.UserParse(Strings[iNext]);
  if Strings[iLocal] <> '' then
  begin
    Arr := slice(Strings[iLocal], sLocal);
    SetLength(Local, Length(Arr));
    for i:=0 to High(Arr) do
      Local[i] := TLink.UserParse(Arr[i]);
  end;
end;

destructor TLink.Destroy;
var i: Integer;
begin
  FreeAndNil(Source);
  FreeAndNil(Vars);
  FreeAndNil(FType);
  for i:=0 to High(Params) do
    FreeAndNil(Params[i]);
  FreeAndNil(Value);
  FreeAndNil(FElse);
  FreeAndNil(Next);
  for i:=0 to High(Local) do
    FreeAndNil(Local[i]);
end;

end.
