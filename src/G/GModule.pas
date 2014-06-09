unit GModule;

interface

uses
  MetaBaseModule, Dialogs, Types, Math;

type
  TG = class (TFocus)
  public
    function Exec(Line: String): PNode; override;
    function CreateNode(Node: PNode): PNode;
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure CreateModule(Node: PNode);
    procedure CreateObjects(Node: PNode);
    procedure CreateCopys(Node: PNode);
    procedure CreateData(Node: PNode);
    procedure CreateTypes(Node: PNode);
    procedure CreateFunctionHead(Node: PNode);
    procedure CreateParameters(Node: PNode);
    procedure CreateResult(Node: PNode);
    procedure CreateSequence(Node: PNode);
    procedure CreateValue(Node: PNode);
    procedure SetParameters(Node: PNode);
    procedure CreateIf(Node: PNode);
    procedure CreateFor(Node: PNode);
  end;

const
  LocalCount = 10;
  FunctionCount = 3;

implementation



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

procedure TG.CreateObjects(Node: PNode);
var i: Integer;
begin
  for i:=0 to LocalCount do
  begin
    LocalNode := NewNode(NextId);
    AddLocal(Node, LocalNode);
  end;
end;

procedure TG.CreateParameters(Node: PNode);
begin

end;

procedure TG.CreateFunctionHead(Node: PNode);
var i: Integer;
begin
  for i:=0 to FunctionCount do
  begin
    CreateParameters(Node);
  end;
end;

function TG.CreateModule(Node: PNode): PNode;
begin
  CreateLocal(Result);
  Result := Node;
end;

function TG.Exec(Line: String): PNode;
begin
  Result := CreateModule(inherited Exec(Line));
end;

end.