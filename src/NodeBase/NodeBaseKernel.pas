unit NodeBaseKernel;

interface

uses
  Math{SumInt}, SysUtils{AllocMem, Now}, Classes{TStrings}, NodeLink, NodeUtils,
  Dialogs{test};

type

  PNode = ^TNode;
  ANode = array of PNode;
  AString = array of String;
  
  TNode = record

    Path  : String;          //test

    Name          : String;     
    Index         : ANode;
    ParentIndex   : PNode;
    Source        : PNode;
    ParentName    : PNode;
    FType         : PNode;
    Params        : ANode;
    ParentParams  : PNode;
    Local         : ANode;
    ParentLocal   : PNode;
    Value         : PNode;
    ParentValue   : PNode;
    FTrue         : PNode;
    ParentFTrue   : PNode;
    FElse         : PNode;
    ParentFElse   : PNode;
    Prev          : PNode;
    Next          : PNode;
  //public
    Attr        : Integer;
    Count       : Integer;
    Time        : Double;
    RunCount    : Integer;
    Activate    : Integer;
  //private
    Handle      : Integer;
    SaveTime    : Double;
    RefCount    : Integer;
  end;

  PEvent = ^TEvent;
  TEvent = record
    FBegin: Double;
    FEnd  : Double;
    Nodes : ANode;
    Next  : PEvent;
  end;

  TFocus = class
  public
    ID        : Integer;
    Root      : PNode;
    Prev      : PNode;
    Module    : PNode;
    NodesCount: Integer;    //test

    TimeManager    : PEvent;
    GarbageInterval: Double;
    GarbageLastRun : Double;

    constructor Create;
    function NextID: String;
    function AddSubNode(var Arr: ANode): PNode;
    function AddIndex(Node: PNode; Name: Char): PNode;
    function AddLocal(Node: PNode; Local: PNode): PNode; overload;
    function AddLocal(Node: PNode): PNode; overload;
    function AddValue(Node: PNode; Value: String): PNode;
    function AddParam(Node: PNode; Param: PNode; Index: Integer): PNode;
    function GetIndex(Node: PNode): String;
    function SetValue(Node: PNode; Value: String): PNode; overload;
    function SetValue(Node: PNode; Value: PNode): PNode; overload;
    function GetValue(Node: PNode): PNode;
    function GetParam(Node: PNode): PNode;
    function GetData(Node: PNode): PNode;
    function GetSource(Node: PNode): PNode;
    function GetType(Node: PNode): PNode;
    function NewIndex(Name: String): PNode;
    procedure LoadModule(Node: PNode);
    procedure CallFunc(Node: PNode);
    function LoadNode(Node: PNode): PNode;
    function FindNode(Index: PNode): PNode;
    function NewNode(Line: String): PNode; overload;
    function NewNode(Line: TLink): PNode; overload;
    procedure AddEvent(Node: PNode);
    procedure SaveNode(Node: PNode);
    procedure GarbageCollector;
    procedure RecursiveSave(Node: PNode);
    procedure RecursiveDispose(Node: PNode);
    procedure Clear;
    function GetNodeBody(Node: PNode): String;
    procedure Run(Node: PNode);
    procedure NextNode(var PrevNode: PNode; NextNode: PNode);
    function Execute(Line: String): PNode; virtual;

  end;

const

//NodeAttribyte
  naEmpty = 0;            //sort
  naWord = 1;
  naNode = 2;
  naData = 3;
  naModule = 4;       
  naDLLFunc = 5;          //naStdFunc = $51; naFastCallFunc = $52;
  naInt = 7;
  naFloat = 8;
  naRoot = 9;
  naLoad = 10;

//NameType
  ntInt = 'int';
  ntFloat = 'float';

  NodeFileName = 'Node.txt';

implementation


constructor TFocus.Create;
begin
  NodesCount := 0;
  Root := AllocMem(SizeOf(TNode));
  Root.Attr := naRoot;
  Root.Name := 'data';
  Module := NewNode('root');
end;

procedure SetControl(Node: PNode; Param, Value: String);
begin
  Param := AnsiUpperCase(Param);
  Value := AnsiUpperCase(Value);
  if Param = 'ATTR'  then Node.Attr := StrToIntDef(Value, 0);
  if Param = 'TIME'  then Node.Time := StrToFloatDef(Value, Now);
  if Param = 'COUNT' then Node.Count := StrToIntDef(Value, 0);
  if Param = 'RUN'   then Node.RunCount := StrToIntDef(Value, 1);
  if Param = 'ACTIVATE' then Node.Activate := StrToIntDef(Value, 1);
end;

function GetControls(Node: PNode): String;
begin
  Result := '';
  if Node = nil then Exit;
  if Node.Attr <> 0 then
    Result := Result + '&' + 'ATTR' + '=' + IntToStr(Node.Attr);
  if Node.Time <> 0 then
    Result := Result + '&' + 'TIME' + '=' + FloatToStr(Node.Time);
  if Node.Count <> 0 then
    Result := Result + '&' + 'COUNT' + '=' + IntToStr(Node.Count);
  if Node.RunCount <> 0 then
    Result := Result + '&' + 'RUN' + '=' + IntToStr(Node.RunCount);
  if Node.Activate <> 0 then
    Result := Result + '&' + 'ACTIVATE' + '=' + FloatToStr(Node.Activate);
  Delete(Result, 1, 1); //del &
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
  Result.Attr := naEmpty;
  Result.Name := Name;
  Result.ParentIndex := Node;
  Result := Node.Index[High(Node.Index)];
  Inc(NodesCount);

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
  if Node.Attr = naEmpty
  then Local.ParentName  := Node
  else Local.ParentLocal := Node;
  Node.Local[High(Node.Local)] := Local;
  Result := Local;
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
  Result.ParentValue := Node;
  Node.Value := Result;
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
      Param.ParentParams := Node;
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
  begin
    {if Node.Source.Value <> nil then
      Node.Source.Value.ParentValue := nil; }
    Node.Source.Value := Result;
  end;
end;

function TFocus.SetValue(Node: PNode; Value: PNode): PNode;
begin
{  if Node.Value <> nil then
    Node.Value.ParentValue := nil;}
  if Value <> nil then
    Value.ParentValue := Node;
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
    if Result.Value <> nil then  Exit;   //??
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
  if (Result = nil) and (Node.FElse <> nil) and (Node.FElse.ParentName = Index) then
    Result := Node;
  if Result = nil then
    for i:=0 to High(Node.Local) do
    begin
      Local := Node.Local[i];
      if Local.Attr = naModule then
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

function CreateIndexes(Node: PNode): AString;
begin
  SetLength(Result, 0);
  while Node <> nil do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Node.Name;
    Node := Node.ParentIndex;
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

function CreateIndexesDirTree(Indexes: AString): String;
var i: Integer;  //c:\data\@\1\
begin
  Result := '';
  for i:=High(Indexes) downto 0 do
  begin
    Result := Result + Indexes[i];
    CreateDir(Result);
    Result := Result + '\';
  end;
end;

function SaveToFile(FileName: String; Data: String): Integer;
var List: TStringList;
begin
  Result := 1;
  List := TStringList.Create;
  List.Text := Data;
  List.SaveToFile(FileName);
  List.Free;
  Result := 0;
end;

function LoadFromFile(FileName: String): String;
var List: TStringList;
begin
  Result := '';
  List := TStringList.Create;
  if FileExists(FileName) then
    List.LoadFromFile(FileName);
  Result := List.Text;
  List.Free;
end;

function TFocus.LoadNode(Node: PNode): PNode;
var
  Indexes: AString;
  Body: String;
begin
  Result := Node;
  Indexes := CreateIndexes(Node);
  Body := LoadFromFile(ToFileSystemName(Indexes) + NodeFileName);
  SetLength(Indexes, 0);
  if Body <> '' then
  begin
    Node.Attr := naLoad;
    Result := NewNode(Body);
    Result.Attr := naLoad;
  end;
end;

function TFocus.NewNode(Line: String): PNode;
var Link: TLink;
begin
  Link := TLink.Create(Line); //fastload
  Result := NewNode(Link);
  Link.Destroy;
end;

function TFocus.NewNode(Line: TLink): PNode;
var
  i: Integer;
  Node: PNode;
begin
  if (Line.ID = '') and (High(Line.Names) <> -1) then
    Line.ID := NextID;
  Result := NewIndex(Line.ID);
  if Result = nil then Exit;

  if (Result.Attr = naEmpty) and (Line.ID[1] <> '/') then
    Result := LoadNode(Result);

  if (Line.ID[1] <> '@') and (Result.Attr <> naLoad) then
    Result := AddLocal(Result);

  case Line.ID[1] of
    '!' : Result.Attr := naData;
    '@' : Result.Attr := naNode;
    '/' : Result.Attr := naModule;
    '0'..'9', '-':
        if Pos(',', Line.ID) = 0
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
    AddValue(Result, DecodeName(Copy(Line.ID, 2, MaxInt)));
  end;
  if Result.Attr = naInt then
  begin
    SetValue(Result, NewNode('!' + EncodeName(  IntToStr4(  StrToInt(Line.ID)))));
    Result.FType := NewNode('!' + ntInt);
  end;
  if Result.Attr = naFloat then
  begin
    SetValue(Result, NewNode('!' + EncodeName(FloatToStr8(StrToFloat(Line.ID)))));
    Result.FType := NewNode('!' + ntFloat);
  end;
  if Line.FElse <> nil then
  begin
    Result.FTrue := NewNode(Line.Value);
    Result.FTrue.ParentFTrue := Result;
    if Line.FElse.Name <> '' then
    begin
      Result.FElse := NewNode(Line.FElse);
      Result.FElse.ParentFElse := Result;
    end;
  end
  else
  if Line.Value <> nil then
    SetValue(Result, NewNode(Line.Value));
  if Line.FType <> nil then
    Result.FType := NewNode(Line.FType);
  for i:=0 to High(Line.Local) do
    AddLocal(Result, NewNode(Line.Local[i]));
  if Result.Source <> nil then
    Inc(Result.Source.RefCount);
  AddEvent(Result);
end;

procedure TFocus.AddEvent(Node: PNode);
var Event, NewEvent: PEvent;
begin
  Node.SaveTime := Now + GarbageInterval;  

  Event := TimeManager;
  while True do
  begin
    if Event = nil then
    begin
      Event := AllocMem(SizeOf(TEvent));
      Event.FBegin:= Node.SaveTime;
      Event.FEnd  := Node.SaveTime + GarbageInterval;
      SetLength(Event.Nodes, High(Event.Nodes) + 2);
      Event.Nodes[High(Event.Nodes)] := Node;
      if TimeManager = nil then
        TimeManager := Event;
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
      NewEvent.FEnd  := Node.SaveTime + GarbageInterval;
      SetLength(NewEvent.Nodes, High(NewEvent.Nodes) + 2);
      NewEvent.Nodes[High(NewEvent.Nodes)] := Node;
      Event.Next := NewEvent;
      Break;
    end;
    Event := Event.Next;
  end;
end;





procedure TFocus.RecursiveSave(Node: PNode);
var
  i: Integer;
  Indexes: AString;
begin
  Indexes := CreateIndexes(Node);
  ToFileSystemName(Indexes);
  SaveToFile(CreateIndexesDirTree(Indexes) + NodeFileName, GetNodeBody(Node));
  for i:=0 to High(Node.Index) do
    RecursiveSave(Node.Index[i]);
end;

procedure TFocus.RecursiveDispose(Node: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Index) do
    RecursiveDispose(Node.Index[i]);
  if Node <> Root then
    Dispose(Node)
  else
    SetLength(Root.Index, 0);
end;

procedure TFocus.Clear;
begin
  RecursiveSave(Root);
  RecursiveDispose(Root);
end;

procedure TFocus.SaveNode(Node: PNode);
var
  ParentIndex: PNode;
  Indexes: AString;
  IndexesPath: String;
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
  while (Node.SaveTime = 0) and (High(Node.Local) = -1) and (Node.RefCount = 0)
    and (High(Node.Index) = -1) and (Node.ParentValue = nil) do
  begin

    if Node.Attr <> naEmpty then
    begin
      Indexes := CreateIndexes(Node);
      ToFileSystemName(Indexes);
      IndexesPath := CreateIndexesDirTree(Indexes);
      SaveToFile(IndexesPath + 'Node.txt', GetNodeBody(Node));
    end;

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
    if Node.ParentParams <> nil then
    begin
      DeleteArrayValue(Node.ParentParams.Params, Node);
      SaveNode(Node.ParentParams);
    end;
    if Node.Source <> nil then
    begin
      Dec(Node.Source.RefCount);
      SaveNode(Node.Source);
    end;
    if Node.Value <> nil then
    begin
      if Node.Value.Attr = naData then
      begin
        Node.Attr := -1;
        Dispose(Node.Value);
      end
      else
        SaveNode(Node.ParentValue);
    end; 
    if Node.ParentFTrue <> nil then
    begin
      DeleteArrayValue(Node.ParentParams.Params, Node);
      SaveNode(Node.ParentParams);
    end;

    ParentIndex := Node.ParentIndex;
    DeleteArrayValue(ParentIndex.Index, Node);

    Node.Attr := -1;
    Dispose(Node);
    Dec(NodesCount);
    Node := ParentIndex;
  end;
end;


procedure TFocus.GarbageCollector;
var
  i: Integer;
  DeleteEvent: PEvent; //del
begin
  GarbageInterval := Now - GarbageLastRun;
  GarbageLastRun := Now;
  while (TimeManager <> nil) and (Now >= TimeManager.FEnd) do
  begin
    for i:=0 to High(TimeManager.Nodes) do
      if (TimeManager.Nodes[i].SaveTime >= TimeManager.FBegin) and
         (TimeManager.Nodes[i].SaveTime <= TimeManager.FEnd) then
      begin
        TimeManager.Nodes[i].SaveTime := 0;
        SaveNode(TimeManager.Nodes[i]);
      end;
    TimeManager.Nodes := nil;
    DeleteEvent := TimeManager;
    TimeManager := TimeManager.Next;
    Dispose(DeleteEvent);
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
  (*if Node.ParentName <> nil then
    Result := Result + {EncodeName}(GetIndex(Node.ParentName){, 2});*)
  Result := Result + GetIndex(Node);
  Result := Result + '$' + GetControls(Node);
  {if Node.FType <> nil then
    Result := Result + ':' + GetIndex(Node.FType);}
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
    if Node.FElse <> nil then
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


procedure TFocus.LoadModule(Node: PNode);
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
        Func.Attr := naDLLFunc;
        Func.Handle := GetProcAddress(Node.Handle, List.Strings[i]);
        AddLocal(Node, Func);
      end;
    end;
  end
  else
  if FileExt = '.node' then
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

procedure TFocus.Run(Node: PNode);
label NextNode; 
var FuncResult, i, n: Integer;
begin
  NextNode:
  if Node = nil then Exit;

  if Node.Attr = naModule then
    LoadModule(Node);
  for i:=0 to High(Node.Params) do  //run params
    Run(Node.Params[i]);
  if (Node.Source <> nil) and (((Node.Source.ParentLocal = Module) and (Node.Source.Next <> nil))
    or (Node.Source.Attr = naDLLFunc)) then   // run dll func
  begin
    for i:=0 to High(Node.Params) do
      AddParam(GetSource(Node), GetValue(Node.Params[i]), i);
    Run(Node.Source);                   //run source
    Node.Value := GetData(Node.Source);
  end;
  if Node.Attr = naDLLFunc then     //call dll func
    CallFunc(Node);
  if (Node.FTrue <> nil) or (Node.FElse <> nil) then     //node is if
  begin
    FuncResult := CompareWithZero(GetData(Node));   //del funcresult
    if (FuncResult = 1) and (Node.FTrue <> nil) then   //true
    begin
      Node := GetSource(Node.FTrue);
      Goto NextNode;
    end;
    if (FuncResult = 0) and (Node.FElse <> nil) then   //false
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
  Goto NextNode;    
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
      //for i:=1 to Result.RunCount do //del
      Run(Result);
      Result.Activate := 0;
    end;
  end;
end;

end.
