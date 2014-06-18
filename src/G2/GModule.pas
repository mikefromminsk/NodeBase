unit GModule;

interface

uses
  MetaBaseModule, Dialogs, Types, Math, SysUtils;

type

  TGFocus = class (TFocus)
  public
    procedure CreateFunc(Node: PNode);
    procedure CreateNode(Node: PNode);
    procedure CreateData(Node: PNode);
    procedure CreateLink(Node: PNode);
    procedure CreateFuncHead(Node: PNode);
    function NewRandomNode(Node: PNode): PNode;
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
  FunctionParamsCount = 3;
  FunctionSequenceCount = 10;

implementation


function Random(Range: Integer): Integer;
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

function RandomIndexInArrays(Arr: TIntegerDynArray; var InnerIndex: Integer): Integer;
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
  SetLength(Arr, 4);
  Arr[0] := High(Node.Local) + 1;
  Arr[1] := High(Node.Params) + 1;
  Arr[2] := IfThen(Node.Value = nil, 0, 1);
  case RandomIndexInArrays(Arr, Index) of
    0: Result := Node.Local[Index];
    1: Result := Node.Params[Index];
    2: Result := Node.Value;
  end;
  SetLength(Arr, 0);
  if Result.Attr = naFile then
    Result := NewRandomNode(Result);
  Result := NewNode(GetIndex(Result) + '^' + NextID);
end;

procedure TGFocus.CreateFuncHead(Node: PNode);
var
  i, j: Integer;
  FuncNode: PNode;
begin
  for i:=0 to FunctionCount do
  begin
    AddLocal(Node, NewRandomNode(Node));
    {FuncNode := NewNode(NextId);
    for j:=0 to FunctionParamsCount do
    begin
      AddParam(Node, NewRandomNode(Node), j);
    end;   }
  end;
end;


procedure TGFocus.CreateFunc(Node: PNode);
begin
  CreateNode(Node);
  CreateData(Node);
  CreateLink(Node);
  CreateFuncHead(Node);
end;

end.
