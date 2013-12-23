unit Parser;

interface

uses
  SysUtils, StrUtils, Math, XMLIntf, XmlDoc, Variants;

type
  XTree = IXMLDocument;
  XNode = IXMLNode;

  function RunParser(Mask: String; Data: String): String;

implementation

function PosMem(SubStr, S: String; Index: Integer = 1): Integer;
var
  i, j: Integer;
begin
  if Index < 1 then
    Index := 1;
  if Index <= Length(S) then
  if Length(SubStr) > 0 then
  for i:=Index to Length(S) do
    if S[i] = SubStr[1] then
    begin
      Result := i;
      for j:=1 to Length(SubStr) do
        if S[i+j-2] <> SubStr[j] then
          Break;
      if j = Length(SubStr) then
        Exit;
    end;
  Result := 0;
end;

function PosI(PosI: Integer; Substr: String; S: String): Integer;
begin
  Delete(S, 1, PosI);
  Result := Pos(Substr, S);
  if Result <> 0 
  then Inc(Result, PosI)
  else Result := High(Integer);
end;

function EncodeName(Str: String; Position: Integer = 1): String;
var i: Integer;
begin
  Result := Copy(Str, 1, Position - 1);
  for i:=Position to Length(Str) do
    if Str[i] in [#0..#32, '@', '^', '.', '?', ':', '=', '&', ';', '#', '|']
    then Result := Result + '%' + IntToHex(Ord(Str[i]), 2)
    else Result := Result + Str[i];
end;

function DecodeName(Str: String): String;
var
  i: integer;
  ESC: string[2];
  CharCode: integer;
begin
  Result := '';
  i := 1;
  while i <= Length(Str) do
  begin
    if Str[i] <> '%' then
      Result := Result + Str[i]
    else
    begin
      Inc(i);
      ESC := Copy(Str, i, 2);
      Inc(i, 1);
      CharCode := StrToIntDef('$' + ESC, -1);
      if (CharCode >= 0) and (CharCode <= 255) then
        Result := Result + Chr(CharCode);
    end;
    Inc(i);
  end;
end;

function NextIndex(AText: String; Index: Integer; const AValues: array of string): Integer;
var
  I, PosIndex: Integer;
begin
  Result := High(Integer);
  for I := Low(AValues) to High(AValues) do
  begin
    PosIndex := PosI(Index, AValues[I], AText);
    if PosIndex < Result then
      Result := PosIndex;
  end;
end;

function CopyMem(S: String; Index, Count: Integer): String;
var
  i, Len: Integer;
begin
  Len := Length(S);
  if Index < 1 then
    Index := 1;
  if Count = High(Integer) then
    Count := High(Integer) - Index + 1;
  if Index <= Len then
  for i:=Index to Index+Count-1 do
    if i <= Len
    then Result := Result + S[i]
    else Break;
end;

function CutString(var Str: String; Mask: String): String;
var
  LMask, RMask: String;
  Index, Count: Integer;
  LTag, RTag: String;
  PosLTag, PosRTag: Integer;
  PosDelim: Integer;
begin
  Result := '';
  if Mask = '' then Exit;
  Result := Str;

  PosDelim := PosMem('*', Mask);
  LMask := Copy(Mask, 1, PosDelim-1);
  RMask := Copy(Mask, PosDelim + 1, High(Integer));
  Index := StrToIntDef(LMask, Low(Integer));
  Count := StrToIntDef(RMask, High(Integer));
  LTag := IfThen(Index = Low(Integer), DecodeName(LMask));
  RTag := IfThen(Count = High(Integer), DecodeName(RMask));

  PosLTag := PosMem(LTag, Result);
  PosRTag := PosMem(RTag, Result, PosLTag);
  if PosRTag = 0 then
    PosRTag := High(Integer);

  Delete(Str, Max(Max(Index, PosLTag),1), Min(Count, PosRTag));

  if PosLTag <> 0 then
    Inc(PosLTag, Length(LTag));
  if PosRTag <> 0 then
    Dec(PosRTag, Length(RTag));
  Result := CopyMem(Result, Max(Index, PosLTag), Min(Count, PosRTag));
end;


function RecPars(Str: String; MaskRoot: XNode; ResultRoot: XNode): String;
var
  Attr, Value: Variant;
  PartMask, Part, Mask, ValueStr, S: String;
  Root, Node: XNode;
  Index: Integer;

  function Down(S: String; MaskRoot: XNode; ResultRoot: XNode): String;
  begin
    if S <> '' then
    begin
      Node := ResultRoot.AddChild(MaskRoot.NodeName);
      Node.SetAttribute('Data', S);
    end;

    Root := MaskRoot.ChildNodes.First;
    while Root <> nil do
    begin
      S := RecPars(S, Root, Node);
      Root := Root.NextSibling;
    end;
    Result := S;
  end;

begin
  Index := 0;
  Result := MaskRoot.NodeName;

  Attr := MaskRoot.GetAttribute('Mask');
  if VarType(Attr) = varOleStr then
    Mask := Attr;

  repeat
    Index := NextIndex(Mask, 0, ['.', ':', ';']);
    if Index = High(Integer) then Break;

    PartMask := Copy(Mask, 1, Index - 1);


    S := CutString(Str, PartMask);

    if (Mask[Index] = '.') or (Mask[Index] = ';') then
      S := Down(S, MaskRoot, ResultRoot);

    if (S <> '') and (Mask[Index] = ';') then
      Break;

    if (S <> '') and (Mask[Index] = ':') then
      while S <> '' do
      begin
        Down(S, MaskRoot, ResultRoot);
        S := CutString(Str, PartMask);
      end;

    Delete(Mask, 1, Index);
  until Index = High(Integer);

  Result := Str;
end;


function RunParser(Mask: String; Data: String): String;
var
  MaskTree, ShemeTree: XTree;
begin
  MaskTree := TXMLDocument.Create(nil);
  MaskTree.XML.Text := Mask;
  MaskTree.Active := True;

  ShemeTree := TXMLDocument.Create(nil);
  ShemeTree.Active := True;

  RecPars(Data, MaskTree.ChildNodes.First, ShemeTree.Node);

  Result := ShemeTree.XML.Text;
end;



end.