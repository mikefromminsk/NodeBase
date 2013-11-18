unit MetaGenerator;

interface

uses MetaBase, MetaUtils, Dialogs, SysUtils;

type
  TGenerator = class(TMeta)
    procedure GenerationLocal(Node: PNode);
    procedure GenerationScript(Node: PNode);
    function RandomNode(Node: PNode): PNode;

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
    {CountParam := Random(3);
    if CountParam > 0 then
    begin
      NewLine := NewLine + '?';
      for j:=0 to CountParam do
        NewLine := NewLine + NextId + '&';
      Delete(NewLine, Length(NewLine), 1);
    end;}
    AddLocal(Node, NewNode(NewLine));
  end;
end;

function TGenerator.RandomNode(Node: PNode): PNode;
var i, Index: Integer;
begin
  Index := Random(High(Node.Local) +  High(Node.Params) + 1);
  if Index > High(Node.Local)
  then Result := Node.Params[Index - High(Node.Local)]
  else Result := Node.Local[Index];
end;

procedure TGenerator.GenerationScript(Node: PNode);
var
  i, j: Integer;
  NewLine: String;
begin

  for i:=0 to Random(10) do
  begin
    NewLine := GetIndex(RandomNode(Node)) + '^' + NextId;
    
    if Random(2) = 0 then
      NewLine := NewLine + '=' + GetIndex(RandomNode(Node));

    {if High(Next.Params) <> -1 then
    begin
      NewLine := NewLine + '?';
      for j:=0 to High(Next.Params) do
        NewLine := NewLine + GetIndex(RandomNode(Node)) + '&';
      Delete(NewLine, Length(NewLine), 1);
    end;

    if Random(30) = 0 then
      NewLine := NewLine + '|' + GetIndex(RandomNode(Node));}    

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
  Gen := TGenerator.Create;
  Gen.Get('$I1?2&2');
end.
