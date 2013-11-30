unit MetaGenerator;

interface

uses MetaBase, MetaUtils, Dialogs, SysUtils, Math{IfThen}, Types;

type
  TMGen = class(TMeta)
    function AddNode(var Arr: ANode; Node: PNode): PNode;
    procedure GenNode(Node: PNode);
    procedure GenParams(Node: PNode);
    procedure GenScript(Node: PNode);
    function RandomNode(Node: PNode): PNode;
    function RandomParams(Func: PNode; Node: PNode): String;
    procedure Analysing(Node: PNode); override;
    function GetNodeText(Node: PNode): String;
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

function TMGen.RandomNode(Node: PNode): PNode;
var
  Index: Integer; Arr: TIntegerDynArray;
begin
  SetLength(Arr, 4);
  Arr[0] := 0;//High(Node.Local) + 1;
  Arr[1] := High(Node.Params) + 1;
  Arr[2] := IfThen(Node.Value = nil, 0, 1);
  Arr[3] := High(Node.ParentLocal.Local);
  case RandomArr(Index, Arr) of
    0: Result := Node.Local[Index];
    1: Result := Node.Params[Index];
    2: Result := Node.Value;
    3: Result := Node.ParentLocal.Local[Index];
  else Result := nil;
  end;
  SetLength(Arr, 0);
  if (Result <> nil) and (((Result.Attr = naFile) and (High(Result.Local) <> -1)) or (Result = Node)) then
    Result := RandomNode(Result);
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
  NewLine: String;
  LeftNode, RightNode, Buf: PNode;
begin

  for i:=0 to Random(5) do
  begin
    LeftNode := RandomNode(Node);
    NewLine := '';
    NewLine := GetIndex(LeftNode) + '^' + NextId;

    {if (High(LeftNode.Params) <> -1) and (Random(2) = 0) then  //SetParams
      NewLine := NewLine + RandomParams(LeftNode, Node);}

    if (High(LeftNode.Params) = -1) {and (Random(2) = 0)} then   //SetValue with Params
    begin
      RightNode := RandomNode(Node);
      NewLine := NewLine + '=' + GetIndex(RightNode) + '^' + NextId{ + RandomParams(RightNode, Node)};
    end;

    NextNode(NewNode(NewLine));
  end;
end;


procedure TMGen.Analysing(Node: PNode);
var
  i: Integer;
begin
  inherited Analysing(Node);

  if Node.Generate <> 0 then
  begin
    GenNode(Node);
    //GenScript(Node);
  end;
end;



function TMGen.GetNodeText(Node: PNode): String; //to MetaBase.SaveNode
var
  Str: String;
  i: Integer;
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
  while Node.Next <> nil do
    Result := Result + #10 + GetIndex(Node.Next);
  for i:=0 to High(Node.Local) do
    Result := Result + #10#10 + GetIndex(Node.Local[i]);
end;


initialization
  Randomize;
  Gen := TMGen.Create;
end.
