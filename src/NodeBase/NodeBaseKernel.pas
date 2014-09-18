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
    Path          : String;          //test
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
    FTrue         : PNode;
    FElse         : PNode;
    Prev          : PNode;
    Next          : PNode;

    Attr        : Integer;
    Count       : Integer;
    Time        : Double;
    RunCount    : Integer;
    Activate    : Integer;
    Handle      : Integer;
    Data        : String;
  end;

  TFocus = class
    ID        : Integer;
    Root      : PNode;
    Prev      : PNode;
    Module    : PNode;
    NodesCount: Integer;    //test

    constructor Create;

    function NextID: String;
	
	  function NewIndex(Name: String): PNode;

	  procedure SetSource(Node: PNode; Source: PNode);
	  function GetSource(Node: PNode): PNode;

	  function FindName(Index: PNode): PNode;
    function FindNameInNode(Node: PNode; Index: PNode): PNode;

    procedure SetVars(Node: PNode; Param, Value: String);
    function GetVars(Node: PNode): String;

    procedure SetFType(Node: PNode; FType: PNode);

	  procedure SetParam(Node: PNode; Param: PNode; Index: Integer);

    function SetValue(Node: PNode; Value: PNode): PNode;
    function GetValue(Node: PNode): PNode;

	  procedure SetData(Node: PNode; Value: String);

    procedure SetFTrue(Node: PNode; FTrue: PNode);
    procedure SetFElse(Node: PNode; FElse: PNode);

	  procedure SetNext(Node: PNode; Next: PNode);
    procedure NextNode(var PrevNode: PNode; NextNode: PNode);

    function SetLocal(Node: PNode; Local: PNode): PNode;
    function NewLocal(Node: PNode): PNode;

    function NewNode(Line: String): PNode; overload;
    function NewNode(Line: TLink): PNode; overload;

	  function LoadNode(Node: PNode): PNode;
	  procedure LoadModule(Node: PNode);

    procedure CallFunc(Node: PNode);
    procedure Run(Node: PNode);

    procedure RecursiveSave(Node: PNode);
    procedure RecursiveDispose(Node: PNode);
    procedure Clear;

	  function GetIndex(Node: PNode): String;
    function GetNodeBody(Node: PNode): String;

    function Execute(Line: String): PNode; virtual;
  end;

const

//NodeAttribyte
  naEmpty = 0;           
  naNode = 1;
  naData = 2;
  naWord = 3;
  naModule = 4;
  naDLLFunc = 5;
  naNumber = 6;
  naLoad = 7;
  naRoot = 8;

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


procedure TFocus.SetVars(Node: PNode; Param, Value: String);
begin
  Param := AnsiUpperCase(Param);
  Value := AnsiUpperCase(Value);
  if Param = 'ATTR'  then Node.Attr := StrToIntDef(Value, 0);
  if Param = 'TIME'  then Node.Time := StrToFloatDef(Value, Now);
  if Param = 'COUNT' then Node.Count := StrToIntDef(Value, 0);
  if Param = 'RUN'   then Node.RunCount := StrToIntDef(Value, 1);
  if Param = 'ACTIVATE' then Node.Activate := StrToIntDef(Value, 1);
  if Param = 'HANDLE' then Node.Handle := StrToIntDef(Value, 0);
end;


function TFocus.GetVars(Node: PNode): String;
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
  if Node.Handle <> 0 then
    Result := Result + '&' + 'HANDLE' + '=' + FloatToStr(Node.Handle);
  Delete(Result, 1, 1);
end;


function TFocus.NextID: String;
begin
  Inc(ID);
  Result := '@' + IntToStr(ID);
end;


function TFocus.NewIndex(Name: String): PNode;          //SetIndex
var
  i, j, Index: Integer;
  function AddIndex(Node: PNode; Name: Char): PNode;
  begin
    SetLength(Node.Index, Length(Node.Index) + 1);
    Result := AllocMem(SizeOf(TNode));
    Node.Index[High(Node.Index)] := Result;
    Result.Attr := naEmpty;
    Result.Name := Name;
    Result.ParentIndex := Node;
    Result := Node.Index[High(Node.Index)];
    Inc(NodesCount);
    Result.Path := GetIndex(Result); //test
  end;
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


procedure TFocus.SetSource(Node: PNode; Source: PNode);
begin
  Node.Source := Source;
end;


function TFocus.GetSource(Node: PNode): PNode;
begin
  Result := Node;
  if Node = nil then Exit;
  while Result.Source <> nil do
    Result := Result.Source;
end;


function TFocus.FindName(Index: PNode): PNode;
var Node, Find: PNode;
begin
  Result := nil;
  if Index = nil then Exit;
  if Prev = nil
  then Node := Module
  else Node := Prev;
  while Node <> nil do
  begin
    Find := FindNameInNode(Node, Index);
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


function TFocus.FindNameInNode(Node: PNode; Index: PNode): PNode;
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
        Result := FindNameInNode(Local, Index);
        if Result <> nil then Exit;
      end;
      if Local.ParentName = Index then
      begin
        Result := Local;
        Exit;
      end;
    end;
end;


procedure TFocus.SetFType(Node: PNode; FType: PNode);
begin
  Node.FType := FType;
end;


procedure TFocus.SetParam(Node: PNode; Param: PNode; Index: Integer);
begin
  if Param.FType <> nil then
  begin
    Param.Source := nil;
    SetLength(Node.Params, Length(Node.Params) + 1);
    Node.Params[High(Node.Params)] := Param;
  end
  else
  begin
    if Index = Length(Node.Params) then
    begin
      SetLength(Node.Params, Length(Node.Params) + 1);
      Node.Params[Index] := Param;
    end
    else
    if Index <= High(Node.Params) then
    begin
      {if Node.Attr = naDLLFunc then
      begin
        if Node.Params[Index] <> Param then
          Node.Params[Index] := Param;
      end
      else}
      if Node.Params[Index] <> Param then
        Node.Params[Index].Value := Param;

    end;
  end;
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
    SetLength(ValueStack, Length(ValueStack) + 1);
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


procedure TFocus.SetData(Node: PNode; Value: String);
begin
  Node.Data := Value;
end;


procedure TFocus.SetFTrue(Node: PNode; FTrue: PNode);
begin
  Node.FTrue := FTrue;
end;


procedure TFocus.SetFElse(Node: PNode; FElse: PNode);
begin
  Node.FElse := FElse;
end;


procedure TFocus.SetNext(Node: PNode; Next: PNode);
begin
  Node.Next := Next;
  Node.Next.Prev := Node;
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
        SetLocal(Module, NextNode);
    end;
  PrevNode := NextNode;
end;


function TFocus.SetLocal(Node: PNode; Local: PNode): PNode;
begin
  SetLength(Node.Local, Length(Node.Local) + 1);
  if Node.Attr = naEmpty
  then Local.ParentName  := Node
  else Local.ParentLocal := Node;
  Node.Local[High(Node.Local)] := Local;
  Result := Local;
end;


function TFocus.NewLocal(Node: PNode): PNode;
begin
  Result := SetLocal(Node, NewIndex(NextID));
end;


function TFocus.NewNode(Line: String): PNode;
var Link: TLink;
begin
  Link := TLink.Create(Line);
  Result := NewNode(Link);
  Link.Destroy;
end;


function TFocus.NewNode(Line: TLink): PNode;
var
  i: Integer;
begin
  Result := NewIndex(Line.ID);
  if Result = nil then Exit;

  if Line.ID = '@146' then
    Line.ID := '@146';

  if Line.ID[1] <> '@' then
    Result := NewLocal(Result)
  else
  if Result.Attr = naEmpty then
    LoadNode(Result);

  if Result.Attr <> naLoad then   //Initialization
  begin
    case Line.ID[1] of
      '@' : Result.Attr := naNode;
      '/' : Result.Attr := naModule;
      '!' : Result.Attr := naData;
      '0'..'9', '-': Result.Attr := naNumber;
      else  Result.Attr := naWord;
    end;

    if Result.Attr = naWord then
        Result.Source := FindName(Result.ParentName);
  end;

  if Line.Source <> '' then
  begin
    if (Result.Attr = naWord) and (Result.Attr <> naLoad) then
    begin  //hardcode
      SetSource(GetSource(Result), NewNode(Line.Source));
      Result := GetSource(Result)
    end
    else
      SetSource(Result, NewNode(Line.Source));
  end;

  if Line.Name <> '' then
    Result.ParentName := NewIndex(Line.Name);

  for i:=0 to High(Line.Names) do
    SetVars(Result, Line.Names[i], Line.Values[i]);

  for i:=0 to High(Line.Params) do
    SetParam(Result, NewNode(Line.Params[i]), i);

  if Result.Attr = naNumber then
  begin
    if Pos(',', Line.ID) = 0
    then Line.ID := '!' + IntToStr4(    StrToIntDef(Line.ID, 0))
    else Line.ID := '!' + FloatToStr8(StrToFloatDef(Line.ID, 0));
    Result.Attr := naData;
  end;

  if Result.Attr = naData then
    SetData(Result, DecodeStr(Copy(Line.ID, 2, MaxInt)));

  if Line.FElse <> nil then
  begin
    Result.FTrue := NewNode(Line.Value);
    if Line.FElse.Name <> '' then
      Result.FElse := NewNode(Line.FElse);
  end
  else
  if Line.Value <> nil then
  begin
    if Line.Value.ID[1] = '!'
    then SetData(Result, DecodeStr(Copy(Line.Value.ID, 2, MaxInt)))
    else SetValue(Result, NewNode(Line.Value));
  end;

  if Line.FType <> nil then
    SetFType(Result, NewNode(Line.FType));
  for i:=0 to High(Line.Local) do
    SetLocal(Result, NewNode(Line.Local[i]));
  if Line.Next <> '' then
    SetNext(Result, NewNode(Line.Next));
end;


function TFocus.LoadNode(Node: PNode): PNode;
var
  Indexes: AString;
  Body, Path: String;
begin
  if Node = nil then Exit;
  Node.Attr := naLoad;

  SetLength(Indexes, 0);
  while Node <> nil do
  begin
    SetLength(Indexes, Length(Indexes) + 1);
    Indexes[High(Indexes)] := Node.Name;
    Node := Node.ParentIndex;
  end;
  Path := ToFileSystemName(Indexes) + NodeFileName;
  Body := LoadFromFile(Path);
  SetLength(Indexes, 0);

  if Body <> '' then
    NewNode(Body); //fastload
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
      Node.Handle := GetFunctionList(FileName, List);
      for i:=0 to List.Count-1 do
      begin
        Func := NewNode(List.Strings[i]);
        Func.Attr := naDLLFunc;
        Func.Handle := GetProcAddress(Node.Handle, List.Strings[i]);
        SetLocal(Node, Func);
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
    Value := GetValue(Node.Params[i]);
    if (Value = nil) or (Value.Data = '') then Exit
    else
    begin
      Param := Value.Data;

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
    SetLength(Stack, Length(Stack) + 1);
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
    MOV BVal, EAX
    MOV IfFloat, 0
    JMP @2
    @1:
    FSTP QWORD PTR [DBVal]     
    MOV IfFloat, 1
    @2:
  end;

  if IfFloat = 0
  then SetValue(Node, NewNode('!' + EncodeStr(IntToStr4(BVal))))
  else SetValue(Node, NewNode('!' + EncodeStr(FloatToStr8(DBVal))));

end;


procedure TFocus.Run(Node: PNode);
label NextNode;
var
  FuncResult, i, n: Integer;
  Str: String;
  function CompareWithZero(Node: PNode): Integer;
  var i: Integer;
  begin
    Result := -1;
    if Node <> nil then
    begin
      Result := 0;
      for i:=0 to Length(Node.Data) do
        Inc(Result, Ord(Node.Data[i]));
    end;
  end;
begin
  NextNode:
  if Node = nil then Exit;

  if Node.Attr = naModule then
    LoadModule(Node);
  for i:=0 to High(Node.Params) do 
    Run(Node.Params[i]);
  if (Node.Source <> nil) and (((Node.Source.ParentLocal = Module) and (Node.Source.Next <> nil))   //recode  2
    or (Node.Source.Attr = naDLLFunc)) then
  begin
    for i:=0 to High(Node.Params) do
      SetParam(GetSource(Node), GetValue(Node.Params[i]), i);
    Run(Node.Source);
  end;
  if Node.Attr = naDLLFunc then
    CallFunc(Node);
  if (Node.FTrue <> nil) or (Node.FElse <> nil) then
  begin
    FuncResult := CompareWithZero(GetValue(Node));
    if (FuncResult = 1) and (Node.FTrue <> nil) then
    begin
      Node := GetSource(Node.FTrue);
      Goto NextNode;
    end;
    if (FuncResult = 0) and (Node.FElse <> nil) then
    begin
      Node := GetSource(Node.FElse);
      Goto NextNode;
    end;
  end
  else
  if (Node.Source <> nil) and (Node.Value <> nil) then
  begin
    Run(Node.Value);
    Node.Source.Value := GetValue(Node.Value);
  end;

  Node := Node.Next;
  Goto NextNode;
end;


procedure TFocus.RecursiveSave(Node: PNode);
var
  i: Integer;
  Indexes: AString;
  Body: String;
  Buf: PNode;
begin
  Buf := Node;
  SetLength(Indexes, 0);
  while Buf <> nil do
  begin
    SetLength(Indexes, Length(Indexes) + 1);
    Indexes[High(Indexes)] := Buf.Name;
    Buf := Buf.ParentIndex;
  end;
  if (Length(Indexes) > 1) and (Indexes[High(Indexes) - 1] <> '@') then Exit;
  ToFileSystemName(Indexes);
  Body := GetNodeBody(Node);
  SaveToFile(CreateDir(Indexes) + NodeFileName, Body);
  for i:=0 to High(Node.Index) do
    RecursiveSave(Node.Index[i]);
end;


procedure TFocus.RecursiveDispose(Node: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Index) do
    RecursiveDispose(Node.Index[i]);
  if Node <> Root
  then Dispose(Node)
  else SetLength(Root.Index, 0);
end;


procedure TFocus.Clear;
begin
  RecursiveSave(Root);
  RecursiveDispose(Root);
  Prev := nil;
  Module := nil;
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
    Result := Result + GetIndex(Node.ParentName);
  Result := Result + GetIndex(Node);
  Result := Result + '$' + GetVars(Node);
  if Node.FType <> nil then
    Result := Result + ':' + GetIndex(Node.FType);
  Str := '';
  for i:=0 to High(Node.Params) do
    Str := Str + GetIndex(Node.Params[i]) + '&';
  if Str <> '' then
  begin
    Delete(Str, Length(Str), 1);
    Result := Result + '?' + Str;
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
    if Node.Attr = naData then
      Result := Result + '#!' + EncodeStr(Node.Data)
    else
    if Node.Value <> nil then
      Result := Result + '#' + GetIndex(Node.Value);

  if Node.Next <> nil then
    Result := Result + #10 + GetIndex(Node.Next);
  for i:=0 to High(Node.Local) do
    Result := Result + #10#10 + GetIndex(Node.Local[i]);
end;


function TFocus.Execute(Line: String): PNode;
var
  Data: String;
  i: Integer;
begin
  //Line
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
  end;
end;

end.