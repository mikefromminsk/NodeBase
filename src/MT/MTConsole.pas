unit MTConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, XPMan, ComCtrls, XMLIntf, XmlDoc;

type

  XTree = IXMLDocument;
  XNode = IXMLNode;

  TGG = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    FromStruct: TComboBox;
    ToStruct: TComboBox;
    XPManifest1: TXPManifest;
    TabSheet2: TTabSheet;
    Panel4: TPanel;
    Button1: TButton;
    FromData: TRichEdit;
    ToData: TRichEdit;
    LeftBox: TEdit;
    RightBox: TEdit;
    Add: TButton;
    ActionBox: TComboBox;
    NameBox: TEdit;
    TreeView1: TTreeView;
    ResultBox: TRichEdit;
    DataBox: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure TabSheet1Show(Sender: TObject);
    function GetRightData: String;
    procedure SetRightData(Data: String);
    function GetLeftData: String;
    procedure SetLeftData(Data: String);
    function GetData: String;
    procedure SetData(Data: String);
    function GetAction: String;
    procedure SetAction(Data: String);
    function GetName: String;
    procedure SetName(Data: String);
    property RData: String read GetRightData write SetRightData;
    property LData: String read GetLeftData write SetLeftData;
    property Data: String read GetData write SetData;
    property Action: String read GetAction write SetAction;
    property Name: String read GetName write SetName;
    function XTag: String;
    procedure DataBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AddClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  GG: TGG;
  Files: TStringList;
  StructTree: XTree;
  StructNode: XNode;
implementation

{$R *.dfm}

function TGG.GetRightData: String;
begin
  Result := RightBox.Text;
end;

procedure TGG.SetRightData(Data: String);
begin
  RightBox.Text := Data;
end;

function TGG.GetLeftData: String;
begin
  Result := LeftBox.Text;
end;

procedure TGG.SetLeftData(Data: String);
begin
  LeftBox.Text := Data;
end;

function TGG.GetData: String;
begin
  Result := DataBox.Text;
end;

procedure TGG.SetData(Data: String);
begin
  DataBox.Text := Data;
end;

function TGG.GetName: String;
begin
  Result := NameBox.Text;
end;

procedure TGG.SetName(Data: String);
begin
  NameBox.Text := Data;
end;


function TGG.GetAction: String;
begin
  Result := ActionBox.Text;
end;

procedure TGG.SetAction(Data: String);
begin
  ActionBox.Text := Data;
end;

procedure FindFiles(Dir: String; Files: TStringList);
var SR: TSearchRec;
begin
  Files.Clear;
  if FindFirst(Dir + '\*', faAnyFile, SR) = 0 then
  try
    repeat
      if not ((SR.Name = '.') or (SR.Name = '..')) then
        Files.Add(SR.Name);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

procedure TGG.FormCreate(Sender: TObject);
begin
  CreateDir('structs');
  Files := TStringList.Create;

  StructTree := TXMLDocument.Create(nil);
  StructTree.Active := True;
  StructNode := StructTree.Node;
end;

procedure TGG.TabSheet1Show(Sender: TObject);
begin
  FindFiles('structs', Files);
  FromStruct.Text := Files.Text;
  ToStruct.Text := Files.Text;


end;

procedure TGG.DataBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if DataBox.SelText <> '' then
    LData := DataBox.SelText; 
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

function TGG.XTag: String;
begin
  Result := '<' + Name;
  if Action <> '' then
    Result := Result + ' Action="' + Action + '"';
  if LData <> '' then
    Result := Result + ' Left="' + LData + '"';
  if RData <> '' then
    Result := Result + ' Right="' + RData + '"';
  Result := Result + '>';
end;

procedure TGG.AddClick(Sender: TObject);
var Node: XNode;
begin
  Node := StructNode;
  with TreeView1 do
  begin
    Items.AddChild(Selected, XTag);
    FullExpand;
  end;
//  StructBox.Text := StructNode.XML;
end;

end.
