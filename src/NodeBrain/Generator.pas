unit Generator;

interface

uses
  Dialogs, SysUtils, Kernel, Utils;

const

  Data8Count = 2;
  LocalVarCount = 2;
  SubLevel = 1;
  SubFuncCount = 3;
  SubFuncParamsCount = 2;
  SequenceCount = 10;
  IfWhileElseCount = 1;

  IntRange : ARange = (-3, 0, 10);  // -3 < x < 10
  FracRange: ARange = ( 0, 0, 10);  //  0 < x < 10
  IfWhileElseFrequency: Array[0..2] of Integer = (1{If}, 0{While}, 0{else});



type

  TGenerator = class (TKernel)

    function GetRandomSource(FuncNode: TNode): TNode;
    function NewRandomNode(FuncNode: TNode): TNode;

    procedure CreateData(Node: TNode);

    procedure CreateLocalVar(Node: TNode);

    procedure CreateSubFuncParams(Node: TNode; Level: Integer);
    procedure CreateSubFunc(Node: TNode; Level: Integer);

    procedure CreateSequence(FuncNode: TNode);

    procedure CreateParams(Node: TNode; FuncNode: TNode);

    procedure CreateIfElseWhile(FuncNode: TNode);

    procedure CreateFunc(Node: TNode; Level: Integer);

    function GenerateNode: TNode;

    procedure FindUnknown(Node: TNode; var Unknown: ANode);

    procedure FindSolution(Task: TNode);

  end;


implementation


function TGenerator.GetRandomSource(FuncNode: TNode): TNode;
var
  Index: Integer;
  Arr: AInteger;
begin
  SetLength(Arr, 4);
  Arr[0] := Length(FuncNode.Local);
  Arr[1] := Length(FUnit.Local);
  Arr[2] := Length(FuncNode.Params);
  Arr[3] := IfThen(FuncNode.Value = nil, 0, 1);
  case Random(Arr, Index) of
    0: Result := FuncNode.Local[Index];
    1: Result := FUnit.Local[Index];
    2: Result := FuncNode.Params[Index];
    3: Result := FuncNode.Value;
  end;
  SetLength(Arr, 0);
  if Result.FType = ntModule then
    Result := GetRandomSource(Result);
end;


function TGenerator.NewRandomNode(FuncNode: TNode): TNode;
begin
  Result := NewNode(NextID);
  SetSource(Result, GetRandomSource(FuncNode));
end;

procedure TGenerator.CreateData(Node: TNode);
var i: Integer;
begin
  for i:=0 to Random(Data8Count) do
    SetLocal(Node, NewNode(
      IntToStr(RandomRange(IntRange)) + ',' + IntToStr(RandomRange(FracRange)) ));
end;


procedure TGenerator.CreateLocalVar(Node: TNode);
var i: Integer;
begin
  for i:=0 to Random(LocalVarCount) do
    SetLocal(Node, NewNode(NextID));
end;


procedure TGenerator.CreateSubFuncParams(Node: TNode; Level: Integer);
var
  i, j: Integer;
  FuncNode: TNode;
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


procedure TGenerator.CreateSubFunc(Node: TNode; Level: Integer);
var i: Integer;
begin
  for i:=0 to High(Node.Local) do
    if Node.Local[i].Params <> nil then
      CreateFunc(Node.Local[i], Level - 1);
end;


procedure TGenerator.CreateSequence(FuncNode: TNode);
var
  i: Integer;
  Node: TNode;
  NewNode: TNode;
begin
  Node := FuncNode;
  for i:=0 to Random(SequenceCount) do
  begin
    NewNode := NewRandomNode(FuncNode);
    if GetSource(NewNode).FType = ntDllFunc then Continue;
    NextNode(Node, NewNode);
    SetValue(Node, NewRandomNode(FuncNode));
    if Node.Value.Source.Params <> nil then
      CreateParams(Node.Value, FuncNode);
  end;
end;


procedure TGenerator.CreateParams(Node, FuncNode: TNode);
var i: Integer;
begin
  for i:=0 to High(Node.Params) do
    SetParam(Node, NewRandomNode(FuncNode), i);
end;


procedure TGenerator.CreateIfElseWhile(FuncNode: TNode);
var
  j, i, IfWhileElse: Integer;
  FirstPos, SecondPos, ThirdPos: Integer;
  FirstNode, SecondNode, ThirdNode: TNode;
  ExitNode: TNode;
  Node: TNode;
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


procedure TGenerator.CreateFunc(Node: TNode; Level: Integer);
begin
  CreateLocalVar(Node);
  CreateData(Node);
  CreateSubFuncParams(Node, Level);
  CreateSequence(Node);
  CreateIfElseWhile(Node);
  CreateSubFunc(Node, Level);
end;


function TGenerator.GenerateNode: TNode;
begin
  Result := NewNode(NextID);
  SetValue(Result, NewNode(NextID));
  CreateFunc(Result, SubLevel);
end;









procedure TGenerator.FindUnknown(Node: TNode; var Unknown: ANode);  //out
var i: Integer;
begin
  for i:=0 to High(Node.Params) do
  begin
    if Node.Params[i].Source = nil then
      Node.Params[i].Attr[naGenerate] := 'T';

    if Node.Params[i].Attr[naGenerate] <> '' then
      AddItem(Unknown, Node.Params[i]);
  end;
end;


procedure TGenerator.FindSolution(Task: TNode);
var
  Unknown: ANode;
  Branch: TNode;
  i: Integer;
begin
  //Set Branch
  Branch := NewNode(Root.Attr[naStartID]);

  FindUnknown(Task, Unknown);

  //GenerateNodes
  for i:=0 to High(Unknown) do
    Unknown[i].Source := GenerateNode;

  Run(Task);
  if Compare(GetValue(Task)) then
  begin
    SaveBranch(Branch);

    for i:=0 to High(Unknown) do
      SetLocal(Unknown[i], Unknown[i].Source);
  end;
  FreeBranch(Branch);

  Unknown := nil;
end;



end.
