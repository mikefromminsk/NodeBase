unit Generator;

interface

uses
  Dialogs, SysUtils, Kernel, Utils;

const

  Data4Count = 1;
  Data8Count = 2;
  LocalVarCount = 2;
  SubLevel = 1;
  SubFuncCount = 3;
  SubFuncParamsCount = 2;
  SequenceCount = 10;
  IfWhileElseCount = 1;

  IntRange: ARange = (-3{Begin}, 0{Center}, 10{End});
  FracRange: ARange = (0{Begin>=0}, 0{Center}, 10{End});
  IfWhileElseFrequency: Array[0..2] of Integer = (1{If}, 0{While}, 0{else});

type

  TGenerator = class (TKernel)

    function GetRandomSource(FuncNode: PNode): PNode;
    function NewRandomNode(FuncNode: PNode): PNode;

    procedure CreateData(Node: PNode);

    procedure CreateLocalVar(Node: PNode);

    procedure CreateSubFuncParams(Node: PNode; Level: Integer);
    procedure CreateSubFunc(Node: PNode; Level: Integer);

    procedure CreateSequence(FuncNode: PNode);

    procedure CreateParams(Node: PNode; FuncNode: PNode);

    procedure CreateIfElseWhile(FuncNode: PNode);

    procedure CreateFunc(Node: PNode; Level: Integer);

    function Generate: PNode;
  end;


implementation


function TGenerator.GetRandomSource(FuncNode: PNode): PNode;
var
  Index: Integer;
  Arr: AInteger;
begin
  SetLength(Arr, 4);
  Arr[0] := Length(FuncNode.Local);
  Arr[1] := Length(Module.Local);
  Arr[2] := Length(FuncNode.Params);
  Arr[3] := IfThen(FuncNode.Value = nil, 0, 1);
  case Random(Arr, Index) of
    0: Result := FuncNode.Local[Index];
    1: Result := Module.Local[Index];
    2: Result := FuncNode.Params[Index];
    3: Result := FuncNode.Value;
  end;
  SetLength(Arr, 0);
  if Result.Attr = naModule then
    Result := GetRandomSource(Result);
end;


function TGenerator.NewRandomNode(FuncNode: PNode): PNode;
begin
  Result := NewNode(NextID);
  SetSource(Result, GetRandomSource(FuncNode));
end;


procedure TGenerator.CreateData(Node: PNode);
var i: Integer;
begin
  for i:=0 to Random(Data4Count) do
    SetLocal(Node, NewNode( IntToStr(RandomRange(IntRange)) ));
  for i:=0 to Random(Data8Count) do
    SetLocal(Node, NewNode(
      IntToStr(RandomRange(IntRange)) + ',' + IntToStr(RandomRange(FracRange)) ));
end;


procedure TGenerator.CreateLocalVar(Node: PNode);
var i: Integer;
begin
  for i:=0 to Random(LocalVarCount) do
    SetLocal(Node, NewNode(NextID));
end;


procedure TGenerator.CreateSubFuncParams(Node: PNode; Level: Integer);
var
  i, j: Integer;
  FuncNode: PNode;
begin
  if Level <= 0 then Exit;
  for i:=0 to Random(SubFuncCount) do
  begin
    FuncNode := NewNode(NextID);
    SetLocal(Node, FuncNode);
    for j:=0 to Random(SubFuncParamsCount) do
      SetParam(FuncNode, NewNode(NextID), j);
    SetValue(FuncNode, NewNode(NextID));
  end;
end;


procedure TGenerator.CreateSubFunc(Node: PNode; Level: Integer);
var i: Integer;
begin
  for i:=0 to High(Node.Local) do
    if Node.Local[i].Params <> nil then
      CreateFunc(Node.Local[i], Level - 1);
end;


procedure TGenerator.CreateSequence(FuncNode: PNode);
var
  i: Integer;
  Node: PNode;
  NewNode: PNode;
begin
  Node := FuncNode;
  for i:=0 to Random(SequenceCount) do
  begin
    NewNode := NewRandomNode(FuncNode);
    if GetSource(NewNode).Attr = naDllFunc then Continue;
    NextNode(Node, NewNode);
    SetValue(Node, NewRandomNode(FuncNode));
    if Node.Value.Source.Params <> nil then
      CreateParams(Node.Value, FuncNode);
  end;
end;


procedure TGenerator.CreateParams(Node, FuncNode: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Params) do
    SetParam(Node, NewRandomNode(FuncNode), i);
end;


procedure TGenerator.CreateIfElseWhile(FuncNode: PNode);
var
  j, i, IfWhileElse: Integer;
  FirstPos, SecondPos, ThirdPos: Integer;
  FirstNode, SecondNode, ThirdNode: PNode;
  ExitNode: PNode;
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

    if IfWhileElse = 0 then   // if
    begin
      SetFElse(FirstNode, SecondNode);
    end;

    {if IfWhileElse = 1 then  // while
    begin
      SetFElse(FirstNode, SecondNode);
      ElseNode := NewNode('1#' + GetIndex(FirstNode) + '|');
      NextNode(SecondNode.Prev, ElseNode);
      NextNode(ElseNode, SecondNode);
    end;

    if IfWhileElse = 2 then // if else
    begin
      SetFElse(FirstNode, SecondNode);
      ExitNode := NewNode('1#' + GetIndex(ThirdNode) + '|');
      NextNode(SecondNode.Prev, ElseNode);
      NextNode(ElseNode, SecondNode);
    end; }

  end;
end;


procedure TGenerator.CreateFunc(Node: PNode; Level: Integer);
begin
  CreateLocalVar(Node);
  CreateData(Node);
  CreateSubFuncParams(Node, Level);
  CreateSequence(Node);
  CreateIfElseWhile(Node);
  CreateSubFunc(Node, Level);
end;


function TGenerator.Generate: PNode;
begin
  Result := NewNode(NextID);
  SetValue(Result, NewNode(NextID));
  CreateFunc(Result, SubLevel);
  Run(Result);
end;


end.
