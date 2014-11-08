unit Kernel;

interface

uses
  Link, Utils, Dialogs;

type
  TNode = class;
  ANode = array of TNode;


  TNode = class
  public
    Path          : String;          //test
    IndexName     : String;
    IndexChilds   : ANode;

    Source        : TNode;
    ValueType     : TNode;
    Params        : ANode;
    Local         : ANode;
    Value         : TNode;
    Data          : String;
    FTrue         : TNode;
    FElse         : TNode;
    Prev          : TNode;
    Next          : TNode;

    ParentIndex   : TNode;
    ParentName    : TNode;
    ParentParams  : TNode;
    ParentLocal   : TNode;


    Status        : Integer;
    Attributes    : TMap;


    function  GetType: String;
    procedure SetType(Value: String);
    function  GetAttr(Name: String): String;
    procedure SetAttr(Name, Value: String);
    property  FType: String read GetType write SetType;
    property  Attr[Name: String]: String read GetAttr write SetAttr;
    destructor Destroy; override;
  end;


  TKernel = class
    Root      : TNode;
    Prev      : TNode;
    FUnit     : TNode;

    constructor Create;

    function NextID: String;

    procedure SetName(var Node: TNode; Name: String);
	  function FindName(Index: TNode): TNode;
    function FindNameInNode(Node: TNode; Index: TNode): TNode;

    function NewIndex(Name: String): TNode;

	  procedure SetSource(Node: TNode; Source: TNode);
	  function GetSource(Node: TNode): TNode;

    procedure SetFType(Node: TNode; FType: TNode);

	  procedure SetParam(Node: TNode; Param: TNode; Index: Integer);

    function SetValue(Node: TNode; Value: TNode): TNode;
    function GetValue(Node: TNode): TNode;

	  procedure SetData(Node: TNode; Value: String);

    procedure SetFTrue(Node: TNode; FTrue: TNode);
    procedure SetFElse(Node: TNode; FElse: TNode);

	  procedure SetNext(Node: TNode; Next: TNode);
    procedure NextNode(var PrevNode: TNode; NextNode: TNode);

    function SetLocal(Node: TNode; Local: TNode): TNode;

    function NewNode(Line: String): TNode; overload;
    function NewNode(Link: TLink): TNode; overload;

	  function LoadNode(Node: TNode): TNode;
	  procedure LoadModule(Node: TNode);

    procedure SaveNode(Node: TNode);

    procedure SaveBranch(Node: TNode);
    procedure FreeBranch(Node: TNode);

    procedure Call(Node: TNode);
    function Compare(Node: TNode): Boolean;
    procedure Run(Node: TNode);

	  function GetIndex(Node: TNode): String;
    function GetNodeBody(Node: TNode): String;

    function UserNode(Line: String): TNode; virtual;

  end;

procedure Clear(var Nodes: ANode);
procedure AddItem(var Nodes: ANode; Node: TNode);
procedure DeleteItem(var Nodes: ANode; Node: TNode);

implementation


procedure Clear(var Nodes: ANode);
begin
  SetLength(Nodes, 0);
end;

procedure AddItem(var Nodes: ANode; Node: TNode);
begin
  SetLength(Nodes, Length(Nodes) + 1);
  Nodes[High(Nodes)] := Node;
end;

procedure DeleteItem(var Nodes: ANode; Node: TNode);
var i: Integer;
begin         //dangeros to param
  for i:=0 to High(Nodes) do
    if Nodes[i] = Node then
    begin
      Nodes[i] := Nodes[High(Nodes)];
      SetLength(Nodes, High(Nodes));
    end;
end;


{ TNode }

function TNode.GetAttr(Name: String): String;
begin
  Result := '';
  if Attributes <> nil then
    Result := Attributes.GetValue(Name);
end;

procedure TNode.SetAttr(Name, Value: String);
begin
  if Attributes = nil then
    Attributes := TMap.Create;
  Attributes.SetValue(Name, Value);
end;

function TNode.GetType: String;
begin
  Result := Attr[naType];
end;

procedure TNode.SetType(Value: String);
begin
  Attr[naType] := Value;
end;

destructor TNode.Destroy;
begin
  if Attributes <> nil then
    Attributes.Free;
end;

{ TKernel }

constructor TKernel.Create;
begin
  Root := TNode.Create;
  Root.Attributes := TMap.Create(LoadFromFile(RootFileName), #10);
  Root.FType := ntRoot;
end;


function TKernel.NextID: String;
begin
  Root.Attr[naLastID] := IntToStr(StrToIntDef(Root.Attr[naLastID], 0) + 1);
  Result := sID + Root.Attr[naStartID] + Root.Attr[naLastID];
end;


procedure TKernel.SetName(var Node: TNode; Name: String);
begin
  if Node = nil then
  begin
    Node := NewIndex(NextID);
    Node.ParentName := NewIndex(Name);
  end
  else
    Node.ParentName := NewIndex(Name);
end;


function TKernel.FindName(Index: TNode): TNode;
var Node, Find: TNode;
begin
  Result := nil;
  if Index = nil then Exit;
  if Prev = nil
  then Node := FUnit
  else Node := Prev;
  while Node <> nil do
  begin
    Find := FindNameInNode(Node, Index);
    if Find <> nil then
    begin
      Result := Find;
      if Find.Source = nil then Exit;
    end;
    if (Node.Prev = nil) and (Node.ParentLocal <> nil)
    then Node := Node.ParentLocal
    else Node := Node.Prev;
  end;
end;


function TKernel.FindNameInNode(Node: TNode; Index: TNode): TNode;
var
  i: Integer;
  Local: TNode;
begin
  Result := nil;
  if Node.ParentName = Index then
    Result := Node;
  if (Result = nil) then
    for i:=0 to High(Node.Params) do
      if Node.Params[i].ParentName = Index then
        Result := Node.Params[i];
  if (Result = nil) and (Node.Value <> nil) and (Node.Value.ParentName = Index) then
    Result := Node.Value;
  if (Result = nil) and (Node.FTrue <> nil) and (Node.FTrue.ParentName = Index) then
    Result := Node.FTrue;
  if (Result = nil) and (Node.FElse <> nil) and (Node.FElse.ParentName = Index) then
    Result := Node;
  if Result = nil then
    for i:=0 to High(Node.Local) do
    begin
      Local := Node.Local[i];
      if Local.FType = ntModule then
      begin
        Result := FindNameInNode(Local, Index);
        if Result <> nil then Exit;
      end;
      if Local.ParentName = Index then
      begin
        Result := Local;
        Exit;
      end;
    end;
end;


function TKernel.NewIndex(Name: String): TNode;         
var
  i, j, Index: Integer;
  function AddIndex(Node: TNode; IndexName: String): TNode;
  begin
    Result := TNode.Create;
    Result.FType := ntEmpty;
    Result.IndexName := IndexName;
    Result.ParentIndex := Node;
    AddItem(Node.IndexChilds, Result);
    Result := Node.IndexChilds[High(Node.IndexChilds)];
    Result.Path := GetIndex(Result); //test
  end;
begin
  Result := Root;
  for i:=1 to Length(Name) do
  begin
    Index := -1;
    for j:=0 to High(Result.IndexChilds) do
      if  Result.IndexChilds[j].IndexName = Name[i] then
      begin
        Index := j;
        Break;
      end;
    if Index = -1
    then Result := AddIndex(Result, Name[i])
    else Result := Result.IndexChilds[Index];
  end;
  if Result = Root then
    Result := nil;
end;


procedure TKernel.SetSource(Node: TNode; Source: TNode);
begin
  Node.Source := Source;
end;


function TKernel.GetSource(Node: TNode): TNode;
begin
  Result := Node;
  if Node = nil then Exit;
  while Result.Source <> nil do
    Result := Result.Source;
end;


procedure TKernel.SetFType(Node: TNode; FType: TNode);
begin
  Node.ValueType := FType;
end;


procedure TKernel.SetParam(Node: TNode; Param: TNode; Index: Integer);
begin
  if Param.ValueType <> nil then
  begin
    Param.Source := nil;
    AddItem(Node.Params, Param);
  end
  else
  begin
    if Index = Length(Node.Params) then
    begin
      AddItem(Node.Params, Param);
    end
    else
    if Index <= High(Node.Params) then
    begin
      {if Node.FType = naDLLFunc then
      begin
        if Node.Params[Index] <> Param then
          Node.Params[Index] := Param;
      end
      else}
      if Node.Params[Index] <> Param then
        Node.Params[Index].Value := Param;

    end;
  end;
end;


function TKernel.SetValue(Node: TNode; Value: TNode): TNode;
begin
  Node.Value := Value;
end;


function FindValue(var ValueStack: ANode; Value: TNode): Boolean;
var i: Integer;
begin
  Result := False;
  for i:=0 to High(ValueStack) do
  if ValueStack[i] = Value then
  begin
    Result := True;
    Exit;
  end;
end;


function TKernel.GetValue(Node: TNode): TNode;
var ValueStack: ANode; //recode to status
begin
  Result := nil;
  while Node <> nil do
  begin
    AddItem(ValueStack, Node);
    if Node.Source <> nil then
      Node := Node.Source
    else
    begin
      Result := Node;
      if Node.Value = nil then Break;
      if FindValue(ValueStack, Node.Value) then Break;
      Node := Node.Value;
    end;
  end;
  Clear(ValueStack);
end;


procedure TKernel.SetData(Node: TNode; Value: String);
begin
  Node.Data := Value;
end;


procedure TKernel.SetFTrue(Node: TNode; FTrue: TNode);
begin
  Node.FTrue := FTrue;
end;


procedure TKernel.SetFElse(Node: TNode; FElse: TNode);
begin
  Node.FElse := FElse;
end;


procedure TKernel.SetNext(Node: TNode; Next: TNode);
begin
  Node.Next := Next;
  Node.Next.Prev := Node;
end;


procedure TKernel.NextNode(var PrevNode: TNode; NextNode: TNode);
begin
  if PrevNode <> nil then
  begin
    if NextNode <> nil then
      NextNode.Prev := PrevNode;
    PrevNode.Next := NextNode;
  end
  else
    if NextNode <> nil then
    begin
      if FUnit = nil then
        FUnit := NextNode
      else
        SetLocal(FUnit, NextNode);
    end;
  PrevNode := NextNode;
end;


function TKernel.SetLocal(Node: TNode; Local: TNode): TNode;
begin
  if Node.FType = ntEmpty
  then Local.ParentName  := Node
  else Local.ParentLocal := Node;
  AddItem(Node.Local, Local);
  Result := Local;
end;



function TKernel.NewNode(Line: String): TNode;
var Link: TLink;
begin
  Link := TLink.BaseParse(Line);
  Result := NewNode(Link);
  Link.Free;
end;


function TKernel.NewNode(Link: TLink): TNode;
var
  i: Integer;
begin

  if Link.ID <> '' then
  begin
    Result := NewIndex(sID + Link.ID);

    if Result.FType = ntEmpty then
      LoadNode(Result);
  end;

  if Link.Name <> '' then
  begin
    SetName(Result, Link.Name);

    if Result.FType <> ntLoad then   //Initialization
    begin
      case Link.Name[1] of
        '/' : Result.FType := ntModule;
        '!' : Result.FType := ntString;
        '0'..'9', '-': Result.FType := ntNumber;
        else  Result.FType := ntWord;
      end;

      if Result.FType = ntWord then
        Result.Source := FindName(Result.ParentName);

      if Result.FType = ntNumber then
        SetData(Result, FloatToStr8(StrToFloatDef(Link.Name, 0)));

      if Result.FType = ntString then
        SetData(Result, DecodeStr(Copy(Link.Name, 2, MaxInt)));
    end;
  end;

  if Result = nil then Exit;

  if Link.Source <> nil then
  begin
    if (Result.FType = ntWord) and (Result.FType <> ntLoad) then
    begin  //hardcode
      SetSource(GetSource(Result), NewNode(Link.Source));
      Result := GetSource(Result)
    end
    else
      SetSource(Result, NewNode(Link.Source));
  end;

  if Link.Vars <> nil then
    for i:=0 to Link.Vars.High do
      Result.Attr[Link.Vars.Names[i]] := Link.Vars.Values[i]; //optimization

  if Link.FType <> nil then
    SetFType(Result, NewNode(Link.FType));

  for i:=0 to High(Link.Params) do
    SetParam(Result, NewNode(Link.Params[i]), i);

  if Link.Value <> nil then
  begin
    if (Link.Value.Name <> '') and (Link.Value.Name[1] = sData)
    then SetData(Result, DecodeStr(Copy(Link.Value.Name, 2, MaxInt)))
    else SetValue(Result, NewNode(Link.Value));
  end;

  if Link.FElse <> nil then
    SetFElse(Result, NewNode(Link.FElse));

  if Link.FTrue <> nil then
    SetFTrue(Result, NewNode(Link.FTrue));

  if Link.Next <> nil then
    SetNext(Result, NewNode(Link.Next));

  for i:=0 to High(Link.Local) do
    SetLocal(Result, NewNode(Link.Local[i]));
end;


function TKernel.LoadNode(Node: TNode): TNode;
var
  Indexes: AString;
  Body, Path: String;
begin
  if Node = nil then Exit;
  Node.FType := ntLoad;

  SetLength(Indexes, 0);
  while Node <> nil do
  begin
    SetLength(Indexes, Length(Indexes) + 1);
    Indexes[High(Indexes)] := Node.IndexName;
    Node := Node.ParentIndex;
  end;
  Path := ToFileSystemName(Indexes) + NodeFileName;
  SetLength(Indexes, 0);

  Body := LoadFromFile(Path);
  if Body <> '' then
    NewNode(Body);
end;


procedure TKernel.LoadModule(Node: TNode);
var
  i: Integer;
  Func, PrevModule: TNode;
  List: AString;
  FileName, FileExt: String;
begin
  FileName := Copy(GetIndex(Node.ParentName), 2, MaxInt);
  if not FileExists(FileName) then Exit;
  FileExt := LowerCase(ExtractFileExt(FileName));
  if FileExt = ExternalModuleExtention then
  begin
    if Node.Attr[naHandle] = '' then
    begin
      Node.Attr[naHandle] := IntToStr(GetFunctionList(FileName, List));
      for i:=0 to High(List) do
      begin
        Func := NewNode(List[i]);
        Func.FType := ntDLLFunc;
        Func.Attr[naHandle] := IntToStr(GetProcAddress(StrToInt(Node.Attr[naHandle]), List[i]));
        SetLocal(Node, Func);
      end;
    end;
  end
  else
  if FileExt = NodeFileExtention then
  begin
    PrevModule := FUnit;
    FUnit := Node;
    List := slice(LoadFromFile(FileName), #10);
    for i:=0 to High(List) do
      UserNode(List[i]);
    FUnit := PrevModule;
  end;
end;


procedure TKernel.Call(Node: TNode);
var
  Value: TNode;
  Params, Param: String;
  Stack: array of Integer;
  Func, FourByte, i, BVal,
  EAXParam, EDXParam, ECXParam, RegParamCount: Integer;
  DBVal: Double;
  IfFloat: Integer;
begin
  BVal := BVal + 1;
  Func := StrToInt(Node.Attr[naHandle]);
  if (Func = 0) then Exit;
  EAXParam := 0; EDXParam := 0; ECXParam := 0; RegParamCount := 0;


  for i:=0 to High(Node.Params) do
  begin
    Value := GetValue(Node.Params[i]);
    if (Value = nil) or (Value.Data = '') then Exit
    else
    begin
      Param := Value.Data;

      if Length(Param) > 4 then
        Params := StringOfChar(#0, Length(Param) mod 4) + Param + Params;

      if Length(Param) < 4 then
        Params := StringOfChar(#0, 4 - Length(Param)) + Param + Params;

      if Length(Param) = 4 then
      begin
        case RegParamCount of
          0: EAXParam := StrToInt4(Param);
          1: EDXParam := StrToInt4(Param);
          2: ECXParam := StrToInt4(Param);
        else
          Params := Param + Params;
        end;
        Inc(RegParamCount);
      end;
    end;
  end;

  while Params <> '' do
  begin
    SetLength(Stack, Length(Stack) + 1);
    Stack[High(Stack)] := StrToInt4(Copy(Params, 1, 4));
    Delete(Params, 1, 4);
  end;

  for i:=High(Stack) downto 0 do
  begin
    FourByte := Stack[i];
    asm push FourByte end;
  end;

  if RegParamCount >= 3 then
    asm mov ecx, ECXParam end;

  if RegParamCount >= 2 then
    asm mov edx, EDXParam end;

  if RegParamCount >= 1 then
    asm mov eax, EAXParam end;

  asm
    CLC
    CALL Func
    JC @1
    MOV BVal, EAX
    MOV IfFloat, 0
    JMP @2
    @1:
    FSTP QWORD PTR [DBVal]
    MOV IfFloat, 1
    @2:
  end;

  if IfFloat = 0
  then SetValue(Node, NewNode('!' + EncodeStr(IntToStr4(BVal))))
  else SetValue(Node, NewNode(FloatToStr(DBVal)));
end;

function TKernel.Compare(Node: TNode): Boolean;
var i: Integer;
begin
  Result := False;
  if Node = nil then Exit;
  if Node.FType = ntNumber then
  begin
    if StrToFloat8(Node.Data) = 1 then
      Result := True;
    Exit;
  end;
  if Node.FType = ntString then
  begin
    if Node.Data <> '' then
      Result := True;
    Exit;
  end;
end;


procedure TKernel.Run(Node: TNode);
var
  FuncResult, i: Integer;
begin
  while True do
  begin
    if Node = nil then Exit;
    if Node.FType = ntModule then
      LoadModule(Node);
    for i:=0 to High(Node.Params) do
      Run(Node.Params[i]);
    if (Node.Source <> nil) and (((Node.Source.ParentLocal = FUnit) and (Node.Source.Next <> nil))   //recode  2
      or (Node.Source.FType = ntDLLFunc)) then
    begin
      for i:=0 to High(Node.Params) do
        SetParam(GetSource(Node), GetValue(Node.Params[i]), i);
      Run(Node.Source);
    end;
    if Node.FType = ntDLLFunc then
      Call(Node);
    if (Node.FTrue <> nil) or (Node.FElse <> nil) then
    begin
      if Compare(GetValue(Node)) then
        if Node.FTrue <> nil then
        begin
          Node := GetSource(Node.FTrue);
          Continue;
        end
      else
        if Node.FElse <> nil then      
        begin
          Node := GetSource(Node.FElse);
          Continue;
        end;
    end
    else
    if (Node.Source <> nil) and (Node.Value <> nil) then
    begin
      Run(Node.Value);
      Node.Source.Value := GetValue(Node.Value);
    end;
    Node := Node.Next;
  end;
end;


procedure TKernel.SaveNode(Node: TNode);
var
  Indexes: AString;
  Body: String;
  Buf: TNode;
begin
  Buf := Node;
  SetLength(Indexes, 0);
  while Buf <> Root do
  begin
    SetLength(Indexes, Length(Indexes) + 1);
    Indexes[High(Indexes)] := Buf.IndexName;
    Buf := Buf.ParentIndex;
  end;
  SetLength(Indexes, Length(Indexes) + 1);
  Indexes[High(Indexes)] := Root.Attr[naRootPath];
  if (Length(Indexes) > 1) and (Indexes[High(Indexes) - 1] <> sID) then Exit;
  ToFileSystemName(Indexes);
  Body := GetNodeBody(Node);
  SaveToFile(CreateDir(Indexes) + NodeFileName, Body);
end;


procedure TKernel.SaveBranch(Node: TNode); //or Branch
var i: Integer;
begin
  SaveNode(Node);
  for i:=0 to High(Node.IndexChilds) do
    SaveBranch(Node.IndexChilds[i]);
end;


procedure TKernel.FreeBranch(Node: TNode);
var i: Integer;
begin
  for i:=0 to High(Node.IndexChilds) do
    FreeBranch(Node.IndexChilds[i]);
  if Node <> Root then
    Node.Free
  else
    Clear(Root.IndexChilds);
end;


function TKernel.GetIndex(Node: TNode): String;
begin
  Result := '';
  if Node <> nil then
    while Node.ParentIndex <> nil do
    begin
      Result := Node.IndexName + Result;
      Node := Node.ParentIndex;
    end;
end;


function TKernel.GetNodeBody(Node: TNode): String;
var
  i: Integer;
begin
  Result := '';
  if Node = nil then Exit;

  if Node.ParentName <> nil then
    Result := Result + GetIndex(Node.ParentName);

  Result := Result + GetIndex(Node);

  if Node.Source <> nil then
    Result := Result + sSource + GetIndex(Node.Source);

  if Node.Attributes <> nil then
  begin
    for i:=0 to Node.Attributes.High do
      Result := Result + Node.Attributes.Names[i] + sVal + Node.Attributes.Values[i] + sAnd;
    Delete(Result, Length(Result) - Length(sAnd) + 1, Length(sAnd));
  end;


  if Node.ValueType <> nil then
    Result := Result + sType + GetIndex(Node.ValueType);

  if Length(Node.Params) > 0 then
  begin
    Result := Result + sParams;
    for i:=0 to High(Node.Params) do
      Result := Result + GetIndex(Node.Params[i]) + sAnd;
    Delete(Result, Length(Result) - Length(sAnd) + 1, Length(sAnd));
  end;

  if Node.Data <> '' then
    Result := Result + sValue + sData + EncodeStr(Node.Data)
  else
  if Node.Value <> nil then
    Result := Result + sValue + GetIndex(Node.Value);

  if Node.FTrue <> nil then
    Result := Result + sTrue + GetIndex(Node.FTrue);

  if Node.FElse <> nil then
    Result := Result + sElse + GetIndex(Node.FElse);

  if Node.Next <> nil then
    Result := Result + sNext + GetIndex(Node.Next);

  for i:=0 to High(Node.Local) do
    Result := Result + sLocal + GetIndex(Node.Local[i]);
end;


function TKernel.UserNode(Line: String): TNode;
var
  Link: TLink;
begin
  Link := TLink.UserParse(Line);
  Result := NewNode(Link);
  Link.Free;
  NextNode(Prev, Result);
  if Result <> nil then
  begin
    if MapExistName(Result.Attributes, naActivate) then
      Run(Result);
  end;
end;




end.
