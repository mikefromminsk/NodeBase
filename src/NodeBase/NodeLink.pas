unit NodeLink;

// ver 3


interface

uses
  SysUtils, NodeUtils, Classes, Dialogs;

const
  sID = '@';
  sSource = '^';
  sVars = '$';
  sType = ':';
  sParams = '?';
  sParamValue = '=';
  sParamAnd = '&';
  sParamEnd = ';';
  sValue = '#';
  sTrue = '>';
  sFalse = '|';
  sNext = #10;
  sLocal = #10#10;

  sFile = '/';
  sData = '!';


type

  TLink = class
  public
    Source      : TLink;
    Name        : String;
    ID          : String;
    Names       : Array of String;
    Values      : Array of String;
    FType       : TLink;
    Params      : Array of TLink;
    Value       : TLink;
    FElse       : TLink;
    Next        : TLink;
    Local       : Array of TLink;

    constructor Create(Str: string);
    constructor RecParse(Str: String);   //рекурсивную для пользователя
    constructor BaseParse(Str: String);  //более простую для базы
    destructor Destroy;
  end;

implementation



constructor TLink.Create(Str: string);
begin
  ID := Str;
end;

//Name@ID^Source$Names=Values:FType?Params#Value>FTrue|FElse
//Next
//
//Local
constructor TLink.BaseParse(Str: String);
const
  Count = 10;
  SysChars: array[1..Count] of String =
    (sID, sSource, sVars, sType, sParams, sValue, sTrue, sFalse, sNext, sLocal);
var
  i, Start: Integer;
  Indexes: array[1..Count + 1] of Integer;
  Strings: array[0..Count] of String;
begin
  Indexes[High(Indexes)] := Length(Str) + 1;

  for i:=1 to Count do
    Indexes[i] := Pos(SysChars[i], Str);

  for i:=1 to Count do
    if Indexes[i] <> 0 then
    begin
      Start := i;
      Strings[0] := Copy(Str, 0, Indexes[i] - Length(SysChars[i]));
      Break;
    end;

  for i:=Start to Count do
    if Indexes[i] = 0 then
      Indexes[i] := Indexes[i + 1];

  for i:=Start to Count do
    Strings[i] := Copy(Str, Indexes[i] + Length(SysChars[i]), Indexes[i + 1] - (Indexes[i] + Length(SysChars[i])));
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















