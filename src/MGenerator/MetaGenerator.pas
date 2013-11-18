unit MetaGenerator;

interface

uses MetaBase, Dialogs, SysUtils;

type
  TGenerator = class(TMeta)
    procedure GenerationLocal(Node: PNode);
    procedure GenerationScript(Node: PNode);

    function Get(Line: String): PNode; //override;
  end;

var
  Gen: TGenerator;

implementation


procedure TGenerator.GenerationLocal(Node: PNode);
var
  i, j, CountParam: Integer;
  NewLine: String;
begin
  for i:=0 to Random(10) do
  begin
    NewLine := NextId;
    CountParam := Random(3);
    if CountParam > 0 then
    begin
      NewLine := NewLine + '?';
      for j:=0 to CountParam do
        NewLine := NewLine + NextId + '&';
      Delete(NewLine, Length(NewLine), 1);
    end;
    AddLocal(Node, NewNode(NewLine));
  end;
end;

procedure TGenerator.GenerationScript(Node: PNode);
var
  i, j: Integer;
  Next: PNode;
  NewLine: String;
begin
  for i:=0 to Random(10) do
  begin
    Next := Node.Local[Random(High(Node.Local))];
    NewLine := '@' + GetIndex(Next) + '^' + NextId;
    if High(Next.Params) <> -1 then
      for j:=0 to High(Next.Params) do
    NextNode(NewNode(NewLine));
  end;
end;


function TGenerator.Get(Line: String): PNode;
var
  Node: PNode;
  i: Integer;
begin
  Result := inherited Get(Line);
  if Result = nil then Exit;


  if Result.Interest <> 0 then
  begin
    GenerationLocal(Result);
    GenerationScript(Result);
  end;
end;


initialization
  Randomize;
  Gen := TGenerator.Create;
  Gen.Get('$I1');
end.
