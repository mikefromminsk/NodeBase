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
    procedure FormShow(Sender: TObject);
    function Send(Line: String; WriteToConsole: Boolean = False): String;
    procedure FormDestroy(Sender: TObject);
    procedure OutputBoxKeyPress(Sender: TObject; var Key: Char);
  private
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
  end;

var
  GG: TGG;

implementation

uses
  MetaBase, MetaUtils, MetaLine;

{$R *.dfm}

function TGG.Send(Line: String; WriteToConsole: Boolean = False): String;
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
  '<html><head></head><body>' + GG.Send(Line) + '</body></html>';
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
    Send(InputBox.Lines[InputBox.Lines.Count-1]);
end;

procedure TGG.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do Style := (Style or WS_POPUP) and not WS_DLGFRAME;
end;

procedure TGG.FormCreate(Sender: TObject);
var i: Integer;
begin
  //RegisterHotKey(GG.Handle, VK_F9, 0, VK_F9);
  for i:=0 to InputBox.Lines.Count - 1 do
    Send(InputBox.Lines[i]);
end;

procedure TGG.FormShow(Sender: TObject);
begin
  InputBox.SelStart := Length(InputBox.Lines.Text);
end;

procedure TGG.WMHotKey(var Msg: TWMHotKey);
begin
  ShowMessage('1');
end;

procedure TGG.FormDestroy(Sender: TObject);
begin
  //UnRegisterHotKey(GG.Handle, VK_F9);
end;

procedure TGG.OutputBoxKeyPress(Sender: TObject; var Key: Char);
begin
  ShowMessage(IntToStr(Ord(Key)));
end;

end.

