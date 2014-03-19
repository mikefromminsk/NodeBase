unit MetaGenerator;

interface

uses
  MetaBase, MetaUtils, Dialogs, SysUtils, Math{IfThen}, Types;

type
  TMGen = class(TMeta)
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure GenNode(Node: PNode);
    procedure GenParams(Node: PNode);
    function RandomNode(Node: PNode): PNode;
    function RandomParams(Func: PNode; Node: PNode): String;
    procedure GenScript(Node: PNode);
  end;

var
  Gen: TMGen;

implementation



function TMGen.AddNode(var Arr: ANode; Node: PNode): PNode;
begin
  Result := AddSubNode(Arr);
  Arr[High(Arr)] := Node;
end;

function RandomArr(var Index: Integer; Arr: TIntegerDynArray): Integer;
var i, SumArr: Integer;
begin
  SumArr := SumInt(Arr);
  if SumArr = 0 then
  begin
    Result := -1;
    Exit;
  end;
  Index := Random(MaxInt) mod SumArr;
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

procedure TMGen.GenNode(Node: PNode);
var
  i: Integer;
  LocalNode: PNode;
begin
  //NOT GUT
  SetLength(Node.Local, 0);
  for i:=0 to Random(10) do
  begin
    LocalNode := NewNode(NextId); // Find
    AddLocal(Node, LocalNode);
    if Random(30) = 0 then
      GenParams(LocalNode);
  end;
end;

procedure TMGen.GenParams(Node: PNode);
var i, CountParams: Integer;
begin
  CountParams := Random(3);
  for i:=0 to CountParams do
    AddParam(Node, NewNode(NextId + ':'), i);
  if Random(2) = 0 then       
    Node.Value := NewNode(NextId);
end;

function TMGen.RandomNode(Node: PNode): PNode;
var Index: Integer; Arr: TIntegerDynArray;
begin
  Result := nil;
  SetLength(Arr, 4);
  Arr[0] := High(Node.Local) + 1;
  Arr[1] := High(Node.Params) + 1;
  Arr[2] := IfThen(Node.Value = nil, 0, 1);
  Arr[3] := High(Module.Local); // Node.ParentLocal.Local
  case RandomArr(Index, Arr) of
    0: Result := Node.Local[Index];
    1: Result := Node.Params[Index];
    2: Result := Node.Value;
    3: Result := Module.Local[Index];
  end;
  if Result.Attr = naFile then
    Result := RandomNode(Node);
  SetLength(Arr, 0);
end;

function TMGen.RandomParams(Func: PNode; Node: PNode): String;
var i, Index: Integer;
begin
  Result := '';
  if High(Func.Params) <> -1 then
  begin
    Result := '?';
    for i:=0 to High(Func.Params) do
      Result := Result + GetIndex(RandomNode(Node)) + '^' + NextId + '&';
    Delete(Result, Length(Result), 1);
  end;
end;

procedure TMGen.GenScript(Node: PNode);
var
  i, j: Integer;
  Line: String;
  LNode, RNode, Buf, LastNode: PNode;
begin
  //NOT GUT
  Node.Next := nil;
  Node.Value := nil;
  if Node.Value = nil then
    Node.Value := NewNode(NextID);
  LastNode := Node;
  for i:=0 to 0 do
  begin
    Line := '';
    LNode := RandomNode(Node);
    RNode := RandomNode(Node);

    while (LNode = nil) or (RNode = nil) or (LNode = RNode) or
          (LNode = Node) or (RNode = Node) or
          (LNode.ParentParams = Node) do
    begin
      LNode := RandomNode(Node);
      RNode := RandomNode(Node);
    end;
    {if RNode.Attr = naFile then
    ShowMessage('1'); //!!!  }

    Line := GetIndex(LNode) + '^' + NextId + RandomParams(LNode, Node);

    if (High(LNode.Params) = -1) then
      Line := Line + '=' + GetIndex(RNode) + '^' + NextId + RandomParams(RNode, Node);
    NextNode(LastNode, NewNode(Line));
  end;
end;




procedure Analysing(Node: PNode);
var
  i: Integer;
begin
  inherited Analysing(Node);

  if Node.Generate > 0 then
  begin
    GenNode(Node);
    GenScript(Node);
  end;
end;

initialization
  Randomize;
  Gen := TMGen.Create;
end.
