unit MetaGenerator;

interface

uses MetaBase, MetaUtils, Dialogs, SysUtils;

type
  TMGen = class(TMeta)
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure GenNode(Node: PNode);
    procedure GenParams(Node: PNode);
    procedure GenScript(Node: PNode);
    function RandomNode(Node: PNode): PNode;
    function RandomParams(Func: PNode; Node: PNode): String;
    function Get(Line: String): PNode; 
  end;

var
  Gen: TMGen;
  Nodes: ANode;

implementation


function TMGen.AddNode(var Arr: ANode; Node: PNode): PNode;
begin
  Result := AddSubNode(Arr);
  Arr[High(Arr)] := Node;
end;

procedure TMGen.GenNode(Node: PNode);
var
  i: Integer;
  LocalNode: PNode;
begin
  for i:=0 to Random(10) do     //CreateNode
  begin
    LocalNode := NewNode(NextId);
    AddLocal(Node, LocalNode);
    if Random(30) = 0 then      //CreateParams
      GenParams(LocalNode);
  end;
end;

procedure TMGen.GenParams(Node: PNode);
var i, CountParams: Integer;
begin
  CountParams := Random(3);   //CountParams
  for i:=0 to CountParams do
    AddParam(Node, NewNode(NextId + ':'), i);
  if Random(2) = 0 then       //CreateResult
    Node.Value := NewNode(NextId);
end;

function TMGen.RandomNode(Node: PNode): PNode;
var i, Index: Integer;
begin
  Index := Random(High(Node.Local) +  High(Node.Params) + 1); //RandomLocalOrParam
  if Index > High(Node.Local)
  then Result := Node.Params[Index - High(Node.Local)]
  else Result := Node.Local[Index];
end;

function TMGen.RandomParams(Func: PNode; Node: PNode): String;
var i, Index: Integer;
begin
  Result := '';
  if High(Func.Params) <> -1 then
  begin
    Result := '?';
    for i:=0 to High(Func.Params) do
      Result := Result + GetIndex(RandomNode(Root)) + '^' + NextId + '&';
    Delete(Result, Length(Result), 1);
  end;
end;

procedure TMGen.GenScript(Node: PNode);
var
  i, j: Integer;
  NewLine: String;
  LeftNode, RightNode: PNode;
begin

  for i:=0 to Random(10) do
  begin
    LeftNode := RandomNode(Node);
    NewLine := GetIndex(LeftNode) + '^' + NextId;

    if (High(LeftNode.Params) = -1) and (Random(2) = 0) then   //SetValue
    begin
      RightNode := RandomNode(Node);
      NewLine := NewLine + '=' + GetIndex(RightNode) + '^' + NextId + RandomParams(RightNode, Node);
    end;

    if (High(LeftNode.Params) <> -1) and (Random(2) = 0) then  //SetParams
      NewLine := NewLine + '=' + GetIndex(LeftNode) + '^' + NextId + RandomParams(LeftNode, Node);

    NextNode(NewNode(NewLine));
  end;
end;


function TMGen.Get(Line: String): PNode;
var
  Node: PNode;
  i: Integer;
begin
  Result := inherited Get(Line);
  if Result = nil then Exit;


  if Result.Interest <> 0 then
  begin

    SetLength(Nodes, 0);
    for i:=0 to High(Result.Params) do
      AddNode(Nodes, Result.Params[i]);
    GenNode(Result);
    GenScript(Result);

    Node := Result;
    while Node.Next <> nil do
    begin
      if (Node.Value <> nil) and (GetData(Node) <> nil) then
        ShowMessage(EncodeName(GetData(Node).Name));
      Node := Node.Next;
    end;
    
  end;
end;


initialization
  Randomize;
  Gen := TMGen.Create;
  Gen.Get('$I1?2&2');
end.
