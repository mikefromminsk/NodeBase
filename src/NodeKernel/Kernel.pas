unit Kernel;

interface

uses
  Link, Utils, Dialogs;

type
  TNode = class;
  ANode = array of TNode;


  TNode = class
    Path          : String;          //test
    Name          : String;
    Data          : String;
    Source        : TNode;
    ValueType     : TNode;
    Params        : ANode;
    Local         : ANode;
    Value         : TNode;
    FTrue         : TNode;
    FElse         : TNode;
    Prev          : TNode;
    Next          : TNode;

    Index         : ANode;
    ParentIndex   : TNode;
    ParentName    : TNode;
    ParentParams  : TNode;
    ParentLocal   : TNode;

    FType       : Integer;
    RunCount    : Integer;
    Activate    : Integer;
    Handle      : Integer;

    Vars        : TMap;
  end;


  TKernel = class
    LastID    : Integer;
    Root      : TNode;
    Prev      : TNode;
    FUnit     : TNode;


    Options: TMap;
    NodesCount: Integer; //test

    constructor Create;

    function NextID: String;

    procedure SetName(var Node: TNode; Name: String);
	  function FindName(Index: TNode): TNode;
    function FindNameInNode(Node: TNode; Index: TNode): TNode;

    function NewIndex(Name: String): TNode;

	  procedure SetSource({var} Node: TNode; Source: TNode);
	  function GetSource(Node: TNode): TNode;

    procedure SetVars(Node: TNode; Param, Value: String);
    function GetVars(Node: TNode): String;

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
    procedure RecursiveSave(Node: TNode);
    procedure RecursiveDispose(Node: TNode);
    procedure Clear;

    procedure CallFunc(Node: TNode);
    procedure Run(Node: TNode);

	  function GetIndex(Node: TNode): String;
    function GetNodeBody(Node: TNode): String;

    function Execute(Line: String): TNode; virtual;
  end;

implementation

{ TKernel }

constructor TKernel.Create;
begin

  Options := TMap.Create(LoadFromFile(OptionsFileName), #10);
  LastID := StrToIntDef(Options.GetValue('LastID'), 0);
  Root := TNode.Create;
  Root.FType := naRoot;
  Root.Name :=  StrToDef(Options.GetValue('RootName'), 'data');

  FUnit := NewNode('module');
end;


function TKernel.NextID: String;
begin
  Inc(LastID);
  Result := sID + IntToStr(LastID);
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
      if Local.FType = naModule then
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
  function AddIndex(Node: TNode; Name: Char): TNode;
  begin
    SetLength(Node.Index, Length(Node.Index) + 1);
    Result := TNode.Create;
    Node.Index[High(Node.Index)] := Result;
    Result.FType := naEmpty;
    Result.Name := Name;
    Result.ParentIndex := Node;
    Result := Node.Index[High(Node.Index)];
    Inc(NodesCount);
    Result.Path := GetIndex(Result); //test
  end;
begin
  Result := Root;
  for i:=1 to Length(Name) do
  begin
    Index := -1;
    for j:=0 to High(Result.Index) do
      if  Result.Index[j].Name = Name[i] then
      begin
        Index := j;
        Break;
      end;
    if Index = -1
    then Result := AddIndex(Result, Name[i])
    else Result := Result.Index[Index];
  end;
  if Result = Root then
    Result := nil;
end;

procedure TKernel.SetVars(Node: TNode; Param, Value: String);
begin
       if Param = 'TYPE'     then Node.FType     := StrToIntDef(Value, 0)
  else if Param = 'RUN'      then Node.RunCount := StrToIntDef(Value, 1)
  else if Param = 'ACTIVATE' then Node.Activate := StrToIntDef(Value, 1)
  else if Param = 'HANDLE'   then Node.Handle   := StrToIntDef(Value, 0)
  else
  begin
    if Node.Vars = nil then
      Node.Vars := TMap.Create;
    Node.Vars.Push(Param, Value);
  end;    
end;


function TKernel.GetVars(Node: TNode): String;
begin
  Result := '';
  if Node = nil then Exit;
  if Node.FType <> 0 then
    Result := Result + '&' + 'TYPE' + '=' + IntToStr(Node.FType);
  if Node.RunCount <> 0 then
    Result := Result + '&' + 'RUN' + '=' + IntToStr(Node.RunCount);
  if Node.Activate <> 0 then
    Result := Result + '&' + 'ACTIVATE' + '=' + FloatToStr(Node.Activate);
  if Node.Handle <> 0 then
    Result := Result + '&' + 'HANDLE' + '=' + FloatToStr(Node.Handle);
  Delete(Result, 1, 1);
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
    SetLength(Node.Params, Length(Node.Params) + 1);
    Node.Params[High(Node.Params)] := Param;
  end
  else
  begin
    if Index = Length(Node.Params) then
    begin
      SetLength(Node.Params, Length(Node.Params) + 1);
      Node.Params[Index] := Param;
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
var ValueStack: ANode;
begin
  Result := nil;
  while Node <> nil do
  begin
    SetLength(ValueStack, Length(ValueStack) + 1);
    ValueStack[High(ValueStack)] := Node;
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
  SetLength(ValueStack, 0);
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
  SetLength(Node.Local, Length(Node.Local) + 1);
  if Node.FType = naEmpty
  then Local.ParentName  := Node
  else Local.ParentLocal := Node;
  Node.Local[High(Node.Local)] := Local;
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

    if Result.FType = naEmpty then
      LoadNode(Result);
  end;

  if Link.Name <> '' then
  begin
    SetName(Result, Link.Name);

    if Result.FType <> naLoad then   //Initialization
    begin
      case Link.Name[1] of
        '/' : Result.FType := naModule;
        '!' : Result.FType := naData;
        '0'..'9', '-': Result.FType := naNumber;
        else  Result.FType := naWord;
      end;

      if Result.FType = naWord then
        Result.Source := FindName(Result.ParentName);

      if Result.FType = naNumber then
      begin
        if Pos(sDecimalSeparator, Link.Name) = 0
        then Link.Name := sData + IntToStr4  (  StrToIntDef(Link.Name, 0))
        else Link.Name := sData + FloatToStr8(StrToFloatDef(Link.Name, 0));
        Result.FType := naData;
      end;

      if Result.FType = naData then
        SetData(Result, DecodeStr(Copy(Link.Name, 2, MaxInt)));
    end;



  end;


  if Result = nil then Exit;


  if Link.Source <> nil then
  begin
    if (Result.FType = naWord) and (Result.FType <> naLoad) then
    begin  //hardcode
      SetSource(GetSource(Result), NewNode(Link.Source));
      Result := GetSource(Result)
    end
    else
      SetSource(Result, NewNode(Link.Source));
  end;

  for i:=0 to Link.Vars.High do
    SetVars(Result, Link.Vars.Names[i], Link.Vars.Values[i]);

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
  Node.FType := naLoad;

  SetLength(Indexes, 0);
  while Node <> nil do
  begin
    SetLength(Indexes, Length(Indexes) + 1);
    Indexes[High(Indexes)] := Node.Name;
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
    if Node.Handle = 0 then
    begin
      Node.Handle := GetFunctionList(FileName, List);
      for i:=0 to High(List) do
      begin
        Func := NewNode(List[i]);
        Func.FType := naDLLFunc;
        Func.Handle := GetProcAddress(Node.Handle, List[i]);
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
      Execute(List[i]);
    FUnit := PrevModule;
  end;
end;


procedure TKernel.CallFunc(Node: TNode);
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
  Func := Node.Handle;
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
  else SetValue(Node, NewNode('!' + EncodeStr(FloatToStr8(DBVal))));

end;


procedure TKernel.Run(Node: TNode);
label NextNode;
var
  FuncResult, i: Integer;
  function CompareWithZero(Node: TNode): Integer;
  var i: Integer;
  begin
    Result := -1;
    if Node <> nil then
    begin
      Result := 0;
      for i:=1 to Length(Node.Data) do
        if Node.Data[i] <> #0 then
        begin
          Result := 1;
          Exit;
        end;
    end;
  end;
begin
  NextNode:
  if Node = nil then Exit;

  if Node.FType = naModule then
    LoadModule(Node);
  for i:=0 to High(Node.Params) do
    Run(Node.Params[i]);
  if (Node.Source <> nil) and (((Node.Source.ParentLocal = FUnit) and (Node.Source.Next <> nil))   //recode  2
    or (Node.Source.FType = naDLLFunc)) then
  begin
    for i:=0 to High(Node.Params) do
      SetParam(GetSource(Node), GetValue(Node.Params[i]), i);
    Run(Node.Source);
  end;
  if Node.FType = naDLLFunc then
    CallFunc(Node);
  if (Node.FTrue <> nil) or (Node.FElse <> nil) then
  begin
    FuncResult := CompareWithZero(GetValue(Node));
    if (FuncResult = 1) and (Node.FTrue <> nil) then
    begin
      Node := GetSource(Node.FTrue);
      Goto NextNode;
    end;
    if (FuncResult = 0) and (Node.FElse <> nil) then
    begin
      Node := GetSource(Node.FElse);
      Goto NextNode;
    end;
  end
  else
  if (Node.Source <> nil) and (Node.Value <> nil) then
  begin
    Run(Node.Value);
    Node.Source.Value := GetValue(Node.Value);
  end;

  Node := Node.Next;
  Goto NextNode;
end;


procedure TKernel.SaveNode(Node: TNode);
var
  Indexes: AString;
  Body: String;
  Buf: TNode;
begin
  Buf := Node;
  SetLength(Indexes, 0);
  while Buf <> nil do
  begin
    SetLength(Indexes, Length(Indexes) + 1);
    Indexes[High(Indexes)] := Buf.Name;
    Buf := Buf.ParentIndex;
  end;
  if (Length(Indexes) > 1) and (Indexes[High(Indexes) - 1] <> sID) then Exit;
  ToFileSystemName(Indexes);
  Body := GetNodeBody(Node);
  SaveToFile(CreateDir(Indexes) + NodeFileName, Body);
end;

procedure TKernel.RecursiveSave(Node: TNode);
var
  i: Integer;
begin
  SaveNode(Node);
  for i:=0 to High(Node.Index) do
    RecursiveSave(Node.Index[i]);
end;



procedure TKernel.RecursiveDispose(Node: TNode);
var i: Integer;
begin
  for i:=0 to High(Node.Index) do
    RecursiveDispose(Node.Index[i]);
  if Node <> Root then
  begin
    Node.Free;
  end
  else
    SetLength(Root.Index, 0);
end;


procedure TKernel.Clear;
begin
  //RecursiveSave(Root);
    Prev := nil;
  FUnit := nil;

  RecursiveDispose(Root);
  //ShowMessage(IntTOStr(NodeCount));


end;


function TKernel.GetIndex(Node: TNode): String;
begin
  Result := '';
  if Node <> nil then
    while Node.ParentIndex <> nil do
    begin
      Result := Node.Name + Result;
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

  Result := Result + sVars + GetVars(Node);

  if Node.ValueType <> nil then
    Result := Result + sType + GetIndex(Node.ValueType);

  if Length(Node.Params) > 0 then
  begin
    Result := Result + sParams;
    for i:=0 to High(Node.Params) do
      Result := Result + GetIndex(Node.Params[i]) + sParamAnd;
    Delete(Result, Length(Result) - Length(sParamAnd) + 1, Length(sParamAnd));
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


function TKernel.Execute(Line: String): TNode;
var
  Link: TLink;
begin
  Link := TLink.UserParse(Line);
  Result := NewNode(Link);
  Link.Free;
  NextNode(Prev, Result);
  if Result <> nil then
  begin
    if Result.Activate <> 0 then
    begin
      if Result.RunCount = 0 then
        Result.RunCount := 1;
      Run(Result);
      Result.Activate := 0;
    end;
  end;
end;

end.
