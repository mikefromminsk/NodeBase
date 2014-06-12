unit GModule;

interface

uses
  MetaBaseModule, Dialogs, Types, Math, SysUtils;

type
  TG = class (TFocus)
  public
    function Exec(Line: String): PNode; override;
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure CreateModule(Node: PNode);
      procedure CreateLocal(Node: PNode);
        procedure CreateUses(Node: PNode);
        procedure CreateObjects(Node: PNode);
        procedure CreateData(Node: PNode);
        procedure CreateTypes(Node: PNode);
      procedure CreateFunctionHead(Node: PNode);
        procedure CreateParameters(Node: PNode);
        procedure CreateResult(Node: PNode);
      procedure CreateFunctionBody(Node: PNode);
    procedure CreateSequence(Node: PNode);
    procedure CreateValue(Node: PNode);
    procedure SetParameters(Node: PNode);
    procedure CreateIf(Node: PNode);
    procedure CreateFor(Node: PNode);
  end;

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

implementation

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


function Random(Range: Integer): Integer;
begin
  Result := Range;
end;

function TG.AddNode(var Arr: ANode; Node: PNode): PNode;
begin
  Result := AddSubNode(Arr);
  Arr[High(Arr)] := Node;
end;

function RandomIndex(Arr: TIntegerDynArray): Integer;
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
    AddLocal(Node, NewNode(IntToStr(CauchyRandomMod(IntBeginRange, IntCenterRange, IntEndRange))));

  for i:=0 to Data8Count do
    AddLocal(Node, NewNode(
            IntToStr(CauchyRandomMod(IntBeginRange, IntCenterRange, IntEndRange))
            + ',' +
            IntToStr(CauchyRandomMod(FracBeginRange, FracCenterRange, FracEndRange)) ));
end;

procedure TG.CreateTypes(Node: PNode);
begin
{TypeName [Int, Float, Binary, Array]
TypeLong [4, 8, 0] }
end;


procedure TG.CreateLocal(Node: PNode);
begin
  CreateUses(Node);
  CreateObjects(Node);
  CreateData(Node);
  CreateTypes(Node);
end;

procedure TG.CreateModule(Node: PNode);
begin
  CreateLocal(Node);
end;


function TG.Exec(Line: String): PNode;
begin
  Result := inherited Exec(Line);
  CreateModule(Result);
end;





end.
