unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MetaBase;

type
  TGG = class(TForm)
  end;

  {
var
  ValueActionFrequency: TIntegerDynArray;

const
  actNew = 0;
  actFind = 1;
  actDelete = 2;



function RandomArr(A: TIntegerDynArray): Integer;
var i: Integer;
begin
  Result := Random(MaxInt);
  Result := Result mod SumInt(A);
  for i:=0 to High(A) do
  begin
    Result := Result - A[i];
    if Result <= 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;


function RandomNode(Node: PNode): PNode;
begin
  Node := Node.ParentLocal;
  Result := Node.Local[Random(High(Node.Local) + 1)];
end;


procedure TypeLink(Node: PNode; Value, Next, Fif: Integer);
var
  TypeLink, Action: Integer;
begin
  TypeLink := Value;

  if TypeLink <= Value then
  begin
    case RandomArr(ValueActionFrequency) of
      actNew : Node.Value := Base.NewNode(Base.NextID);   //Analusis
      actFind: Node.Value := Base.NewNode(Base.GetIndex(RandomNode(Node)));  //Recursion  Param
      actDelete: Base.SaveNode(Base.AddLocal(Node, Node.Value)); //ParentValue
    end;
  end;

end;


procedure Analysis(Node: PNode);
begin
  if Node = nil then Exit;
  if Node.Interest > 0 then
  begin
    if Node.Prev = nil then
      TypeLink(Node, 10, 10, 10);
  end;

end;
}

var
  GG: TGG;

implementation

{$R *.dfm}

initialization
  {SetLength(ValueActionFrequency, 3);
  ValueActionFrequency[actNew] := 0;
  ValueActionFrequency[actFind] := 90;
  ValueActionFrequency[actDelete] := 0;}
end.

