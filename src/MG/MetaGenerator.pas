unit MetaGenerator;

interface

uses MetaBase, MetaUtils, Dialogs, SysUtils, Math{IfThen}, Types;

type
  TMGen = class(TMeta)
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure GenNode(Node: PNode);
    procedure GenParams(Node: PNode);

    function RandomParams(Func: PNode; Node: PNode): String;
    function RandomNode(Node: PNode): PNode;
    procedure GenScript(Node: PNode);

    function GetNodeText(Node: PNode): String;

    procedure Analysing(Node: PNode); override;
  end;

var
  Gen: TMGen;

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

function TMGen.RandomNode(Node: PNode): PNode;
var Index: Integer; Arr: TIntegerDynArray;
begin
  Result := nil;
  SetLength(Arr, 4);
  Arr[0] := {1;//}High(Node.Local) + 1;
  Arr[1] := {0;//}High(Node.Params) + 1;
  Arr[2] := IfThen(Node.Value = nil, 0, 1);
  Arr[3] := {0;//}High(Node.ParentLocal.Local);
  case RandomArr(Index, Arr) of
    0: Result := Node.Local[Index];
    1: Result := Node.Params[Index];
    2: Result := Node.Value;
    3: Result := Node.ParentLocal.Local[Index];
  end;
  SetLength(Arr, 0);
end;



procedure TMGen.GenScript(Node: PNode);
var
  i, j: Integer;
  Line: String;
  LNode, RNode, Buf: PNode;
begin

  for i:=0 to 5 do
  begin
    Line := '';
    LNode := RandomNode(Node);
    RNode := RandomNode(Node);

    while (LNode = nil) or (RNode = nil) or (LNode = RNode) or
          (LNode = Node) or (RNode = Node) do
    begin
      LNode := RandomNode(Node);
      RNode := RandomNode(Node);
    end;

    Line := GetIndex(LNode) + '^' + NextId + RandomParams(LNode, Node);

    if (High(LNode.Params) = -1) then
      Line := Line + '=' + GetIndex(RNode) + '^' + NextId + RandomParams(RNode, Node);

    NextNode(NewNode(Line));
  end;
end;


function TMGen.GetNodeText(Node: PNode): String;
var
  Str: String;
  i: Integer;
  Next: PNode;
begin
  Result := '';
  if Node = nil then Exit;
  if Node.Source <> nil then
    Result := Result + GetIndex(Node.Source) + '^';
  if Node.ParentName <> nil then
    Result := Result + GetIndex(Node.ParentName);
  Result := Result + GetIndex(Node);
  if Node.FType <> nil then
    Result := Result + ':' + GetIndex(Node.FType);
  Str := '';
  {if Node.Count <> 0 then
    Str := Str + 'C' + IntToStr(Node.Count);
  if Node.SaveTime <> 0 then
    Str := Str + 'T' + FloatToStr(Node.SaveTime); }
  if Node.Generate <> 0 then
    Str := Str + 'G' + IntToStr(Node.Generate);
  if Str <> '' then
    Result := Result + '$' + Str;
  Str := '';
  for i:=0 to High(Node.Params) do
    Str := Str + GetIndex(Node.Params[i]) + '&';
  if Str <> '' then
  begin
    Delete(Str, Length(Str), 1);
    Result := Result + '?' + Str + ';';
  end;
  if (Node.FTrue <> nil) or (Node.FElse <> nil) then
  begin
    if Node.FTrue <> nil then
      Result := Result + '#' + GetIndex(Node.FTrue);
    if Node.FElse <> nil then
      Result := Result + '|' + GetIndex(Node.FElse);
  end
  else
  if Node.Value <> nil then
    Result := Result + '#' + GetIndex(Node.Value);
  if GetData(Node) <> nil then
    Result := Result + '=' + EncodeName(GetData(Node).Name);
  Next := Node.Next;
  while Next <> nil do
  begin
    Result := Result + #10 + GetIndex(Next) + '=' + GetIndex(Next.Value);
    Next := Next.Next;
  end;
  for i:=0 to High(Node.Local) do
    Result := Result + #10#10 + GetNodeText(Node.Local[i]);
end;


procedure TMGen.Analysing(Node: PNode);
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
  //for RandSeed := 0 to 1 do
  //RandSeed := 0;
  Gen := TMGen.Create;
end.
