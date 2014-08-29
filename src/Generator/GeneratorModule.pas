unit GeneratorModule;

interface

uses
  Dialogs, SysUtils, NodeBaseKernel, GeneratorUtils;

type

  TGFocus = class (TFocus) //TGeneratorFocus
  public
    procedure CreateFunc(Node: PNode; Level: Integer);
    procedure CreateData(Node: PNode);
    procedure CreateLocalVar(Node: PNode);
    procedure CreateFuncHead(Node: PNode; Level: Integer);
    procedure SetParams(Node: PNode; FuncNode: PNode);
    procedure CreateSequence(FuncNode: PNode);
    procedure CreateIfElseWhile(FuncNode: PNode);
    procedure CreateFuncBody(Node: PNode; Level: Integer);
    function NewRandomNode(Node: PNode): PNode;
    function NewRandomType: String;
    function Generate: PNode;
  end;

const
  LocalCount = 2;
  Data4Count = 1;
  Data8Count = 2;

  IntBeginRange = -3;
  IntCenterRange = 0;
  IntEndRange = 10;
  FracBeginRange = 0;  // >= 0
  FracCenterRange = 0;
  FracEndRange = 10;

  DataSCount = 0;
  FunctionCount = 3;
  FunctionParamsCount = 2;
  FunctionSequenceCount = 10;
  FunctionLevel = 1;

  IfWhileElseFrequency: Array[0..3] of Integer = (0{null}, 1{If}, 1{While}, 1{else});
  IfWhileElseCount = 1;

var
  GFocus: TGFocus;

implementation


procedure TGFocus.CreateLocalVar(Node: PNode);
var i: Integer;
begin
  for i:=0 to Random(LocalCount) do
    AddLocal(Node, NewNode(NextID));
end;

procedure TGFocus.CreateData(Node: PNode);
var i: Integer;
begin
  for i:=0 to Random(Data4Count) do
    AddLocal(Node, NewNode(
      IntToStr(CauchyRandom(IntBeginRange, IntCenterRange, IntEndRange))));
  for i:=0 to Random(Data8Count) do
    AddLocal(Node, NewNode(
      IntToStr(CauchyRandom(IntBeginRange, IntCenterRange, IntEndRange)) + ',' +
      IntToStr(CauchyRandom(FracBeginRange, FracCenterRange, FracEndRange)) ));
end;

function TGFocus.NewRandomNode(Node: PNode): PNode;
var Index: Integer; Arr: TIntegerDynArray;
begin
  Result := nil;
  SetLength(Arr, 4);
  Arr[0] := Length(Node.Local);
  Arr[1] := Length(Module.Local);
  Arr[2] := Length(Node.Params);
  Arr[3] := IfThen(Node.Value = nil, 0, 1);
  case Random(Arr, Index) of
    0: Result := Node.Local[Index];
    1: Result := Module.Local[Index];
    2: Result := Node.Params[Index];
    3: Result := Node.Value;
  end;
  SetLength(Arr, 0);
  if Result.Attr = naModule then
    Result := NewRandomNode(Result);
  Result := NewNode(GetIndex(Result) + '^' + NextID);
end;

function TGFocus.NewRandomType(): String;
begin
  if Random(100) > 50
  then Result := 'int'
  else Result := 'float';
end;

procedure TGFocus.CreateFuncHead(Node: PNode; Level: Integer);
var
  i, j: Integer;
  FuncNode: PNode;
begin
  if Level <= 0 then Exit;
  for i:=0 to Random(FunctionCount) do
  begin
    FuncNode := NewNode(NextID);
    AddLocal(Node, FuncNode);
    for j:=0 to Random(FunctionParamsCount) do
      AddParam(FuncNode, NewNode(NextID + ':' + NewRandomType), j);
    SetValue(FuncNode, NewNode(NextID));
  end;
end;

procedure TGFocus.SetParams(Node, FuncNode: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Params) do
    AddParam(Node, NewRandomNode(FuncNode), i);
end;

procedure TGFocus.CreateSequence(FuncNode: PNode);
var
  i: Integer;
  Node: PNode;
  NewNode: PNode;
begin
  Node := FuncNode;
  for i:=0 to Random(FunctionSequenceCount) do
  begin
    NewNode := NewRandomNode(FuncNode);
    if GetSource(NewNode).Attr = naDllFunc then Continue;
    NextNode(Node, NewNode);
    SetValue(Node, NewRandomNode(FuncNode));
    if Node.Value.Source.Params <> nil then
      SetParams(Node.Value, FuncNode);
  end;
end;

procedure TGFocus.CreateFuncBody(Node: PNode; Level: Integer);
var
  i: Integer;
begin
  for i:=0 to High(Node.Local) do
    if Node.Local[i].Params <> nil then
      CreateFunc(Node.Local[i], Level - 1);
end;

procedure TGFocus.CreateIfElseWhile(FuncNode: PNode);
var
  j, i, IfWhileElse: Integer;
  FirstPos, SecondPos, ThirdPos: Integer;
  FirstNode, SecondNode, ThirdNode: PNode;
  ElseNode: PNode;
  Node: PNode;
begin
  FuncNode := FuncNode.Next;
  if FuncNode = nil then Exit;

  for j:=1 to IfWhileElseCount do
  begin

    i := 0;
    Node := FuncNode;
    while Node.Next <> nil do
    begin
      Inc(i);
      Node := Node.Next;
    end;

    FirstPos  := Random(i);
    SecondPos := Random(i);
    ThirdPos  := Random(i);

    i := 0;
    Node := FuncNode;
    while Node <> nil do
    begin
      if i = FirstPos  then FirstNode  := Node;
      if i = SecondPos then SecondNode := Node;
      if i = ThirdPos  then ThirdNode  := Node;
      Inc(i);
      Node := Node.Next;
    end;

    IfWhileElse := Random(IfWhileElseFrequency);

    if IfWhileElse = 1 then   // if
    begin
      NewNode(GetIndex(FirstNode) + '#|' + GetIndex(SecondNode));
    end;

    if IfWhileElse = 2 then  // while
    begin
      NewNode(GetIndex(FirstNode) + '#|' + GetIndex(SecondNode));
      ElseNode := NewNode('1#' + GetIndex(FirstNode) + '|');
      NextNode(SecondNode.Prev, ElseNode);
      NextNode(ElseNode, SecondNode);
    end;

    if IfWhileElse = 3 then // if else
    begin
      NewNode(GetIndex(FirstNode) + '#|' + GetIndex(SecondNode));
      ElseNode := NewNode('1#' + GetIndex(ThirdNode) + '|');
      NextNode(SecondNode.Prev, ElseNode);
      NextNode(ElseNode, SecondNode);
    end;

  end;
end;

procedure TGFocus.CreateFunc(Node: PNode; Level: Integer);
begin
  CreateLocalVar(Node);
  CreateData(Node);
  CreateFuncHead(Node, Level);
  CreateSequence(Node);
  CreateIfElseWhile(Node);
  CreateFuncBody(Node, Level);
end;

function TGFocus.Generate: PNode;
begin
  Result := NewNode(NextID + '#' + NextID);
  CreateFunc(Result, FunctionLevel);
  Run(Result);
end;

end.
