unit NodeLink;

// ver 2


interface

uses
  SysUtils, NodeUtils, Classes;

const
  nlRecursiveParse = 0;
  nlKernelFastParse = 1;
  nlSetID = 2;

type

  TLink = class
  public
    ID          : String;
    Name        : String;
    Source      : String;
    Names       : Array of String;
    Values      : Array of String;
    FType       : TLink;
    Local       : Array of String;    
    Params      : Array of TLink;
    Value       : TLink;
    FElse       : TLink;
    Next        : String;
    constructor Create(LURI: string; Mode: Integer = nlRecursiveParse);
    constructor RecParse(var LURI: String; FirstRun: Boolean = False);  //рекурсивную дл€ пользовател€
    procedure FastParse(var Str: String);  //более простую дл€ базы
    destructor Destroy;
  end;

implementation

uses Math;

constructor TLink.Create(LURI: string; Mode: Integer = nlRecursiveParse);
begin
  case Mode of
   nlRecursiveParse : RecParse(LURI, True);
   nlKernelFastParse : FastParse(LURI);
   nlSetID : ID := LURI;
  end;
end;

                                                         //потокова€ обработка ссылок
constructor TLink.RecParse(var LURI: String; FirstRun: Boolean = False);
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
      {SetLength(Path, 1);
      Path[0] := ID; }                                             //Path
    end;
    {if ID[1] = '!' then
    begin                                                          //?
      SetLength(Path, 1);
      Path[0] := ID;
    end;}

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

  if LURI[1] = ':' then                         //FType
  begin
    Delete(LURI, 1, 1);
    Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

    if Index = MaxInt then                      //нету управл€ющих символов
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
      Value := TLink.RecParse(LURI);            //следующее значение
    end
    else
    begin
      if Length(LURI) > 0 then                  //дальше функци€
        FType := TLink.RecParse(LURI);
    end;
    Exit;
  end;

  if LURI[1] = '=' then
  begin
    Delete(LURI, 1, 1);
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


procedure TLink.FastParse(var Str: String);
//Source^Name@ID$Names=Values:FType?Params#Value|FElse
//Next
//
//Local
var
  i, j, Index_Source, Index_ID, Index_Controls, Index_FType, Index_Params,
  Index_Value, Index_Felse, Index_Next, Index_Local: Integer;
  ControlsStr, FTypeStr, ParamsStr, ValueStr, FElseStr, LocalStr: String;
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

  ControlsStr := '';
  FTypeStr := '';
  ParamsStr := '';
  ValueStr := '';
  FElseStr := '';
  LocalStr := '';

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

  if Index_ID = 0 then  //ѕодразумеваетс€ что в первой строке есть символ @
  begin
    RecParse(Str, True);
    Exit;
  end;

  if Index_Next <> 0 then
    for i:=Index_Next to Length(Str) - 1 do
      if (Str[i] = #10) and (Str[i + 1] = #10) then
      begin
        Index_Local := i;
        Break;
      end;


  //реализаци€ быстрой записи в переменные
  //перечислим все возможные ситуации не использу€ математические операции
  // ѕарсим с начала  parent^name@
  if Index_Source <> 0 then
  begin
    Source := Copy(Str, 1, Index_Source - 1);
    Name := Copy(Str, Index_Source + 1, Index_ID - Index_Source - 1);
  end
  else
  begin
    Name := Copy(Str, 1, Index_ID - 1);
  end;

  // ѕарсим с конца  @id$controls?params#value|else
  //блоки аналогичные в блоках else нужно заменить переменную ифа на переменную верхнего ифа


  if Index_Local <> 0 then
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
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_FElse - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_FElse - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_FElse - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FElse - Index_ID - 1);
              end;
            end;
          end;
        end;
      end
      else
      begin
        FElseStr := '';
        if Index_Value <> 0 then
        begin
          ValueStr := Copy(Str, Index_Value + 1, Index_Next - Index_Value - 1);
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Next - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Next - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Next - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Next - Index_ID - 1);
              end;
            end;
          end;
        end;
      end;
    end
    else
    begin
      Next := '';
      if Index_Felse <> 0 then
      begin
        FElseStr := Copy(Str, Index_Felse + 1, Index_Local - Index_Felse - 1);
        if Index_Value <> 0 then
        begin
          ValueStr := Copy(Str, Index_Value + 1, Index_Felse - Index_Value - 1);
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_FElse - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_FElse - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_FElse - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FElse - Index_ID - 1);
              end;
            end;
          end;
        end;
      end
      else
      begin
        FElseStr := '';
        if Index_Value <> 0 then
        begin
          ValueStr := Copy(Str, Index_Value + 1, Index_Local - Index_Value - 1);
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Local - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Local - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Local - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Local - Index_ID - 1);
              end;
            end;
          end;
        end;
      end;
    end;
  end
  else
  begin
    LocalStr := '';
    if Index_Next <> 0 then
    begin
      Next := Copy(Str, Index_Next + 1, MaxInt - Index_Next - 1);
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
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_FElse - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_FElse - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_FElse - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FElse - Index_ID - 1);
              end;
            end;
          end;
        end;
      end
      else
      begin
        FElseStr := '';
        if Index_Value <> 0 then
        begin
          ValueStr := Copy(Str, Index_Value + 1, Index_Next - Index_Value - 1);
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Next - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Next - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Next - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Next - Index_ID - 1);
              end;
            end;
          end;
        end;
      end;
    end
    else
    begin
      Next := '';
      if Index_Felse <> 0 then
      begin
        FElseStr := Copy(Str, Index_Felse + 1, MaxInt - Index_Felse - 1);
        if Index_Value <> 0 then
        begin
          ValueStr := Copy(Str, Index_Value + 1, Index_Felse - Index_Value - 1);
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, Index_FElse - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_FElse - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_FElse - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FElse - Index_ID - 1);
              end;
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
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Value - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
              end;
            end;
          end;
        end
        else
        begin
          ValueStr := '';
          if Index_Params <> 0 then
          begin
            ParamsStr := Copy(Str, Index_Params + 1, MaxInt - Index_Params - 1);
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, Index_Params - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
              end;
            end;
          end
          else
          begin
            ParamsStr := '';
            if Index_Ftype <> 0 then
            begin
              FTypeStr := Copy(Str, Index_Ftype + 1, MaxInt - Index_Ftype - 1);
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, Index_Ftype - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, Index_FType - Index_ID - 1);
              end;
            end
            else
            begin
              FTypeStr := '';
              if Index_Controls <> 0 then
              begin
                ControlsStr := Copy(Str, Index_Controls + 1, MaxInt - Index_Controls - 1);
                ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
              end
              else
              begin
                ControlsStr := '';
                ID := Copy(Str, Index_ID + 1, MaxInt - Index_ID - 1);
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  //ќбрабатываем полученные строки
  
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


  if FTypeStr <> '' then
    FType := TLink.Create(FTypeStr, nlSetID);


  if ParamsStr <> '' then
  begin
    Index_Params := 1;
    for i:=1 to Length(ParamsStr) - 1 do
      if ParamsStr[i] = '&' then
      begin
        SetLength(Params, Length(Params) + 1);
        Params[High(Params)] := TLink.Create(Copy(ParamsStr, Index_Params, i - Index_Params), nlSetID);
        Index_Params := i + 1;
      end;
    if Index_Params <> Length(ParamsStr) then
    begin
      SetLength(Params, Length(Params) + 1);
      Params[High(Params)] := TLink.Create(Copy(ParamsStr, Index_Params, MaxInt), nlSetID);
    end;
  end;

  if ValueStr <> '' then
    Value := TLink.Create(ValueStr, nlSetID);

  if FElseStr <> '' then
    FElse := TLink.Create(FElseStr, nlSetID);

  if LocalStr <> '' then
  begin
    Index_Local := 1;
    for i:=1{3} to Length(LocalStr) - 1{4} do
      if (LocalStr[i] = #10) and (LocalStr[i + 1] = #10) then
      begin
        SetLength(Local, Length(Local) + 1);
        Local[High(Local)] := Copy(LocalStr, Index_Local,  i - Index_Local);
        Index_Local := i + 2;
      end;
    if Index_Local <> Length(LocalStr) then
    begin
      SetLength(Local, Length(Local) + 1);
      Local[High(Local)] := Copy(LocalStr, Index_Local,  MaxInt);
    end;
  end;

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















