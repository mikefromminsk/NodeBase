unit NodeLink;

// ver 3


interface

uses
  SysUtils, NodeUtils, Classes, Dialogs;

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
    Names       : Array of String;
    Values      : Array of String;
    FType       : TLink;
    Params      : Array of TLink;
    Value       : TLink;
    FTrue       : TLink;
    FElse       : TLink;
    Next        : TLink;
    Local       : Array of TLink;

    constructor Create(Str: string);
    constructor UserParse(Str: String);  //рекурсивную для пользователя
    constructor BaseParse(Str: String);  //более простую для базы
    destructor Destroy;
  end;

implementation



constructor TLink.Create(Str: string);
begin
  ID := Str;
end;

function ToStrings(Str: string): CString;
var
  i, Start: Integer;
  Indexes: array[1..Count + 1] of Integer;
begin
  Indexes[High(Indexes)] := Length(Str) + 1;
  for i:=1 to Count do
    Indexes[i] := Pos(SysChars[i], Str);
  for i:=1 to Count do
    if Indexes[i] <> 0 then
    begin
      Start := i;
      Result[0] := Copy(Str, 0, Indexes[i] - Length(SysChars[i]));
      Break;
    end;
  for i:=Count downto Start do
    if Indexes[i] = 0 then
      Indexes[i] := Indexes[i + 1];
  for i:=Start to Count do
    Result[i] := Copy(Str, Indexes[i] + Length(SysChars[i]), Indexes[i + 1] - (Indexes[i] + Length(SysChars[i])));
end;

constructor TLink.BaseParse(Str: String);
//Name@ID^Source$Names=Values:FType?Params#Value>FTrue|FElse
//Next
//
//Local
var
  i, PosValue: Integer;
  Strings: CString;
  Arr   : AString;
begin
  Strings := ToStrings(Str);

  Name := Strings[iName];
  ID   := Strings[iID];
  if Strings[iSource] <> '' then
    Source  := TLink.Create(Strings[iSource]);
  if Strings[iVars] <> '' then
  begin
    Arr := slice(Strings[iVars], '&');
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
  if Strings[iType] <> '' then
    FType := TLink.Create(Strings[iType]);
  if Strings[iParams] <> '' then
  begin
    Arr := slice(Strings[iParams], '&');
    SetLength(Params, Length(Arr));
    for i:=0 to High(Arr) do
      Params[i] := TLink.Create(Arr[i]);
  end;
  if Strings[iValue] <> '' then
    Value := TLink.Create(Strings[iValue]);
  if Strings[iTrue] <> '' then
    FTrue := TLink.Create(Strings[iTrue]);
  if Strings[iElse] <> '' then
    FElse := TLink.Create(Strings[iElse]);
  if Strings[iNext] <> '' then
    Next  := TLink.Create(Strings[iNext]);
  if Strings[iLocal] <> '' then
  begin
    Arr := slice(Strings[iLocal], #10#10);
    SetLength(Local, Length(Arr));
    for i:=0 to High(Arr) do
      Local[i] := TLink.Create(Arr[i]);
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

  if Pos(sParamValue, Str) < Pos(sParams, Str) then


  Strings := ToStrings(Str);

  Name := Strings[iName];
  ID   := Strings[iID];
  if Strings[iSource] <> '' then
    Source  := TLink.Create(Strings[iSource]);
  if Strings[iVars] <> '' then
  begin
    Arr := slice(Strings[iVars], '&');
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
  if Strings[iType] <> '' then
    FType := TLink.Create(Strings[iType]);
  if Strings[iParams] <> '' then
  begin
    Arr := slice(Strings[iParams], '&');
    SetLength(Params, Length(Arr));
    for i:=0 to High(Arr) do
      Params[i] := TLink.Create(Arr[i]);
  end;
  if Strings[iValue] <> '' then
    Value := TLink.Create(Strings[iValue]);
  if Strings[iTrue] <> '' then
    FTrue := TLink.Create(Strings[iTrue]);
  if Strings[iElse] <> '' then
    FElse := TLink.Create(Strings[iElse]);
  if Strings[iNext] <> '' then
    Next  := TLink.Create(Strings[iNext]);
  if Strings[iLocal] <> '' then
  begin
    Arr := slice(Strings[iLocal], #10#10);
    SetLength(Local, Length(Arr));
    for i:=0 to High(Arr) do
      Local[i] := TLink.Create(Arr[i]);
  end;
end;

destructor TLink.Destroy;
var i: Integer;
begin
  if Source <> nil then
    Source.Destroy;
  if FType <> nil then
    FType.Destroy;
  for i:=0 to High(Params) do
    if Params[i] <> nil then
      Params[i].Destroy;
  if Value <> nil then
    Value.Destroy;
  if FElse <> nil then
    FElse.Destroy;
  if Next <> nil then
    Next.Destroy;
  for i:=0 to High(Local) do
    if Local[i] <> nil then
      Local[i].Destroy;
  inherited Destroy;
end;

end.















