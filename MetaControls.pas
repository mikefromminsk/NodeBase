unit MetaControls;

interface

uses
  MetaBase;



procedure Analysis(Node: PNode);



implementation

function Find(): PNode;
begin

end;


procedure TypeAction(Node: PNode; New, Find, Delete: Integer);
var
  Method: Integer;
begin

  Method := Random(New + Find + Delete);

  if Method <= New then
  begin
    AddLocal(Module, NewNode(NextNode));
  end
  else
  if Method <= New + Find then
  begin
    Node
    for i:=0 to High(Node.Param) do
    begin

    end;
  end
  else
  begin

  end;

end;

procedure TypeLink(Node: PNode; Value, Next, Fif: Integer);
var TypeLink:Integer;
begin
  TypeLink := Random(Value + Next + Fif);
  if TypeLink <= Value then
  begin
    NFD(Node: PNode; New, Find, Delete: Integer);
  end
  else
  if TypeLink <= Value + Next then
  begin
    NFD(Node: PNode; New, Find, Delete: Integer);
  end
  else
  begin
    NFD(Node: PNode; New, Find, Delete: Integer);
  end;

end;

procedure TypeNode(Node: PNode; Value, Next, Fif: Integer);
var i:Integer;
begin

  if Node.Prev = nil then
  begin

  end;
  if Node.Prev <> nil then
  begin

  end;
  if Node.Next <> nil then
  begin

  end;
end;


end.
