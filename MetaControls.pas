unit MetaControls;

interface

uses MetaBase;


procedure SetControls(Node: PNode);



implementation


procedure SetControls(Node: PNode);
begin
  if Node = nil then Exit;
  Node.Interest := 2;
end;


end.
