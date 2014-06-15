unit GModule;

interface

uses
  MetaBaseModule, Dialogs, Types, Math, SysUtils;

type
  TG = class (TFocus)
  public
    function Execute(Line: String): PNode; override;
    function RandomIndexInArr(Arr: TIntegerDynArray): Integer;
    function NewRandomNode(Node: PNode; ToNode: PNode = nil): PNode;
    procedure CreateModule(Node: PNode);
      procedure CreateLocal(Node: PNode);
        procedure CreateUses(Node: PNode);
        procedure CreateObjects(Node: PNode);
        procedure CreateData(Node: PNode);
        procedure CreateFunctionHead(Node: PNode);
          procedure CreateParameters(Node: PNode);
          procedure CreateResult(Node: PNode);
      procedure CreateFunctionBody(Node: PNode);
    procedure CreateSequence(FuncNode: PNode);
    procedure SetParameters(Node: PNode; ParentNode: PNode);              {
    procedure CreateIf(Node: PNode);                  
    procedure CreateFor(Node: PNode);                  }
  end;
var
  RandomVariable: Integer;
  
const
  LocalCount = 10;
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
  FunctionParamsCount = 3;
  FunctionSequenceCount = 10;

implementation



function Random(Range: Integer): Integer;    //предсказуемый рандом
begin
  Inc(RandomVariable);
  Result := RandomVariable mod Range;
end;

function CauchyRandomMod(BeginRange, CenterRange, EndRange: Integer): Integer;
var MaxRange, MinRange: Integer;
begin
  repeat
    MaxRange := Max(CenterRange - BeginRange, EndRange - CenterRange);
    MinRange := Min(CenterRange - BeginRange, EndRange - CenterRange);
    Result := Round(Tan(PI * (Random(MaxInt) / MaxInt - 0.5)));
    Result := Result mod (MaxRange + 1);
    Result := Result + CenterRange;
  until (Result >= BeginRange) and (Result <= EndRange);
end;

function TG.RandomIndexInArr(Arr: TIntegerDynArray): Integer;
var i, Index: Integer;
begin
  Index := Random(MaxInt) mod SumInt(Arr);
  for i:=0 to High(Arr) do
  begin
    if Index - Arr[i] < 0 then
    begin
      Result := i;
      Exit;
    end;
    Index := Index - Arr[i];
  end;
end;




procedure TG.CreateUses(Node: PNode);
var i: Integer;
begin
  for i:=0 to High(Module.Local) do
    AddLocal(Node, Module.Local[i]);
end;

procedure TG.CreateObjects(Node: PNode);
var i: Integer;
begin
  for i:=0 to LocalCount do
    AddLocal(Node, NewNode(NextId));
end;

procedure TG.CreateData(Node: PNode);
var i: Integer;
begin
  for i:=0 to Data4Count do
    AddLocal(Node, NewNode(
      IntToStr(CauchyRandomMod(IntBeginRange, IntCenterRange, IntEndRange))));
  for i:=0 to Data8Count do
    AddLocal(Node, NewNode(
      IntToStr(CauchyRandomMod(IntBeginRange, IntCenterRange, IntEndRange)) + ',' +
      IntToStr(CauchyRandomMod(FracBeginRange, FracCenterRange, FracEndRange)) ));
end;

function TG.NewRandomNode(Node: PNode; ToNode: PNode = nil): PNode;
var Index: Integer; Arr: TIntegerDynArray;
begin
  SetLength(Arr, 4);
  Arr[0] := High(Node.Local) + 1;
  Arr[1] := High(Node.Params) + 1;
  Arr[2] := IfThen(Node.Value = nil, 0, 1);
  case RandomIndexInArr(Arr) of
    0: Result := Node.Local[Index];
    1: Result := Node.Params[Index];
    2: Result := Node.Value;
  end;
  SetLength(Arr, 0);

  if Result = ToNode then
    Result := NewRandomNode(Node);

  if Result.Attr = naFile then
    Result := NewRandomNode(Result);

  Result := NewNode(GetIndex(Result) + '^' + NextID);
end;


procedure TG.CreateParameters(Node: PNode);
var
  i: Integer;
  RandomeNode, TypeNode: PNode;
begin
  for i:=0 to FunctionParamsCount do
  begin
    repeat
      RandomeNode := NewRandomNode(Node.ParentLocal);
    until RandomeNode.FType = nil;
    TypeNode := GetType(RandomeNode);
    AddParam(Node, NewNode(NextID + ':' + TypeNode.Name), i);
  end;
end;

procedure TG.CreateResult(Node: PNode);
var
  RandomeNode, TypeNode: PNode;
begin
  repeat
    RandomeNode := NewRandomNode(Node.ParentLocal);
  until RandomeNode.FType = nil;
  TypeNode := GetType(RandomeNode);
  NewNode(GetIndex(Node) + '#' + NextId + ':' + TypeNode.Name);
end;

procedure TG.CreateFunctionHead(Node: PNode);
var
  i: Integer;
  Func: PNode;
begin
  for i:=0 to FunctionCount do
  begin
    Func := NewNode(NextId);
    AddLocal(Node, Func);
    CreateParameters(Func);
    CreateResult(Func);
  end;
end;

procedure TG.SetParameters(Node: PNode; ParentNode: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Params) do
    AddParam(Node, NewRandomNode(ParentNode), i);
end;

procedure TG.CreateSequence(FuncNode: PNode);
var
  i: Integer;
  PrevNode: PNode;
begin
  PrevNode := FuncNode;
  for i:=0 to FunctionSequenceCount do
  begin
    NextNode(PrevNode, NewRandomNode(FuncNode.ParentLocal));
    if PrevNode.Params <> nil then
      SetParameters(PrevNode, FuncNode)
    else
    begin
      SetValue(PrevNode, NewRandomNode(FuncNode.ParentLocal));
      if PrevNode.Value.Params <> nil then
        SetParameters(PrevNode.Value, FuncNode);
    end;
  end;
end;

procedure TG.CreateFunctionBody(Node: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Local) do
    if Node.Local[i].Params <> nil then
    begin
      CreateLocal(Node.Local[i]);
      CreateSequence(Node.Local[i]);
    end;
end;

procedure TG.CreateLocal(Node: PNode);
begin
  CreateUses(Node);
  CreateObjects(Node);
  CreateData(Node);
  CreateFunctionHead(Node);
end;

procedure TG.CreateModule(Node: PNode);
begin
  CreateLocal(Node);
  CreateFunctionBody(Node);
end;

function TG.Execute(Line: String): PNode;
begin
  Result := inherited Execute(Line);
  CreateModule(Result);
end;



initialization
  RandomVariable := 1;
end.
