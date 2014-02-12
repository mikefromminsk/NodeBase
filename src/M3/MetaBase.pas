unit MetaBase;

interface

uses
  Types{TIntegerDynArray},  Math{SumInt}, SysUtils{AllocMem, Now},
  Classes{TStrings}, MetaLine, Windows{SetTimer}, MetaUtils, Dialogs;

type
  TimerProc = procedure (wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) of object; stdcall;

  PNode = ^TNode;

  ANode = array of PNode;


  PEvent = ^TEvent;   //replace to interval

  TEvent = record
    FBegin: Double;
    FEnd  : Double;
    Nodes : ANode;
    Next  : PEvent;
  end;


  TNode = record
    Path  : String;          //test variable
    LocalName: String;



    Name        : String;     //pointers
    ParentName  : PNode;
    Index       : ANode;
    ParentIndex : PNode;
    Local       : ANode;
    ParentLocal : PNode;
    Value       : PNode;
    ParentField : PNode;
    Fields      : ANode;
    Source      : PNode;
    FType       : PNode;
    FTrue       : PNode;
    FElse       : PNode;
    ParentParams: PNode;
    Params      : ANode;
    Next        : PNode;
    Prev        : PNode;

    Attr        : Integer;    //system
    Count       : Integer;
    Handle      : Integer;
    SaveTime    : Double;
    RefCount    : Integer;

    Generate    : Integer;     //controls
    RunCount    : Integer;
    Exception   : Integer;

  end;

  TInterest = record
    step : Double;
    max  : Double;
    min  : Double;
    count: Double;
    now  : Double;
    into : Double;
    from : Double;
  end;

  TMeta = class
  public
    ID: Integer;
    Root: PNode;
    Prev: PNode;
    Module: PNode;
    TimeLine: PEvent;
    TimerInterval: Double;
    Interest: TInterest;

    ExceptionFlag1: Boolean;

    constructor Create;
    procedure Load;
    function NextID: String;
    function AddSubNode(var Arr: ANode): PNode;
    function AddIndex(Node: PNode; Name: Char): PNode;
    function NewIndex(Name: String): PNode;
    function AddLocal(Node: PNode): PNode; overload;
    function AddLocal(Node: PNode; Local: PNode): PNode; overload;
    function AddValue(Node: PNode; Value: String): PNode;
    function AddField(Node: PNode; Field: PNode): PNode;
    function AddParam(Node: PNode; Param: PNode; Index: Integer): PNode;
    function GetIndex(Node: PNode): String;
    function SetValue(Node: PNode; Value: String): PNode;
    function GetValue(Node: PNode): PNode;
    function GetParam(Node: PNode): PNode;
    function GetData(Node: PNode): PNode;
    function GetType(Node: PNode): PNode;
    function GetSource(Node: PNode): PNode;
    procedure NewModule(Node: PNode);
    procedure CallFunc(Node: PNode);
    function FindNode(Index: PNode): PNode;
    function NewNode(Line: String): PNode; overload;
    function NewNode(Line: TLine): PNode; overload;
    procedure Run(Node: PNode);
    procedure NextNode(var PrevNode: PNode; Node: PNode);
    procedure OnTimer(wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) stdcall;
    procedure AddEvent(Node: PNode);
    procedure SaveNode(Node: PNode);
    procedure Analysing(Node: PNode); virtual;
    function Get(Line: String): PNode;
    function GetNodeBody(Node: PNode): String;
  end;

const
  naIndex = 0;
  naWord = 1;
  naLink = 2;
  naData = 3;
  naFile = 4;
  naFunc = 5;          //naStdFunc = $51; naFastCallFunc = $52;
  naNumber = 6;
  naRoot = 7;

  msec = 86400000;
  RootPath = 'data';

var
  Base: TMeta; //Meta: TRoot;

implementation

constructor TMeta.Create;
var Method: TMethod;
begin
  Load;

  with Interest do
  begin
    step := 10;
    max  := 20;
    min  := -10;
    count:= 0;
    now  := 10;
    into := 0;
    from := 50000;
  end;

  CreateDir(RootPath);
  TimerInterval := 100;
  TimerProc(Method) := Self.OnTimer;
  //Windows.SetTimer(0, 0, Round(TimerInterval), Method.Code);
  TimerInterval := TimerInterval / msec;


  Root := AllocMem(SizeOf(TNode));
  Root.Attr := naRoot;
  Module := NewNode(NextID);
end;

procedure TMeta.Load;
var MetaOptions: TStringList;
begin
  if FileExists('metaoptions.ini') then
  begin
    MetaOptions := TStringList.Create;
    with MetaOptions do
    begin
      LoadFromFile('metaoptions.ini');  //StRootValue
      ID := StrToInt(Values['ID']);
      TimerInterval := StrToInt(Values['TimerInterval']);
    end;
  end;
end;

function TMeta.NextID: String;
begin
  Inc(ID);
  Result := '@' + IntToStr(ID);
end;

function TMeta.AddSubNode(var Arr: ANode): PNode;
begin
  SetLength(Arr, High(Arr) + 2);
  Result := AllocMem(SizeOf(TNode));
  Arr[High(Arr)] := Result;
end;

function TMeta.AddIndex(Node: PNode; Name: Char): PNode;
begin
  Result := AddSubNode(Node.Index);
  Result.Attr := naIndex;
  Result.Name := Name;
  Result.ParentIndex := Node;
  Result := Node.Index[High(Node.Index)];

  Node := Result;         //test
  while Node <> nil do
  begin
    Result.Path := Node.Name + Result.Path;
    Node := Node.ParentIndex;
  end;
end;

function TMeta.AddLocal(Node: PNode; Local: PNode): PNode;
begin
  AddSubNode(Node.Local);
  if Node.Attr = naIndex
  then Local.ParentName  := Node
  else Local.ParentLocal := Node;
  Node.Local[High(Node.Local)] := Local;
  Result := Local;

  while Node <> nil do    //test
  begin
    Result.LocalName := Node.Name + Result.LocalName;
    Node := Node.ParentIndex;
  end;
end;

function TMeta.AddLocal(Node: PNode): PNode;
begin
  Result := AddLocal(Node, NewIndex(NextID));
end;

function TMeta.AddValue(Node: PNode; Value: String): PNode;
begin
  Result := AllocMem(SizeOf(TNode));
  Result.Name := Value;
  Result.Attr := naData;
  Node.Value := Result;
end;

function TMeta.AddField(Node: PNode; Field: PNode): PNode;
var i: Integer;
begin
  Result := nil;
  Field.Source := nil;
  if Node.Source <> nil then
    Node := Node.Source;
  for i:=0 to High(Node.Fields) do
    if Node.Fields[i].ParentName = Field.ParentName then
    begin
      Result := Node.Fields[i];
      Exit;
    end;
  AddSubNode(Node.Fields);
  Field.ParentField := Node;
  Field.Value := nil;
  Node.Fields[High(Node.Fields)] := Field;
  Result := Field;
end;

function TMeta.AddParam(Node: PNode; Param: PNode; Index: Integer): PNode;
var i: Integer;
begin
  Result := nil;
  if Param.FType <> nil then
  begin
    Param.Source := nil;
    for i:=0 to High(Node.Params) do
      if Node.Params[i].ParentName = Param.ParentName then
      begin
        Result := Node.Params[i];
        Exit;
      end;
    AddSubNode(Node.Params);
    Node.Params[High(Node.Params)] := Param;
    Param.ParentParams := Node;
    Result := Param;
  end
  else
  begin
    if Index = High(Node.Params) + 1 then
    begin
      AddSubNode(Node.Params);
      Node.Params[Index] := Param;
      Param.ParentParams := Node;
      Result := Node.Params[Index];
    end
    else
    if Index <= High(Node.Params) then
    begin
      Result := Node.Params[Index];
      if Result <> Param then
        Result.Value := Param;
    end;
  end;
end;

function TMeta.GetIndex(Node: PNode): String;
begin
  Result := '';
  if Node <> nil then
    while Node.ParentIndex <> nil do
    begin
      Result := Node.Name + Result;
      Node := Node.ParentIndex;
    end;
end;

function TMeta.SetValue(Node: PNode; Value: String): PNode;
begin
  Result := AddValue(Node, Value);
  if Node.Source <> nil then
    Node.Source.Value := Result;
end;

function FindValue(var ValueStack: ANode; Value: PNode): Boolean;
var i: Integer;
begin
  Result := False;
  for i:=0 to High(ValueStack) do
  if ValueStack[i] = Value then
  begin
    Result := True;
    Exit;
  end;
end;

function TMeta.GetValue(Node: PNode): PNode;
var ValueStack: ANode;
begin
  Result := nil;
  while Node <> nil do
  begin
    SetLength(ValueStack, High(ValueStack) + 2);
    ValueStack[High(ValueStack)] := Node;
    if Node.Source <> nil then
      Node := Node.Source
    else
    begin
      Result := Node;
      if Node.Value = nil then Break;
      if FindValue(ValueStack, Node.Value) then Break;
      Node := Node.Value;
    end;
  end;
  SetLength(ValueStack, 0);
end;

function TMeta.GetParam(Node: PNode): PNode;
begin
  Result := nil;
  while Node <> nil do
  begin
    Result := Node;
    Node := Node.Value;
  end;
end;

function TMeta.GetData(Node: PNode): PNode;
var ValueStack: ANode;
begin
  Result := nil;
  while Node <> nil do
  begin
    SetLength(ValueStack, High(ValueStack) + 2);
    ValueStack[High(ValueStack)] := Node;
    if Node.Source <> nil then
      Node := Node.Source
    else
    begin
      if Node.Attr = naData then
        Result := Node;
      if FindValue(ValueStack, Node.Value) then Break;
      Node := Node.Value;
    end;
  end;
  SetLength(ValueStack, 0);
end;

function TMeta.GetSource(Node: PNode): PNode;
begin
  Result := Node;
  if Node = nil then Exit;
  while Result.Source <> nil do
  begin
    Result := Result.Source;
    if Result.Value <> nil then  Exit;
  end;
end;

function TMeta.GetType(Node: PNode): PNode;
begin
  Result := nil;
  if Node = nil then Exit;
  if Node.Source <> nil
  then Result := GetType(Node.Source)
  else Result := GetData(Node.FType);
end;

function TMeta.NewIndex(Name: String): PNode;
var i, j, Index: Integer;
begin
  Result := Root;
  for i:=1 to Length(Name) do
  begin
    Index := -1;
    for j:=0 to High(Result.Index) do
      if  Result.Index[j].Name = Name[i] then
      begin
        Index := j;
        Break;
      end;
    if Index = -1
    then Result := AddIndex(Result, Name[i])
    else Result := Result.Index[Index];
  end;
  if Result <> Root
  then Inc(Result.Count)
  else Result := nil;
end;

procedure TMeta.NewModule(Node: PNode);
var
  i: Integer;
  Func, PrevModule: PNode;
  List: TStrings;
  FileName, FileExt: String;
begin
  FileName := Copy(GetIndex(Node.ParentName), 2, MaxInt);
  if not FileExists(FileName) then Exit;
  List := TStringList.Create;
  FileExt := LowerCase(ExtractFileExt(FileName));
  if FileExt = '.dll' then
  begin
    Node.Handle := GetImageFunctionList(FileName, List);
    for i:=0 to List.Count-1 do
    begin
      Func := NewNode(List.Strings[i]);
      Func.Attr := naFunc;
      Func.Handle := GetProcAddress(Node.Handle, List.Strings[i]);
      AddLocal(Node, Func);
    end;
    //if FileExists(FileName + '.meta') then
  end
  else
  if FileExt = '.meta' then
  begin
    PrevModule := Module;
    Module := Node;
    List.LoadFromFile(FileName);
    for i:=0 to List.Count-1 do
      Get(List.Strings[i]);
    Module := PrevModule;
  end;
  List.Free;
end;

procedure TMeta.CallFunc(Node: PNode);
var
  Value: PNode;
  Params, Param: String;
  Stack: array of Integer;
  Func, FourByte, i, BVal, ParamCount,
  EAXParam, EDXParam, ECXParam, RegParamCount: Integer;
  DBVal: Double;
  IfFloat: Integer;
begin
  BVal := BVal + 1;
  Func := Node.Handle;
  if (Func = 0) then Exit;
  EAXParam := 0; EDXParam := 0; ECXParam := 0; RegParamCount := 0;
  

  for i:=0 to High(Node.Params) do
  begin
    Value := GetData(Node.Params[i]);
    if Value = nil then Exit
    else
    begin
      Param := Value.Name;

      if Length(Param) > 4 then
        Params := StringOfChar(#0, Length(Param) mod 4) + Param + Params;

      if Length(Param) < 4 then
        Params := StringOfChar(#0, 4 - Length(Param)) + Param + Params;

      if Length(Param) = 4 then
      begin
        case RegParamCount of
          0: EAXParam := StrToInt4(Param);
          1: EDXParam := StrToInt4(Param);
          2: ECXParam := StrToInt4(Param);
        else
          Params := Param + Params;
        end;
        Inc(RegParamCount);
      end;
    end;
  end;

  while Params <> '' do
  begin
    SetLength(Stack, High(Stack) + 2);
    Stack[High(Stack)] := StrToInt4(Copy(Params, 1, 4));
    Delete(Params, 1, 4);
  end;

  for i:=High(Stack) downto 0 do
  begin
    FourByte := Stack[i];
    asm push FourByte end;
  end;

  if RegParamCount >= 3 then
    asm mov ecx, ECXParam end;

  if RegParamCount >= 2 then
    asm mov edx, EDXParam end;

  if RegParamCount >= 1 then
    asm mov eax, EAXParam end;

  asm
    CLC
    CALL Func
    JC @1
    MOV BVal, EAX                //get int value
    MOV IfFloat, 0
    JMP @2
    @1:
    FSTP QWORD PTR [DBVal]       //get float value
    MOV IfFloat, 1
    @2:
  end;

  if IfFloat = 0
  then SetValue(Node, IntToStr4(BVal))
  else SetValue(Node, FloatToStr8(DBVal));

end;

function FindInNode(Node: PNode; Index: PNode): PNode;
var
  i: Integer;
  Local: PNode;
begin
  Result := nil;
  if Node.ParentName = Index then
    Result := Node;
  if (Result = nil) then
    for i:=0 to High(Node.Params) do
      if Node.Params[i].ParentName = Index then
        Result := Node.Params[i];
  if (Result = nil) and (Node.Value <> nil) and (Node.Value.ParentName = Index) then
    Result := Node.Value;
  if (Result = nil) and (Node.FTrue <> nil) and (Node.FTrue.ParentName = Index) then
    Result := Node.FTrue;
  if (Result = nil) and (Node.FElse <> nil) and (Node.FElse <> Pointer(1))
      and (Node.FElse.ParentName = Index) then
    Result := Node;
  if Result = nil then
    for i:=0 to High(Node.Local) do
    begin
      Local := Node.Local[i];
      while Local.ParentField <> nil do
        Local := Local.ParentField;
      if Local.Attr = naFile then
      begin
        Result := FindInNode(Local, Index);
        if Result <> nil then Exit;
      end;
      if Local.ParentName = Index then
      begin
        Result := Local;
        Exit;
      end;
    end;
end;

function TMeta.FindNode(Index: PNode): PNode;
var Node, Find: PNode;
begin
  Result := nil;
  if Prev = nil
  then Node := Module
  else Node := Prev;
  while Node <> nil do
  begin
    Find := FindInNode(Node, Index);
    if Find <> nil then
    begin
      Result := Find;
      if Find.Source = nil then Exit;
    end;
    if (Node.Prev = nil) and (Node.ParentLocal <> nil)
    then Node := Node.ParentLocal
    else Node := Node.Prev;
  end;
end;

function  TMeta.NewNode(Line: String): PNode;
begin Result := NewNode(TLine.Create(Line)); end;

function TMeta.NewNode(Line: TLine): PNode;
var
  i: Integer;
  Node: PNode;
  IsPointer: Boolean;
begin
  IsPointer := False;
  if (Length(Line.Name) <> 0) and (Line.Name[1] = '*') then
  begin
    Delete(Line.Name, 1, 1);
    IsPointer := True;
  end;
  if (Line.Name = '') and (High(Line.Names) <> -1) then
    Line.Name := NextID;
  Result := NewIndex(Line.Name);
  if Result = nil then Exit;
  if Line.Name[1] <> '@' then
    Result := AddLocal(Result);
  case Line.Name[1] of
    '!' : Result.Attr := naData;
    '@' : Result.Attr := naLink;
    '/' : Result.Attr := naFile;
    '0'..'9', '-': Result.Attr := naNumber;
    else  Result.Attr := naWord;
  end;

  for i:=0 to High(Line.Names) do
  begin
    case Line.Names[i][1] of
      'C' : Result.Count := StrToInt(Line.Values[i]);
      'T' : Result.SaveTime := StrToFloat(Line.Values[i]);
      'G' : Result.Generate := StrToInt(Line.Values[i]);
      'R' : Result.RunCount := StrToInt(Line.Values[i]);
      'E' : Result.Exception := StrToInt(Line.Values[i]);
    end;
  end;

  if Result.Attr = naWord then
  begin
    if Line.FType = nil then
      Result.Source := FindNode(Result.ParentName);
    for i:=1 to High(Line.Path) do
      Result := AddField(Result, NewNode(Line.Path[i]));
    if Line.Source <> '' then
    begin
      NextNode(Prev, NewNode(Line.Source));
      Inc(Result.Source.RefCount);  //!!!
      AddEvent(Result);             //!!!
      Result := GetSource(Result);
      Result.Source := Prev;
    end;
    if (Result.Source = nil) and (Line.Value <> nil) and (Prev <> nil) and (Prev <> Module) then
    begin
      NextNode(Prev, NewNode(Line.Name));
      Result.Source := Prev;
    end;
  end;
  if Line.Source <> '' then
    Result.Source := NewNode(Line.Source);

  for i:=0 to High(Line.Params) do
    AddParam(Result, NewNode(Line.Params[i]), i);
  if Result.Attr = naData then
  begin
    AddValue(Result, DecodeName(Copy(Line.Name, 2, MaxInt)));
    Result.Value.Attr := naData;
  end;
  if (Result.Attr = naNumber) and (Result.ParentField = nil) then
    if Pos(',', Line.Name) = 0
    then Result.Value := NewNode('!' + EncodeName(  IntToStr4(  StrToInt(Line.Name))))
    else Result.Value := NewNode('!' + EncodeName(FloatToStr8(StrToFloat(Line.Name))));
  if Line.FElse <> nil then
  begin
    Result.FElse := NewNode(Line.FElse);
    if Result.FElse = nil then
      Result.FElse := Pointer(1);
    Result.FTrue := NewNode(Line.Value);
  end
  else
  if Line.Value <> nil then
    Result.Value := NewNode(Line.Value);
  if Line.FType <> nil then
    Result.FType := NewNode(Line.FType);
  for i:=0 to High(Line.Local) do
    AddLocal(Result, NewNode(Line.Local[i]));
  if Result.Source <> nil then
    Inc(Result.Source.RefCount);
  AddEvent(Result);
end;

function CompareWithZero(Node: PNode): Integer;
var i: Integer;
begin
  Result := -1;
  if Node <> nil then
  begin
    Result := 0;
    for i:=0 to Length(Node.Name) do
      Inc(Result, Ord(Node.Name[i]));
  end;
end;

procedure TMeta.Run(Node: PNode);
label NextNode; //Change name
var FuncResult, i: Integer;
begin
  NextNode:
  if Node = nil then Exit;
  Analysing(Node);
  if Node.Exception = 1 then
    ExceptionFlag1 := True;

  if ExceptionFlag1 = True then
    Exit;         

  if Node.Attr = naFile then
    NewModule(Node);
  for i:=0 to High(Node.Params) do
    Run(Node.Params[i]);
  if (Node.Source <> nil) and (((Node.Source.ParentLocal = Module) and (Node.Source.Next <> nil))
    or (Node.Source.Attr = naFunc)) then
  begin
    for i:=0 to High(Node.Params) do
      AddParam(GetSource(Node), GetValue(Node.Params[i]), i);
    Run(Node.Source);
    Node.Value := GetData(Node.Source);
  end;
  if Node.Attr = naFunc then
    CallFunc(Node);
  if Node.FElse <> nil then
  begin
    FuncResult := CompareWithZero(GetData(Node));
    if (FuncResult = 1) and (Node.FTrue <> nil) then
    begin
      Node := GetSource(Node.FTrue);
      Goto NextNode;
    end;
    if (FuncResult = 0) and (Node.FElse <> Pointer(1)) then
    begin
      Node := GetSource(Node.FElse);
      Goto NextNode;
    end;
  end
  else
  if (Node.Value <> nil) and (Node.Source <> nil) then
  begin
    Run(Node.Value);
    Node.Source.Value := GetValue(Node.Value);
  end;

  Node := Node.Next;
  Goto NextNode;
end;

procedure TMeta.NextNode(var PrevNode: PNode; Node: PNode);
begin
  if PrevNode <> nil then
  begin
    if Node <> nil then
      Node.Prev := PrevNode;
    PrevNode.Next := Node;
  end
  else
    if Node <> nil then
    begin
      if Module = nil then
        Module := Node
      else
        AddLocal(Module, Node);
    end;
  PrevNode := Node;
end;



procedure TMeta.SaveNode(Node: PNode);
var ParentIndex: PNode;
procedure DeleteArrayValue(var Arr: ANode; Value: Pointer);
var i: Integer;
begin
  for i:=0 to High(Arr) do
    if Arr[i] = Value then
    begin
      Arr[i] := Arr[High(Arr)];
      SetLength(Arr, High(Arr));
      Exit;
    end;
end;
begin
  if Node = nil then Exit;
  while (High(Node.Local) = -1) and (Node.RefCount = 0) and (High(Node.Index) = -1) and (Node.SaveTime = 0) do
  begin
    if Node.ParentName <> nil then
    begin
      DeleteArrayValue(Node.ParentName.Local, Node);
      SaveNode(Node.ParentName);
    end;
    if Node.ParentLocal <> nil then
    begin
      DeleteArrayValue(Node.ParentLocal.Local, Node);
      SaveNode(Node.ParentLocal);
    end;
    ParentIndex := Node.ParentIndex;
    DeleteArrayValue(ParentIndex.Index, Node);
    if Node.Source <> nil then
    begin
      Dec(Node.Source.RefCount);
      SaveNode(Node.Source);
    end;
    Dispose(Node);
    Node := ParentIndex;
  end;
end;

procedure TMeta.AddEvent(Node: PNode);
var Event, NewEvent: PEvent;
begin
  Node.SaveTime := Now + TimerInterval;     //formula

  Event := TimeLine;
  while True do
  begin
    if Event = nil then
    begin
      Event := AllocMem(SizeOf(TEvent));
      Event.FBegin:= Node.SaveTime;
      Event.FEnd  := Node.SaveTime + TimerInterval;
      SetLength(Event.Nodes, High(Event.Nodes) + 2);
      Event.Nodes[High(Event.Nodes)] := Node;
      if TimeLine = nil then
        TimeLine := Event;
      Break;
    end
    else
    if (Node.SaveTime >= Event.FBegin) and (Node.SaveTime <= Event.FEnd) then
    begin
      SetLength(Event.Nodes, High(Event.Nodes) + 2);
      Event.Nodes[High(Event.Nodes)] := Node;
      Break;
    end
    else
    if (Event.Next = nil) or (Node.SaveTime < Event.Next.FBegin) then
    begin
      NewEvent := AllocMem(SizeOf(TEvent));
      NewEvent.FBegin:= Node.SaveTime;
      NewEvent.FEnd  := Node.SaveTime + TimerInterval;
      SetLength(NewEvent.Nodes, High(NewEvent.Nodes) + 2);
      NewEvent.Nodes[High(NewEvent.Nodes)] := Node;
      Event.Next := NewEvent;
      Break;
    end;
    Event := Event.Next;
  end;
end;

procedure TMeta.OnTimer(wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) stdcall;
var
  i: Integer;
  TimeLine: PEvent;
begin
  TimeLine := Base.TimeLine;      
  if (TimeLine = nil) or (Now < TimeLine.FEnd) then Exit;   //while
  for i:=0 to High(TimeLine.Nodes) do
    if (TimeLine.Nodes[i].SaveTime >= TimeLine.FBegin) and
       (TimeLine.Nodes[i].SaveTime <= TimeLine.FEnd) then
    begin
      TimeLine.Nodes[i].SaveTime := 0;
      SaveNode(TimeLine.Nodes[i]);
    end;
  TimeLine.Nodes := nil;
  Base.TimeLine := TimeLine.Next;
  Dispose(TimeLine);
end;

procedure TMeta.Analysing(Node: PNode);
begin

end;

function TMeta.Get(Line: String): PNode;
var
  Data: String;
  i: Integer;
begin
  Result := NewNode(Line);
  NextNode(Prev, Result);
  if Result <> nil then
    for i:=1 to Result.RunCount do
    begin
      Run(Result);
      if ExceptionFlag1 = True then
      if ExceptionFlag1 = True then
        Break;
    end;
end;















function TMeta.GetNodeBody(Node: PNode): String;
var
  Str: String;
  i: Integer;
  Next: PNode;
begin
  Result := '';
  if Node = nil then Exit;
  if Node.Source <> nil then
    Result := Result + GetIndex(Node.Source) + '^';
  if Node.ParentName <> nil then
    Result := Result + EncodeName(GetIndex(Node.ParentName), 2);
  Result := Result + GetIndex(Node);
  if Node.FType <> nil then
    Result := Result + ':' + GetIndex(Node.FType);
  Str := '';
  if Node.Generate <> 0 then
    Str := Str + 'G' + IntToStr(Node.Generate);
  if Str <> '' then
    Result := Result + '$' + Str;
  Str := '';
  for i:=0 to High(Node.Params) do
    Str := Str + GetIndex(Node.Params[i]) + '&';
  if Str <> '' then
  begin
    Delete(Str, Length(Str), 1);
    Result := Result + '?' + Str + ';';
  end;
  if (Node.FTrue <> nil) or (Node.FElse <> nil) then
  begin
    if Node.FTrue <> nil then
      Result := Result + '#' + GetIndex(Node.FTrue);
    if Integer(Node.FElse) > 1 then
      Result := Result + '|' + GetIndex(Node.FElse);
  end
  else
  if Node.Value <> nil then
  begin
    if Node.Value.Attr = naData then
      Result := Result + '#' + EncodeName(Node.Value.Name)
    else
      Result := Result + '#' + GetIndex(Node.Value);
  end;
  Next := Node.Next;
  while Next <> nil do
  begin
    Result := Result + #10 + GetIndex(Next);
    Next := Next.Next;
  end;
  for i:=0 to High(Node.Local) do
    Result := Result + #10#10 + GetIndex(Node.Local[i]);
end;

initialization
  //Base := TMeta.Create;
end.
