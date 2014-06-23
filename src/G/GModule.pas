unit GModule;

interface

uses
  MetaBaseModule, Dialogs, Types, Math, SysUtils;

type

  TGFocus = class (TFocus)
  public
    procedure CreateFunc(Node: PNode; Level: Integer);
    procedure CreateNode(Node: PNode);
    procedure CreateData(Node: PNode);
    procedure CreateLink(Node: PNode);
    procedure CreateFuncHead(Node: PNode; Level: Integer);
    procedure SetParams(Node: PNode; FuncNode: PNode);
    procedure CreateSequence(FuncNode: PNode);
    procedure CreateFuncBody(Node: PNode; Level: Integer);
    function NewRandomNode(Node: PNode): PNode;
    function NewRandomType: String;
  end;
var
  RandomVariable: Integer;

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
  FunctionParamsCount = 1;
  FunctionSequenceCount = 10;
  FunctionLevel = 1;

  TypesArr : array[0..1] of string = ('int', 'float');
implementation


function Random(Range: Integer): Integer; overload;
begin
  Inc(RandomVariable);
  Result := RandomVariable mod Range;
end;

function Random(Arr: TIntegerDynArray; var InnerIndex: Integer): Integer;  overload;
var i: Integer;
begin
  InnerIndex := Random(MaxInt) mod SumInt(Arr);
  for i:=0 to High(Arr) do
  begin
    if InnerIndex - Arr[i] < 0 then
    begin
      Result := i;
      Exit;
    end;
    InnerIndex := InnerIndex - Arr[i];
  end;
end;

function Random(Arr: TIntegerDynArray): Integer; overload;
var InnerIndex: Integer;
begin
  Result := Random(Arr, InnerIndex);
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

procedure TGFocus.CreateNode(Node: PNode);
var i: Integer;
begin
  for i:=0 to LocalCount do
    AddLocal(Node, NewNode(NextId));
end;

procedure TGFocus.CreateData(Node: PNode);
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

procedure TGFocus.CreateLink(Node: PNode);
var i: Integer;
begin
  for i:=0 to High(Module.Local) do
    AddLocal(Node, Module.Local[i]);
end;

function TGFocus.NewRandomNode(Node: PNode): PNode;
var Index: Integer; Arr: TIntegerDynArray;
begin
  Result := nil;
  SetLength(Arr, 4);
  Arr[0] := High(Node.Local) + 1;
  Arr[1] := High(Node.Params) + 1;
  Arr[2] := IfThen(Node.Value = nil, 0, 1);
  case Random(Arr, Index) of
    0: Result := Node.Local[Index];
    1: Result := Node.Params[Index];
    2: Result := Node.Value;
  end;
  SetLength(Arr, 0);
  if Result.Attr = naFile then
    Result := NewRandomNode(Result);
  Result := NewNode(GetIndex(Result) + '^' + NextID);
end;

function TGFocus.NewRandomType(): String;
var Arr: TIntegerDynArray;
begin
  SetLength(Arr, 2);
  Arr[0] := 2;
  Arr[1] := 2;
  Result := TypesArr[Random(Arr)];
  SetLength(Arr, 0);
end;

procedure TGFocus.CreateFuncHead(Node: PNode; Level: Integer);
var
  i, j: Integer;
  FuncNode: PNode;
begin
  if Level < 0 then Exit;
  for i:=0 to FunctionCount do
  begin
    FuncNode := NewNode(NextId);
    AddLocal(Node, FuncNode);
    for j:=0 to FunctionParamsCount do
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
begin
  Node := FuncNode;
  for i:=0 to FunctionSequenceCount do
  begin
    NextNode(Node, NewRandomNode(FuncNode));
    if Node.Source.Params <> nil then
      SetParams(Node, FuncNode)
    else
    begin
      SetValue(Node, NewRandomNode(FuncNode));
      if Node.Value.Source.Params <> nil then
        SetParams(Node.Value, FuncNode);
    end;
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

procedure TGFocus.CreateFunc(Node: PNode; Level: Integer);
begin
  CreateNode(Node);
  CreateData(Node);
  CreateLink(Node);
  CreateFuncHead(Node, Level);
  CreateSequence(Node);
  CreateFuncBody(Node, Level);
end;


end.
