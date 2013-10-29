unit MetaLine;

interface

uses
  SysUtils, MetaUtils;

type

  TLine = class
  public
    Source  : String;
    Name    : String;
    ID      : String;
    Path    : array of String;
    ControlsNames: array of String;
    ControlsValues: array of String;       //property Controls[Index: Integer]: string read Get write Put;

    ParentLocal: String;


    FType: TLine;
    Local: array of TLine;
    Params: array of TLine;
    Value: TLine;
    FElse: TLine;
    constructor CreateName(SourceNode, NameNode, IdNode, ControlsNode: String);
    constructor CreateP(var LURI: String; FirstRun: Boolean = False);
    constructor Create(LURI: string);
    destructor Destroy;
    function GetLine: string;
  end;

{var
  IllegalChars  : Set of '$', '?', ':', '=', '&', ';', '#', '|';
  FileIlegalChars: Set of sdfafsdfasdf}

implementation


destructor TLine.Destroy;
var i: Integer;
begin           
  if FType <> nil then
    FType.Destroy;
  for i:=0 to High(Params) do
    if Params[i] <> nil then
      Params[i].Destroy;
  if Value <> nil then
    Value.Destroy;
  if FElse <> nil then
    FElse.Destroy;
  for i:=0 to High(Local) do
    if Local[i] <> nil then
      Local[i].Destroy;
  inherited Destroy;
end;

constructor TLine.CreateName(SourceNode, NameNode, IDNode, ControlsNode: String);
begin
  inherited Create;
  if IdNode = '' then Exit;
  if SourceNode <> '' then
    Source := SourceNode;
  if NameNode <> '' then
    Name := NameNode;
  ID := IDNode;
  if ControlsNode <> '' then
    Name := Name + '$' + ControlsNode;
end;

constructor TLine.Create(LURI: string);
begin
  CreateP(LURI, True);
end;

constructor TLine.CreateP(var LURI: String; FirstRun: Boolean = False);
var
  S, LS: string;
  Index, i, dx: Integer;
begin
  if length(LURI) = 0 then Exit;
  Name := '';

  Index := NextIndex(0, [' '], LURI);
  if Index <> MaxInt then
  begin
    LS := Copy(LURI, Index + 1, MaxInt);
    Delete(LURI, Index, MaxInt);
  end;

  while Length(LS) > 0 do
  begin
    Index := NextIndex(0, [' '], LS);
    s := Copy(LS, 1, Index-1);
    SetLength(Local, High(Local)+2);
    Local[High(Local)] := TLine.CreateP(s);
    Delete(LS, 1, Index);
  end;

  Index := NextIndex(0, ['?', ':', '=', '&', ';', '#', '|'], LURI);


  if Index > 1 then
  begin
    ID := Copy(LURI, 1, Index - 1);    //ID
    Source := Copy(ID, 1, Pos('^', ID) - 1);
    Delete(ID, 1, Pos('^', ID));
    if Length(ID) > 0 then
    begin
      ParentLocal := Copy(ID, 1, Pos('@', ID) - 1);
      Delete(ID, 1, Pos('@', ID)-1);
    end;
    Delete(LURI, 1, Index-1);

    if NextIndex(0, ['\', '/'], ID) <> MaxInt then
    begin
      for i:=0 to Length(ID) do
        if ID[i] = '\' then
          ID[i] := '/';
      if not (ID[1] in ['\', '/']) then
        ID := '/' + ID;
      SetLength(Path, 1);
      Path[0] := ID;
    end
    else
    if ID[1] <> '!' then
    begin
      if Pos('$', ID) <> 0 then
      begin
        S := UpperCase(Copy(ID, Pos('$', ID) + 1, MaxInt));
        Delete(ID, Pos('$', ID), MaxInt);
        while S <> '' do
        begin
          SetLength(ControlsNames, High(ControlsNames) + 2);
          SetLength(ControlsValues, High(ControlsValues) + 2);
          ControlsNames[High(ControlsNames)] := S[1];
          Delete(S, 1, 1);
          for i:=1 to Length(S) do
            if not (S[i] in ['0'..'9', ',', '.']) then
              Break;
          ControlsValues[High(ControlsValues)] := Copy(S, 1, i-1);
          Delete(S, 1, i-1);
        end;
      end;
      while Pos('..', ID) <> 0 do
        Insert('0', ID, Pos('..', ID) + 1);
      i := 1;
      dx := 0;
      while dx <> MaxInt do
      begin
        dx := PosI(i, '.', ID);
        SetLength(Path, High(Path)+2);
        Path[High(Path)] := Copy(ID, i, dx - i);
        i := dx + 1;
      end;
      if Path[High(Path)] = '' then
        Path[High(Path)] := '0';
      ID := Path[0];
    end
    else
    begin
      SetLength(Path, 1);
      Path[0] := ID;
    end;
    
    if Length(LURI) = 0 then Exit;
  end;

  if LURI[1] = '|' then
  begin
    Exit;
  end;

  if LURI[1] = ':' then
  begin
    Delete(LURI, 1, 1);
    Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

    if Index = MaxInt then
    begin
      FType := TLine.CreateP(LURI);
      Delete(LURI, 1, Length(LURI));
    end
    else
    if LURI[Index] = '=' then
    begin
      s := Copy(LURI, 1, Index-1);
      FType := TLine.CreateP(s);
      Delete(LURI, 1, Index);
      Value := TLine.CreateP(LURI);
    end
    else
    begin
      if Length(LURI) > 0 then
        FType := TLine.CreateP(LURI);
    end;
    Exit;
  end;

  if LURI[1] = '=' then
  begin
    Delete(LURI, 1, 1);
    {Index := NextIndex(0, ['&', '#'], LURI);
    s := Copy(LURI, 1, Index-1);
    Delete(LURI, 1, Index-1);}
    Value := TLine.CreateP(LURI);
    Exit;
  end;

  if LURI[1] = ';' then
  begin
    Delete(LURI, 1, 1);
    Exit;
  end;


  if LURI[1] = '?' then
  begin
    Delete(LURI, 1, 1);
    repeat
      Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

      if (Index = MaxInt) or (LURI[Index] = ';') then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLine.CreateP(s);
        end
        else
          Break;
        Exit;
      end;

      if LURI[Index] in [':', '='] then
      begin
        SetLength(Params, High(Params)+2);
        Params[High(Params)] := TLine.CreateP(LURI);
        Continue;
      end;

      if LURI[Index] = '&' then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLine.CreateP(s);
        end;
        Continue;
      end;

      if LURI[Index] = '#' then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index-1);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLine.CreateP(s);
        end;
        Break;
      end;

      if LURI[Index] = '?' then
      begin
        SetLength(Params, High(Params)+2);
        Params[High(Params)] := TLine.CreateP(LURI);
      end;

    until False;
  end;

  if (Length(LURI) > 0) and (LURI[1] = '#') and (FirstRun = True) then
  begin
    Delete(LURI, 1, 1);
    Value := TLine.CreateP(LURI);
  end;

  if (Length(LURI) > 0) and (LURI[1] = '|') then
  begin
    Delete(LURI, 1, 1);
    FElse := TLine.CreateP(LURI);
  end;

end;

function TLine.GetLine: String;
var i: Integer;
begin
  if Source <> '' then
    Result := Source + '^';
  Result := Result + Name + ID;
  for i:=0 to High(ControlsNames) do
    Result := Result + ControlsNames[i] + ControlsValues[i];
  if FType <> nil then
    Result := Result + ':' + FType.GetLine;
  if Params <> nil then
  begin
    Result := Result + '?';
    for i:=0 to High(Params) do
    begin
      Result := Result + StringReplace(Params[i].GetLine, '#', '=', []);
      if i <> High(Params) then
        Result := Result + '&';
    end;
    Result := Result + ';';
  end;
  if Value <> nil then
    if (Params <> nil) or (FElse <> nil)
    then Result := Result + '#' + Value.GetLine
    else Result := Result + '=' + Value.GetLine;
  if FElse <> nil then
    Result := Result + '|' + FElse.GetLine;
  for i:=0 to High(Local) do
    Result := Result + ' ' + Local[i].GetLine;
end;


{procedure TMeta.SaveNode(Node: PNode);
var
  Line: TLine;
  List: TStringList;
  IndexNode, IndexWin: String;
  i: Integer;
  Parent, BufNode: PNode;

function SaveName(Node: PNode): String;
begin
  Result := '';
  if Node = nil then Exit;
  if (Node.Attr = naData) or (Node.Attr = naFile) or (Node.Attr = naLink)
  then Result := EncodeName(GetIndex(Node), 2)
  else Result := EncodeName(GetIndex(Node), 1);
end;

begin
  if Node = nil then Exit;

  //with TLine.CreateName(SaveName(Node.Source), SaveName(Node.ParentName), SaveName(Node), '') of
  //begin
  {List := TStringList.Create;
  Line :=

  if Node.Attr <> naIndex then
  begin
    List.Text := Line.GetLine;
    if Node.Next <> nil then
      List.Add(SaveName(Node.Next));
    for i:=0 to High(Node.Local) do
      List.Add(#10 + SaveName(Node.Local[i]));

    IndexNode := GetIndex(Node);
    IndexWin  := RootPath;
    for i:=1 to Length(IndexNode) do
    begin
      if IndexNode[i] in [#0..#32, '/', '\', ':', '*', '?', '@', '"', '<', '>', '|']
      then IndexWin := IndexWin + '\' + IntToHex(Ord(IndexNode[i]), 2)
      else IndexWin := IndexWin + '\' + IndexNode[i];
        CreateDir(IndexWin);
    end;

    List.SaveToFile(IndexWin + '\Node.meta');

    if Node.Source <> nil then
      Dec(Node.Source.RefCount);
  end;


  Line.Free;
  List.Free; 
  end;

end;      }

end.

