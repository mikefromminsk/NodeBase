unit MetaGenerator;

interface

uses MetaBase, MetaUtils, Dialogs, SysUtils;

type
  TMGen = class(TMeta)
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure GenLocal(Node: PNode);
    procedure GenScript(Node: PNode);
    function RandomNode(Node: PNode): PNode;

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

procedure TMGen.GenLocal(Node: PNode);
var
  i: Integer;
  LocalNode: PNode;
begin
  for i:=0 to Random(10) do
  begin
    LocalNode := NewNode(NextId);
    AddLocal(Node, LocalNode);
  end;
end;

function TMGen.RandomNode(Node: PNode): PNode;
var i, Index: Integer;
begin
  Index := Random(High(Node.Local) +  High(Node.Params) + 1);
  if Index > High(Node.Local)
  then Result := Node.Params[Index - High(Node.Local)]
  else Result := Node.Local[Index];
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
    
    if (High(LeftNode.Params) = -1) and (Random(2) = 0) then
    begin
      RightNode := RandomNode(Node);

      if High(RightNode.Params) <> -1 then                                              //если попали на функцию то установить параметры
      begin
        NewLine := NewLine + '?';
        for j:=0 to High(RightNode.Params) do
          NewLine := NewLine + GetIndex(RandomNode(Node)) + '^' + NextId + '&';
        Delete(NewLine, Length(NewLine), 1);
      end;

      NewLine := NewLine + '=' + GetIndex(RandomNode(RightNode)) + '^' + NextId;
    end;

    if High(LeftNode.Params) <> -1 then                                              //если попали на функцию то установить параметры
    begin
      NewLine := NewLine + '?';
      for j:=0 to High(LeftNode.Params) do
        NewLine := NewLine + GetIndex(RandomNode(Node)) + '^' + NextId + '&';
      Delete(NewLine, Length(NewLine), 1);
    end;

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
    GenLocal(Result);
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
