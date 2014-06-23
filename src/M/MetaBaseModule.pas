unit MetaBaseModule;

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



    Name          : String;     //pointers
    ParentName    : PNode;
    Index         : ANode;
    ParentIndex   : PNode;
    Local         : ANode;
    ParentLocal   : PNode;
    Value         : PNode;
    ParentField   : PNode;
    Fields        : ANode;
    Source        : PNode;
    FType         : PNode;
    FTrue         : PNode;
    FElse         : PNode;
    ParentParams  : PNode;
    Params        : ANode;
    Next          : PNode;
    Prev          : PNode;

    ControlsName  : array of String;
    ControlsValues: array of String;

    Attr        : Integer;    //public system params
    Count       : Integer;
    Time        : Double;
    Exception   : Integer;
    RunCount    : Integer;
    Activate    : Integer;

    Handle      : Integer;    //private system params
    SaveTime    : Double;
    RefCount    : Integer;
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

  TFocus = class
  public
    ID: Integer;
    Root: PNode;
    Prev: PNode;
    Module: PNode;  //now focus, session state
    TimeLine: PEvent;
    TimerInterval: Double;
    Interest: TInterest;

    ExceptionFlag1: Boolean;

    constructor Create;
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
    function SetValue(Node: PNode; Value: String): PNode;  overload;
    function SetValue(Node: PNode; Value: PNode): PNode;  overload;
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
    procedure NextNode(var PrevNode: PNode; NextNode: PNode);
    procedure OnTimer(wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) stdcall;
    procedure AddEvent(Node: PNode);
    procedure SaveNode(Node: PNode);
    function Execute(Line: String): PNode; virtual;  //Create GetMethod
    function GetNodeBody(Node: PNode): String;
  end;

const
  //na - NodeAttribyte
  naIndex = 0;            //sort
  naWord = 1;
  naLink = 2;
  naData = 3;
  naFile = 4;
  naFunc = 5;          //naStdFunc = $51; naFastCallFunc = $52;
  naInt = 6;
  naFloat = 7;
  naRoot = 8;
  //nt - NameType
  ntInt = 'int';
  ntFloat = 'float';

  msec = 86400000;
  RootPath = 'data';

var
  Base: TFocus; //Meta: TRoot;

implementation

constructor TFocus.Create;
var Method: TMethod;
begin

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

  TimerInterval := 100;
  TimerProc(Method) := Self.OnTimer;
  //Windows.SetTimer(0, 0, Round(TimerInterval), Method.Code);
  TimerInterval := TimerInterval / msec;


  Root := AllocMem(SizeOf(TNode));
  Root.Attr := naRoot;
  Module := NewNode('meta');
end;

procedure SetControl(Node: PNode; Param, Value: String);
begin
  Param := AnsiUpperCase(Param);
  Value := AnsiUpperCase(Value);
  if Param = 'ATTR' then
    Node.Attr := StrToIntDef(Value, 0)
  else
  if Param = 'TIME' then
    Node.Time := StrToFloatDef(Value, Now)
  else
  if Param = 'COUNT' then
    Node.Count := StrToIntDef(Value, 0)
  else
  if Param = 'RUN' then
    Node.RunCount := StrToIntDef(Value, 1)
  else
  if Param = 'ACTIVATE' then
    Node.Activate := StrToIntDef(Value, 1);
end;

function GetControls(Node: PNode): String;
begin
  Result := '';
  if Node = nil then Exit;
  if Node.Attr <> 0 then
    Result := Result + '&' + 'ATTR' + '=' + IntToStr(Node.Attr); //merge strings
  if Node.Time <> 0 then
    Result := Result + '&' + 'TIME' + '=' + FloatToStr(Node.Time);
  if Node.Count <> 0 then
    Result := Result + '&' + 'COUNT' + '=' + IntToStr(Node.Count);
  if Node.RunCount <> 0 then
    Result := Result + '&' + 'RUN' + '=' + IntToStr(Node.RunCount);
  if Node.Activate <> 0 then
    Result := Result + '&' + 'ACTIVATE' + '=' + FloatToStr(Node.Activate);
  Delete(Result, 1, 1);
end;

function TFocus.NextID: String;
begin
  Inc(ID);
  Result := '@' + IntToStr(ID);
end;

function TFocus.AddSubNode(var Arr: ANode): PNode;
begin
  SetLength(Arr, High(Arr) + 2);
  Result := AllocMem(SizeOf(TNode));
  Arr[High(Arr)] := Result;
end;

function TFocus.AddIndex(Node: PNode; Name: Char): PNode;
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

function TFocus.AddLocal(Node: PNode; Local: PNode): PNode;
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

function TFocus.AddLocal(Node: PNode): PNode;
begin
  Result := AddLocal(Node, NewIndex(NextID));
end;

function TFocus.AddValue(Node: PNode; Value: String): PNode;
begin
  Result := AllocMem(SizeOf(TNode));
  Result.Name := Value;
  Result.Attr := naData;
  Node.Value := Result;
end;

function TFocus.AddField(Node: PNode; Field: PNode): PNode; //not workt
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

function TFocus.AddParam(Node: PNode; Param: PNode; Index: Integer): PNode;
begin
  Result := nil;
  if Param.FType <> nil then
  begin
    Param.Source := nil;
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

function TFocus.GetIndex(Node: PNode): String;
begin
  Result := '';
  if Node <> nil then
    while Node.ParentIndex <> nil do
    begin
      Result := Node.Name + Result;
      Node := Node.ParentIndex;
    end;
end;

function TFocus.SetValue(Node: PNode; Value: String): PNode;
begin
  Result := AddValue(Node, Value);
  if Node.Source <> nil then
    Node.Source.Value := Result;
end;

function TFocus.SetValue(Node: PNode; Value: PNode): PNode;
begin
  Node.Value := Value;
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

function TFocus.GetValue(Node: PNode): PNode;
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

function TFocus.GetParam(Node: PNode): PNode;
begin
  Result := nil;
  while Node <> nil do
  begin
    Result := Node;
    Node := Node.Value;
  end;
end;

function TFocus.GetData(Node: PNode): PNode;
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

function TFocus.GetSource(Node: PNode): PNode;
begin
  Result := Node;
  if Node = nil then Exit;
  while Result.Source <> nil do
  begin
    Result := Result.Source;
    if Result.Value <> nil then  Exit;
  end;
end;

function TFocus.GetType(Node: PNode): PNode;
begin
  Result := nil;
  if Node = nil then Exit;
  if Node.Source <> nil
  then Result := GetType(Node.Source)
  else Result := GetData(Node.FType);
end;

function TFocus.NewIndex(Name: String): PNode;
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

procedure TFocus.NewModule(Node: PNode);  //change name to LoadFile
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
  if (FileExt = '.dll') then
  begin
    if Node.Handle = 0 then
    begin
      Node.Handle := GetImageFunctionList(FileName, List);
      for i:=0 to List.Count-1 do
      begin
        Func := NewNode(List.Strings[i]);
        Func.Attr := naFunc;
        Func.Handle := GetProcAddress(Node.Handle, List.Strings[i]);
        AddLocal(Node, Func);
      end;
    end;
  end
  else
  if FileExt = '.meta' then
  begin
    PrevModule := Module;
    Module := Node;
    List.LoadFromFile(FileName);
    for i:=0 to List.Count-1 do
      Execute(List.Strings[i]);
    Module := PrevModule;
  end;
  List.Free;
end;

procedure TFocus.CallFunc(Node: PNode);
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

function TFocus.FindNode(Index: PNode): PNode;
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

function  TFocus.NewNode(Line: String): PNode;      //fastload
begin Result := NewNode(TLine.Create(Line)); end;

function TFocus.NewNode(Line: TLine): PNode;
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
    '0'..'9', '-':
        if Pos(',', Line.Name) = 0
        then Result.Attr := naInt
        else Result.Attr := naFloat;
    else  Result.Attr := naWord;
  end;

  for i:=0 to High(Line.Names) do
    SetControl(Result, Line.Names[i], Line.Values[i]);

  if Result.Attr = naWord then
  begin
    if Line.FType = nil then
      Result.Source := FindNode(Result.ParentName);
    for i:=1 to High(Line.Path) do
      Result := AddField(Result, NewNode(Line.Path[i]));
  end;

  if Line.Source <> '' then
  begin
    Node := GetSource(Result);
    Node.Source := NewNode(Line.Source);           
    if Result.Attr = naWord then
      Result := Node.Source;
  end;

  for i:=0 to High(Line.Params) do
    AddParam(Result, NewNode(Line.Params[i]), i);
  if Result.Attr = naData then
  begin
    AddValue(Result, DecodeName(Copy(Line.Name, 2, MaxInt)));
    Result.Value.Attr := naData;
  end;
  if Result.Attr = naInt then
  begin
    Result.Value := NewNode('!' + EncodeName(  IntToStr4(  StrToInt(Line.Name))));
    Result.FType := NewNode('!' + ntInt);
  end;
  if Result.Attr = naFloat then
  begin
    Result.Value := NewNode('!' + EncodeName(FloatToStr8(StrToFloat(Line.Name))));
    Result.FType := NewNode('!' + ntFloat);
  end;
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

procedure TFocus.Run(Node: PNode);
label NextNode; 
var FuncResult, i, n: Integer;
begin
  NextNode:
  if Node = nil then Exit;

  if Node.Exception = 1 then
    ExceptionFlag1 := True;

  if ExceptionFlag1 = True then      //exit in top
    Exit;

  if Node.Attr = naFile then
    NewModule(Node);
  for i:=0 to High(Node.Params) do  //run params
    Run(Node.Params[i]);
  if (Node.Source <> nil) and (((Node.Source.ParentLocal = Module) and (Node.Source.Next <> nil))
    or (Node.Source.Attr = naFunc)) then   // run dll func
  begin
    for i:=0 to High(Node.Params) do
      AddParam(GetSource(Node), GetValue(Node.Params[i]), i);
    Run(Node.Source);                   //run source
    Node.Value := GetData(Node.Source);
  end;
  if Node.Attr = naFunc then     //call dll func
    CallFunc(Node);
  if Node.FElse <> nil then     //node is if
  begin
    FuncResult := CompareWithZero(GetData(Node));   //del funcresult
    if (FuncResult = 1) and (Node.FTrue <> nil) then   //true
    begin
      Node := GetSource(Node.FTrue);
      Goto NextNode;
    end;
    if (FuncResult = 0) and (Node.FElse <> Pointer(1)) then   //false
    begin
      Node := GetSource(Node.FElse);
      Goto NextNode;
    end;
  end
  else
  if (Node.Value <> nil) and (Node.Source <> nil) then   //run value
  begin
    Run(Node.Value);
    Node.Source.Value := GetValue(Node.Value);
  end;

  Node := Node.Next;
  Goto NextNode;      //stack overflow when many next node
end;

procedure TFocus.NextNode(var PrevNode: PNode; NextNode: PNode);
begin
  if PrevNode <> nil then
  begin
    if NextNode <> nil then
      NextNode.Prev := PrevNode;
    PrevNode.Next := NextNode;
  end
  else
    if NextNode <> nil then
    begin
      if Module = nil then
        Module := NextNode
      else
        AddLocal(Module, NextNode);
    end;
  PrevNode := NextNode;
end;



procedure TFocus.SaveNode(Node: PNode);
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
  while (Node.SaveTime = 0) and (High(Node.Local) = -1) and (Node.RefCount = 0) and (High(Node.Index) = -1)  do
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

procedure TFocus.AddEvent(Node: PNode);
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

procedure TFocus.OnTimer(wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) stdcall;
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

function TFocus.Execute(Line: String): PNode;
var
  Data: String;
  i: Integer;
begin
  Result := NewNode(Line);
  NextNode(Prev, Result);
  if Result <> nil then
  begin
    if Result.Activate <> 0 then
    begin
      if Result.RunCount = 0 then
        Result.RunCount := 1;
      Run(Result);
      Result.Activate := 0;
    end;
    {for i:=1 to Result.RunCount do //del
    begin
      Run(Result);
      if ExceptionFlag1 = True then //except
        Break;
    end; }
  end;
end;



function TFocus.GetNodeBody(Node: PNode): String;
var
  Str, Controls: String;
  i: Integer;
begin
  Result := '';
  if Node = nil then Exit;
  if Node.Source <> nil then
    Result := Result + GetIndex(Node.Source) + '^';
  if Node.ParentName <> nil then
    Result := Result + {EncodeName}(GetIndex(Node.ParentName){, 2});
  Result := Result + GetIndex(Node);
  Result := Result + '$' + GetControls(Node);
  if Node.FType <> nil then
    Result := Result + ':' + GetIndex(Node.FType);
  Str := '';
  for i:=0 to High(Node.Params) do
    Str := Str + GetIndex(Node.Params[i]) + '&';
  if Str <> '' then
  begin
    Delete(Str, Length(Str), 1);
    Result := Result + '?' + Str {+ ';'};
  end;
  if (Node.FTrue <> nil) or (Node.FElse <> nil) then
  begin
    if Node.FTrue <> nil then
      Result := Result + '#' + GetIndex(Node.FTrue);
    Result := Result + '|';
    if Integer(Node.FElse) > 1 then
      Result := Result + GetIndex(Node.FElse);
  end
  else
  if Node.Value <> nil then
  begin
    if Node.Value.Attr = naData then
      Result := Result + '#' + EncodeName(Node.Value.Name)
    else
      Result := Result + '#' + GetIndex(Node.Value);
  end;
  if Node.Next <> nil then
    Result := Result + #10 + GetIndex(Node.Next);
  for i:=0 to High(Node.Local) do
    Result := Result + #10#10 + GetIndex(Node.Local[i]);
end;


{
constructor TLine.CreateName(SourceNode, NameNode, IdNode, ControlsNode: String);
begin
  inherited Create;
  if IdNode = '' then Exit;
  if SourceNode <> '' then
    Source := SourceNode;
  if NameNode <> '' then
    Name := Name + NameNode;
  Name := Name + IdNode;
  if ControlsNode <> '' then
    Name := Name + '$' + ControlsNode;
end;

procedure TFocus.SaveNode(Node: PNode);
var
  Line: TLine;
  List: TStringList;
  IndexNode, IndexWin: String;
  i: Integer;
  Parent, BufNode: PNode;

function SaveName(Node: PNode): String;
begin
  Result := '';
  if Node = nil then Exit;
  if (Node.Attr = naData) or (Node.Attr = naFile) or (Node.Attr = naLink)
  then Result := EncodeName(GetIndex(Node), 2)
  else Result := EncodeName(GetIndex(Node), 1);
end;

begin
  if Node = nil then Exit;
  CreateDir(RootPath);

  //with TLine.CreateName(SaveName(Node.Source), SaveName(Node.ParentName), SaveName(Node), '') of
  //begin
  {List := TStringList.Create;
  Line :=

  if Node.Attr <> naIndex then
  begin
    List.Text := Line.GetLine;
    if Node.Next <> nil then
      List.Add(SaveName(Node.Next));
    for i:=0 to High(Node.Local) do
      List.Add(#10 + SaveName(Node.Local[i]));

    IndexNode := GetIndex(Node);
    IndexWin  := RootPath;
    for i:=1 to Length(IndexNode) do
    begin
      if IndexNode[i] in [#0..#32, '/', '\', ':', '*', '?', '@', '"', '<', '>', '|']
      then IndexWin := IndexWin + '\' + IntToHex(Ord(IndexNode[i]), 2)
      else IndexWin := IndexWin + '\' + IndexNode[i];
        CreateDir(IndexWin);
    end;

    List.SaveToFile(IndexWin + '\Node.meta');

    if Node.Source <> nil then
      Dec(Node.Source.RefCount);
  end;


  Line.Free;
  List.Free;
  end;

end;      }

initialization
  //Base := TFocus.Create;
end.
