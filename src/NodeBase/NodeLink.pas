unit NodeLink;

  // ver 1.0


interface

uses
  SysUtils, NodeUtils, Classes;

type

  //Set of illegal characters
  //Set of filename reserved characters
  AString = array of String;

  TLink = class
  public
    ID        : String;
    Path        : Array of String;
    Name : String;
    Source      : String;
    Names       : Array of String;      //Controls | vars
    Values      : Array of String;
    FType       : TLink;                //TLink_or_String?
    Local       : Array of String;      //todo to TLink
    Params      : Array of TLink;
    Value       : TLink;
    FElse       : TLink;
    Next        : String;
    constructor Create(LURI: String);
    constructor RecParse(var LURI: String; FirstRun: Boolean = False);
    destructor Destroy;
  end;


implementation

uses Math;

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


constructor TLink.Create(LURI: string);
begin
  RecParse(LURI, True);
end;

                                                         //потокова€ обработка ссылок
constructor TLink.RecParse(var LURI: String; FirstRun: Boolean = False);   //рекурсивную дл€ пользовател€
//Source^Name@ID$Names=Values:FType?Params#Value|FElse
//Next
//
//Local

//Error Value !%12 dont load
var
  s, LS, Str: string;
  Index, i: Integer;
  Arr: AString;
begin
  if Length(LURI) = 0 then Exit;                               //выход если пусто
  ID := '';
  s := ''; LS := ''; Str := '';

  while LURI[Length(LURI)] = #10 do
    Delete(LURI, Length(LURI), 1);

  Index := NextIndex(0, [#10#10], LURI);    //Local
  if Index <> MaxInt then
  begin
    LS := Copy(LURI, Index + 2, MaxInt);
    Delete(LURI, Index, MaxInt);
  end;
  while Length(LS) > 0 do
  begin
    Index := NextIndex(0, [#10#10], LS);
    s := Copy(LS, 1, Index-1);
    SetLength(Local, Length(Local) + 1);
    Local[High(Local)] := s;
    if Index = MaxInt then
      LS := '';    
    Delete(LS, 1, Index + 1);
  end;


  Index := NextIndex(0, [#10], LURI);
  if (Index <> MaxInt) and (Index <> Length(LURI)) then
  begin
    Next := Copy(LURI, Index + 1, MaxInt);  //Next
    Delete(LURI, Index, MaxInt);
  end;

  Index := NextIndex(0, ['$', '?', ':', '=', '&', ';', '#', '|'], LURI);     //в пор€дке веро€тности


  if Index > 1 then
  begin
    ID := Copy(LURI, 1, Index - 1);    //ID
    Source := Copy(ID, 1, Pos('^', ID) - 1);                      //Source
    Delete(ID, 1, Pos('^', ID));
    if Length(ID) > 0 then
    begin
      Name := Copy(ID, 1, Pos('@', ID) - 1);               //Name
      Delete(ID, 1, Pos('@', ID)-1);
    end;
    Delete(LURI, 1, Index-1);
    if NextIndex(0, ['\', '/'], ID) <> MaxInt then               //обработка до функции
    begin
      for i:=0 to Length(ID) do                                  //del
        if ID[i] = '\' then
          ID[i] := '/';
      if not (ID[1] in ['\', '/']) then
        ID := '/' + ID;
      SetLength(Path, 1);
      Path[0] := ID;                                              //Path
    end;
    if ID[1] = '!' then
    begin                                                          //?
      SetLength(Path, 1);
      Path[0] := ID;
    end;

    if Length(LURI) = 0 then Exit;                                //?
  end;
                                                  //отрезали всЄ до управл€ющего символа
  if LURI[1] = '|' then                             //обработка else в верхней функции
  begin
    Exit;
  end;

  if LURI[1] = '$' then                                  //vars
  begin
    Delete(LURI, 1, 1);

    Index := NextIndex(0, [':', '?', '#'], LURI);
    s := Copy(LURI, 1, Index - 1);
    Delete(LURI, 1, Index -1);
    Arr := slice(s, '&');
    for i:=0 to High(Arr) do
    begin
      SetLength(Names, Length(Names) + 1);
      SetLength(Values, Length(Values) + 1);
      Index := NextIndex(0, ['='], Arr[i]);
      Names[High(Names)] := Copy(Arr[i], 1, Index -1);
      if Index <> MaxInt then
        Values[High(Values)] := Copy(Arr[i], Index +1, MaxInt);
    end;

    Index := NextIndex(0, ['?', ':', '=', '&', ';', '#', '|'], LURI);
    if (Index = MaxInt) then
      Exit;
  end;

  if LURI[1] = ':' then                           //FType
  begin
    Delete(LURI, 1, 1);
    Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

    if Index = MaxInt then                     //нету управл€ющих символов
    begin
      FType := TLink.RecParse(LURI);
      Delete(LURI, 1, Length(LURI));
    end
    else
    if LURI[Index] = '=' then
    begin
      s := Copy(LURI, 1, Index-1);
      FType := TLink.RecParse(s);
      Delete(LURI, 1, Index);
      Value := TLink.RecParse(LURI);          //следующее значение
    end
    else
    begin
      if Length(LURI) > 0 then                 //дальше функци€
        FType := TLink.RecParse(LURI);
    end;
    Exit;
  end;

  if LURI[1] = '=' then
  begin
    Delete(LURI, 1, 1);
    {Index := NextIndex(0, ['&', '#'], LURI);
    s := Copy(LURI, 1, Index-1);
    Delete(LURI, 1, Index-1);}
    Value := TLink.RecParse(LURI);
    Exit;
  end;

  if LURI[1] = ';' then
  begin
    Delete(LURI, 1, 1);
    Exit;
  end;


  if LURI[1] = '?' then
  begin
    Delete(LURI, 1, 1);
    repeat
      Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

      if (Index = MaxInt) or (LURI[Index] = ';') then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLink.RecParse(s);
        end
        else
          Break;
        Exit;
      end;

      if LURI[Index] in [':', '='] then
      begin
        SetLength(Params, High(Params)+2);
        Params[High(Params)] := TLink.RecParse(LURI);
        Continue;
      end;

      if LURI[Index] = '&' then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLink.RecParse(s);
        end;
        Continue;
      end;

      if LURI[Index] = '#' then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index-1);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLink.RecParse(s);
        end;
        Break;
      end;

      if LURI[Index] = '?' then
      begin
        SetLength(Params, High(Params)+2);
        Params[High(Params)] := TLink.RecParse(LURI);
      end;

    until False;
  end;

  if (Length(LURI) > 0) and (LURI[1] = '#') and (FirstRun = True) then
  begin
    Delete(LURI, 1, 1);
    Value := TLink.RecParse(LURI);
  end;

  if (Length(LURI) > 0) and (LURI[1] = '|') then
  begin
    Delete(LURI, 1, 1);
    FElse := TLink.RecParse(LURI);
  end;
end;


procedure FastParse(var Str: String);  //более простую дл€ базы
//Source^Name@Id$controls[not Ftype]?Params#Value|FElse
var
  i, Index_Source, Index_ID, Index_Controls, Index_Params, Index_Value, Index_Felse: Integer;
  SourceStr, NameStr, IdStr, Controls, ParamsStr, ValueStr, FElseStr: String;
  Chr: Char;
begin

  Index_Source   := 0;
  //Index_ID       := 0;
  Index_Controls := 0;
  Index_Params   := 0;
  Index_Value    := 0;
  Index_Felse    := 0;

  //реализаци€ быстрого поиска индексов
  for i:=1 to Length(Str) do
  begin
    Chr := Str[i];
    if Chr = '@' then
      Index_ID := i
    else
      if Chr = '^' then     //последовательность ифов по веро€тности встречаемости
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
              begin
                Index_Felse := i;
                Break;
              end;
  end;


  //реализаци€ быстрой записи в переменные
  //перечислим все возможные ситуации не использу€ математические операции
  // ѕарсим с начала  parent^name@
  if Index_Source <> 0 then
  begin
    SourceStr := Copy(Str, 1, Index_Source - 1);
    NameStr := Copy(Str, Index_Source - 1, Index_ID - Index_Source - 1);
  end
  else
  begin
    NameStr := Copy(Str, 1, Index_ID - 1);
  end;

  // ѕарсим с конца  @id$controls?params#value|else
  //блоки аналогичные в блоках else нужно заменить переменную ифа на переменную верхнего ифа

  if Index_Felse <> 0 then
  begin
    FElseStr := Copy(Str, Index_Felse + 1, MaxInt);
    if Index_Value <> 0 then
    begin
      ValueStr := Copy(Str, Index_Value + 1, Index_Felse - Index_Value - 1);
      if Index_Params <> 0 then
      begin
        ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        ParamsStr := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
        end;
      end;
    end
    else
    begin
      ValueStr := '';
      if Index_Params <> 0 then
      begin
        ParamsStr := Copy(Str, Index_Params + 1, Index_Felse - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        ParamsStr := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Felse - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Felse - Index_ID - 1);
        end;
      end;
    end;
  end
  else
  begin
    FElseStr := '';
    if Index_Value <> 0 then
    begin
      ValueStr := Copy(Str, Index_Value + 1, MaxInt - Index_Value - 1);
      if Index_Params <> 0 then
      begin
        ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        ParamsStr := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
        end;
      end;
    end
    else
    begin
      ValueStr := '';
      if Index_Params <> 0 then
      begin
        ParamsStr := Copy(Str, Index_Params + 1, MaxInt - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        ParamsStr := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, MaxInt - Index_Controls - 1);
          IdStr := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          IdStr := Copy(Str, Index_ID + 1, MaxInt - Index_ID - 1);
        end;
      end;
    end;
  end;


  {ID := IdStr;
  //Path
  Name := NameStr;
  Source := SourceStr;
    Names       : Array of String;      //Controls | vars
    Values      : Array of String;
  //FType := TLink.Create(FTypeStr);
    Local       : Array of TLink;
    Params      : Array of TLink;
  Value := TLink.Create(ValueStr);
  FElse := TLink.Create(FElseStr);}
end;


destructor TLink.Destroy;
var i: Integer;
begin
  if FType <> nil then
    FType.Destroy;
  for i:=0 to High(Params) do
    if Params[i] <> nil then
      Params[i].Destroy;
  if Value <> nil then
    Value.Destroy;
  if FElse <> nil then
    FElse.Destroy;
  inherited Destroy;
end;






end.















