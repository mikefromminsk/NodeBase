unit MetaLine;

interface

uses
  SysUtils, MetaUtils;

type

  TLine = class
  public
    Name: string;
    Path: array of string;
    ParentLocal: string;
    Source: string;
    FType: TLine;
    Local: array of TLine;
    Params: array of TLine;
    Value: TLine;
    FElse: TLine;
    constructor CreateP(var LURI: String; FirstRun: Boolean = False);
    constructor Create(LURI: string);
    destructor Destroy;
    function GetLink: string;
  end;


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
end;

constructor TLine.Create(LURI: string);
begin
  CreateP(LURI, True);
end;

constructor TLine.CreateP(var LURI: String; FirstRun: Boolean = False);
var
  s, LS: string;
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
    Name := Copy(LURI, 1, Index - 1);    //Name
    Source := Copy(Name, 1, Pos('^', Name) - 1);
    Delete(Name, 1, Pos('^', Name));
    if Length(Name) > 0 then
    begin
      ParentLocal := Copy(Name, 1, Pos('@', Name) - 1);
      Delete(Name, 1, Pos('@', Name)-1);
    end;
    Delete(LURI, 1, Index-1);
    
    if NextIndex(0, ['\', '/'], Name) <> MaxInt then
    begin
      for i:=0 to Length(Name) do
        if Name[i] = '\' then
          Name[i] := '/';
      if not (Name[1] in ['\', '/']) then
        Name := '/' + Name;
      SetLength(Path, 1);
      Path[0] := Name;
    end
    else
    if Name[1] <> '!' then
    begin
      while Pos('..', Name) <> 0 do
        Insert('0', Name, Pos('..', Name) + 1);
      i := 1;
      dx := 0;
      while dx <> MaxInt do
      begin
        dx := PosI(i, '.', Name);
        SetLength(Path, High(Path)+2);
        Path[High(Path)] := Copy(Name, i, dx - i);
        i := dx + 1;
      end;
      if Path[High(Path)] = '' then
        Path[High(Path)] := '0';
      Name := Path[0];
    end
    else
    begin
      SetLength(Path, 1);
      Path[0] := Name;
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

function TLine.GetLink: String;
var
  i: Integer;
begin
  if Source <> '' then
    Result := Source + '^';
  Result := Result + ParentLocal + Name;
  Result := Name;
  if FType <> nil then
    Result := Result + ':' + FType.GetLink;
  if Params <> nil then
  begin
    Result := Result + '?';
    for i:=0 to High(Params) do
    begin
      Result := Result + StringReplace(Params[i].GetLink, '#', '=', []);
      if i <> High(Params) then
        Result := Result + '&';
    end;
    Result := Result + ';';
  end;
  if Value <> nil then
    if (Params <> nil) or (FElse <> nil)
    then Result := Result + '#' + Value.GetLink
    else Result := Result + '=' + Value.GetLink;
  if FElse <> nil then
    Result := Result + '|' + FElse.GetLink;
  for i:=0 to High(Local) do
    Result := Result + ' ' + Local[i].GetLink;
end;

end.

