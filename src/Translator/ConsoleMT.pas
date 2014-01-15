unit ConsoleMT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, RegExpr, XMLIntf, XmlDoc, XmlDom;

type
  XTree = IXMLDocument;
  XNode = IXMLNode;

  TForm1 = class(TForm)
    StructEdit: TRichEdit;
    Button3: TButton;
    ResultEdit: TRichEdit;
    BuildStructEdit: TRichEdit;
    Button1: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Parse(Result, Struct: XNode);
    procedure Build(BResult, BStruct: XNode);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  r: TRegExpr;
  TStruct, TResult, BuildStruct, BuildResult: XTree;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  r := TRegExpr.Create;
  TStruct := TXMLDocument.Create(nil);
  TResult := TXMLDocument.Create(nil);
  BuildStruct := TXMLDocument.Create(nil);
  Button3.Click;
  Button1.Click;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  TStruct.XML.Text := StructEdit.Text;
  TStruct.Active := True;

  TResult.Active := True;
  TResult.ChildNodes.Clear;
  TResult.AddChild('data');
  TResult.DocumentElement.Attributes['d'] := Edit1.Text;

  Parse(TResult.DocumentElement, TStruct.DocumentElement);
  //Result.DocumentElement.Attributes['d'] := '';
  ResultEdit.Text := FormatXMLData(TResult.XML.Text);
end;

function FindNode(Root: XNode; NodeName: String): XNode;
var i: Integer;
begin
  Result := Root.ChildNodes.FindNode(NodeName);
  if Root.NodeName = NodeName then Result := Root;
  if Result = nil then
    for i:=0 to Root.ChildNodes.Count - 1 do
    begin
      Result := FindNode(Root.ChildNodes[i], NodeName);
      if Result <> nil then Exit;
    end;
end;


procedure TForm1.Parse(Result, Struct: XNode);
var
  Data, Cut, CutArr, IfExist, Inherit, Ext: String;
  Group: Integer;
  Node, StructNode: XNode;
  i, j: Integer;
  NodeName: String;
begin
  if (Result = nil) or (Struct = nil) then Exit;
  Data := VarToStr(Result.Attributes['d']);
  with Struct do
  begin
    Cut := VarToStr(Attributes['cut']);
    CutArr := VarToStr(Attributes['cutarray']);
    IfExist := VarToStr(Attributes['copy']);
    Group := StrToIntDef(VarToStr(Attributes['group']), 0);
    Inherit := VarToStr(Attributes['inherited']);
    Ext := VarToStr(Attributes['exit']);
  end;

  if Ext <> '' then
  begin
    r.Expression := Ext;

    if r.Exec(Data) then
    begin
      Node := Result.AddChild(Struct.NodeName);
      Node.Attributes['d'] := r.Match[Group];
      Delete(Data, r.MatchPos[0], r.MatchLen[0]);
      Result.Attributes['d'] := '';
      Result.ParentNode.Attributes['d'] := Result.ParentNode.Attributes['d'] + Data;
      Exit;
    end;
  end;

  if IfExist <> '' then
  begin
    r.Expression := IfExist;
    if r.Exec(Data) then
    begin
      Node := Result.AddChild(Struct.NodeName);
      Node.Attributes['d'] := Data;
      for i:=0 to Struct.ChildNodes.Count - 1  do
        Parse(Node, Struct.ChildNodes[i]);
      Result.Attributes['d'] := Data;
    end
    else
      Exit;
  end
  else
  if Cut <> '' then
  begin
    r.Expression := Cut;
    if r.Exec(Data) then
    begin
      Node := Result.AddChild(Struct.NodeName);
      Node.Attributes['d'] := r.Match[Group];
      Delete(Data, r.MatchPos[0], r.MatchLen[0]);
      Result.Attributes['d'] := Data;
      for i:=0 to Struct.ChildNodes.Count - 1  do
        Parse(Node, Struct.ChildNodes[i]);
    end;
  end
  else
  if CutArr <> '' then
  begin
    r.Expression := CutArr;
    if r.Exec(Data) then
      repeat
        if r.MatchLen[Group] = 0 then Continue;
        Node := Result.AddChild(Struct.NodeName);
        Node.Attributes['d'] := r.Match[Group];
        Result.Attributes['d'] := Data;
        for i:=0 to Struct.ChildNodes.Count - 1  do
          Parse(Node, Struct.ChildNodes[i]);
      until not r.ExecNext;
  end;



  if Inherit <> '' then
    begin
    {Node := Result.AddChild(Struct.NodeName);
    Node.Attributes['d'] := Data;}
    StructNode := FindNode(Struct.OwnerDocument.DocumentElement, Inherit);
    Parse(Result, StructNode);
  end;
  //ShowMessage(FormatXMLData(Result.OwnerDocument.XML.Text));
end;




procedure TForm1.Button1Click(Sender: TObject);
begin
  BuildStruct.XML.Text := BuildStructEdit.Text;
  BuildStruct.Active := True;

  Build(TResult.DocumentElement, BuildStruct.DocumentElement);
  ResultEdit.Text := FormatXMLData(TResult.XML.Text);
end;





function GetAttribut(Root: XNode; AttrName: String): String;
begin
  Result := '';
  if Root <> nil then
    Result := VarToStr(Root.Attributes[AttrName]);
end;



procedure TForm1.Build(BResult, BStruct: XNode);
var
  i: Integer;
  Str, S, Data: String;
  Node: XNode;
begin
  for i:=0 to BResult.ChildNodes.Count - 1 do
    Build(BResult.ChildNodes[i], BStruct);

  Str := GetAttribut(FindNode(BStruct, BResult.NodeName), 's');

  if Str <> '' then
  begin
    Data := Str;
    r.Expression := '\[(.*?)\]';
    if r.Exec(Str) then
      repeat
        Data := StringReplace(Data, r.Match[0], GetAttribut(BResult.ChildNodes.FindNode(r.Match[1]), 'd'), [rfReplaceAll]);
      until not r.ExecNext;
    BResult.Attributes['d'] := Data;
  end;

end;


end.
