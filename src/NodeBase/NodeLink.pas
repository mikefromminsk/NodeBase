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
    constructor FastParse(Str: String);  //более простую для базы
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
constructor TLink.RecParse(Str: String);
const
  Count = 10;
  SysChars: array[1..Count] of String =
    (sID, sSource, sVars, sType, sParams, sValue, sTrue, sFalse, sNext, sLocal);
var
  i: Integer;
  Indexes: array[1..Count + 1] of Integer;
  Strings: array[0..Count] of String;
begin
  Indexes[High(Indexes)] := Length(Str) + 1;

  for i:=1 to Count do
    Indexes[i] := Pos(SysChars[i], Str);

  for i:=1 to Count do
    if Indexes[i] = 0 then
      Indexes[i] := Indexes[i + 1];

  Strings[0] := Copy(Str, 0, Indexes[1] - Length(SysChars[1]));
  for i:=1 to Count do
    Strings[i] := Copy(Str, Indexes[i] + Length(SysChars[i]), Indexes[i + 1] - (Indexes[i] + Length(SysChars[i])));
  ShowMessage('1');
end;








constructor TLink.FastParse(Str: String);
//Source^Name@ID$Names=Values:FType?Params#Value|FElse
//Next
//
//Local
var
  i, j, Index_Source, Index_ID, Index_Controls, Index_FType, Index_Params,
  Index_Value, Index_Felse, Index_Next, Index_Local: Integer;
  ControlsStr, ParamsStr, ValueStr, FElseStr, LocalStr: String;
  Chr: Char;
begin

  Index_Source   := 0;
  Index_ID       := 0;
  Index_Controls := 0;
  Index_FType    := 0;
  Index_Params   := 0;
  Index_Value    := 0;
  Index_Felse    := 0;
  Index_Next     := 0;
  Index_Local    := 0;

  //реализация быстрого поиска индексов
  for i:=1 to Length(Str) do
  begin
    Chr := Str[i];
    if Chr = '@' then
      Index_ID := i
    else
      if Chr = '^' then     //последовательность ифов по вероятности встречаемости
        Index_Source := i
      else
        if Chr = '$' then
          Index_Controls := i
        else
          if Chr = '?' then
            Index_Params := i
          else
            if Chr = '#' then
              Index_Value := i
            else
              if Chr = '|' then
                Index_Felse := i
              else
                if Chr = ':' then
                  Index_FType := i
                else
                  if Chr = #10 then
                  begin
                    Index_Next := i;
                    Break;
                  end;
  end;

  if Index_ID = 0 then  //Подразумевается что в первой строке есть символ @
  begin
    RecParse(Str);
    Exit;
  end;

  if Index_Next <> 0 then
    for i:=Index_Next to Length(Str) - 1 do
      if (Str[i] = #10) and (Str[i + 1] = #10) then
      begin
        Index_Local := i;
        Break;
      end;


  //реализация быстрой записи в переменные
  //перечислим все возможные ситуации не используя математические операции
  // Парсим с начала  parent^name@
  if Index_Source <> 0 then
  begin
    Source := TLink.Create(Copy(Str, 1, Index_Source - 1));
    Name := Copy(Str, Index_Source + 1, Index_ID - Index_Source - 1);
  end
  else
  begin
    Name := Copy(Str, 1, Index_ID - 1);
  end;

  // Парсим с конца  @id$controls?params#value|else
  //блоки аналогичные в блоках else нужно заменить переменную ифа на переменную верхнего ифа


  {if Index_Local <> 0 then
  begin
    LocalStr := Copy(Str, Index_Local + 2, MaxInt);
    if Index_Next <> 0 then
    begin
      Next := Copy(Str, Index_Next + 1, Index_Local - Index_Next - 1);
      if Index_Felse <> 0 then
      begin
        FElseStr := Copy(Str, Index_Felse + 1, Index_Next - Index_Felse - 1);
        if Index_Value <> 0 then
        begin
          ValueStr := Copy(Str, Index_Value + 1, Index_Felse - Index_Value - 1);
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FType := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              }

  //Обрабатываем полученные строки
  
  ID := '@' + ID; //hardcode

  if ControlsStr <> '' then
  begin
    Index_Controls := 1;
    for i:=1 to Length(ControlsStr) do
      if ControlsStr[i] = '&' then
      begin
        SetLength(Names, Length(Names) + 1);
        SetLength(Values, Length(Values) + 1);
        for j:=Index_Controls to i - 1 do
          if ControlsStr[j] = '=' then
          begin
            Names[High(Names)] := Copy(ControlsStr, Index_Controls, j - Index_Controls);
            Values[High(Values)] := Copy(ControlsStr, j + 1, i - j - 1);
            Break;
          end;
        if j <> i - 1 then
          Names[High(Names)] := Copy(ControlsStr, Index_Controls, i - j - 1);
        Index_Controls := i + 1;
      end;
    if i <> Length(ControlsStr) then
    begin
      SetLength(Names, Length(Names) + 1);
      SetLength(Values, Length(Values) + 1);
      for j:=Index_Controls to i - 1 do
        if ControlsStr[j] = '=' then
        begin
          Names[High(Names)] := Copy(ControlsStr, Index_Controls, j - Index_Controls);
          Values[High(Values)] := Copy(ControlsStr, j + 1, MaxInt);
          Break;
        end;
      if j <> i - 1 then
        Names[High(Names)] := Copy(ControlsStr, Index_Controls, MaxInt);
    end;
  end;

  if ParamsStr <> '' then
  begin
    Index_Params := 1;
    for i:=1 to Length(ParamsStr) - 1 do
      if ParamsStr[i] = '&' then
      begin
        SetLength(Params, Length(Params) + 1);
        Params[High(Params)] := TLink.Create(Copy(ParamsStr, Index_Params, i - Index_Params));
        Index_Params := i + 1;
      end;
    if Index_Params <> Length(ParamsStr) then
    begin
      SetLength(Params, Length(Params) + 1);
      Params[High(Params)] := TLink.Create(Copy(ParamsStr, Index_Params, MaxInt));
    end;
  end;

  if ValueStr <> '' then
    Value := TLink.Create(ValueStr);

  if FElseStr <> '' then
    FElse := TLink.Create(FElseStr);

  if LocalStr <> '' then
  begin
    Index_Local := 1;
    for i:=1{3} to Length(LocalStr) - 1{4} do
      if (LocalStr[i] = #10) and (LocalStr[i + 1] = #10) then
      begin
        SetLength(Local, Length(Local) + 1);
        Local[High(Local)] := TLink.Create(Copy(LocalStr, Index_Local,  i - Index_Local));
        Index_Local := i + 2;
      end;
    if Index_Local <> Length(LocalStr) then
    begin
      SetLength(Local, Length(Local) + 1);
      Local[High(Local)] := TLink.Create(Copy(LocalStr, Index_Local,  MaxInt));
    end;
  end;

end;


destructor TLink.Destroy;
var i: Integer;
begin
  for i:=0 to High(Params) do
    if Params[i] <> nil then
      Params[i].Destroy;
  if Value <> nil then
    Value.Destroy;
  inherited Destroy;
end;








end.















