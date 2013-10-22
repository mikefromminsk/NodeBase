unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ScktComp;

type
  TGG = class(TForm)
    InputBox: TRichEdit;
    OutputBox: TRichEdit;
    Splitter: TSplitter;
    Server: TServerSocket;
    Timer1: TTimer;
    Button1: TButton;
    procedure InputBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ServerClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure InputBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  end;

var
  GG: TGG;

implementation

uses
  MetaBase, MetaUtils;

{$R *.dfm}

function M(Line: String; WriteToConsole: Boolean = True): String;
var
  Node, Data: PNode;
begin
  Node := Base.Get(Line);               
  if Node <> nil then
  begin
    Data := Base.GetData(Node);
    if Data <> nil then
      Result := Data.Name;
    if Length(Result) = 4 then
      Result := IntToStr(StrToInt4(Result))
    else if Length(Result) = 8 then
      Result := FloatToStr(StrToFloat8(Result))
    else Result := EncodeName(Result);
  end;
  if Result = '' then
    Result := 'NULL';
  GG.OutputBox.Lines.Text := Result;
  if WriteToConsole then
    GG.InputBox.Lines.Add(Line);
end;

function HttpResponse(Line: String): String;
begin
  Result := 'HTTP/1.1 200 OK'#13#10#13#10 +
  '<html><head></head><body>' + M(Line) + '</body></html>';
end;

procedure TGG.ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
var List: TStrings;
begin                      
  List := TStringList.Create;
  List.Text := Socket.ReceiveText;
  List.Delimiter := ' ';
  List.DelimitedText := List.Strings[0];
  Socket.SendText(HttpResponse(Copy(List.Strings[1], 2, MaxInt)));
  Socket.Close;
  List.Free;
end;

procedure MessageLog(Message: String);
var Log: TextFile;
begin
  AssignFile(Log, 'M.log');
  WriteLn(Log, '[' + DateToStr(Now) + ']: ' +  Message);
  CloseFile(Log);
end;

procedure TGG.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  MessageLog(E.ClassName + ' : ' + E.Message);
end;

procedure TGG.ServerClientError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  MessageLog('SocketError ' + IntToStr(ErrorCode));
end;

procedure TGG.InputBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_F9) then Close;
end;

procedure TGG.InputBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    M(InputBox.Lines[InputBox.Lines.Count-1], False);
end;

procedure TGG.FormCreate(Sender: TObject);
var i: Integer;
begin
  for i:=0 to InputBox.Lines.Count - 1 do
    M(InputBox.Lines[i], False);
  InputBox.SelStart := Length(InputBox.Lines.Text);
end;

procedure TGG.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  //with Params do Style := (Style OR WS_POPUP) AND NOT WS_DLGFRAME;
end;


procedure TGG.Timer1Timer(Sender: TObject);
begin
  GG.Caption := IntToStr(Base.NodeCount);
end;

var
  NodeCount,
  NodeData,
  NodeIndex,
  NodeWord,
  NodeLink,
  NodeFile,
  NodeFunc,
  NodeNumber,
  NodePointer,
  NodeOther
  : Integer;

procedure RecGoTree(Node: PNode);
var i: Integer;
begin
  for i:=0 to High(Node.Index) do
  begin
    RecGoTree(Node.Index[i]);
  end;
  Inc(NodeCount);
  case Node.Attr of
    naData: Inc(NodeData);
    naIndex: Inc(NodeIndex);
    naWord: Inc(NodeWord);
    naLink: Inc(NodeLink);
    naFile: Inc(NodeFile);
    naFunc: Inc(NodeFunc);
    naNumber: Inc(NodeNumber);
    naPointer: Inc(NodePointer);
  else
    Inc(NodeOther);
  end;

end;

procedure TGG.Button1Click(Sender: TObject);
begin
  NodeCount := 0;
  NodeData := 0;
  NodeIndex := 0;
  NodeWord := 0;
  NodeLink := 0;
  NodeFile := 0;
  NodeFunc := 0;
  NodeNumber := 0;
  NodePointer := 0;
  NodeOther := 0;
  RecGoTree(Base.Root);
  ShowMessage(#10'NodeCount = ' + IntToStr(NodeCount) +
              #10'NodeData = ' + IntToStr(NodeData) +
              #10'NodeIndex = ' + IntToStr(NodeIndex) +
              #10'NodeWord = ' + IntToStr(NodeWord) +
              #10'NodeLink = ' + IntToStr(NodeLink) +
              #10'NodeFile = ' + IntToStr(NodeFile) +
              #10'NodeFunc = ' + IntToStr(NodeFunc) +
              #10'NodeNumber = ' + IntToStr(NodeNumber) +
              #10'NodePointer = ' + IntToStr(NodePointer) +
              #10'NodeOther = ' + IntToStr(NodeOther)  );
end;

end.

