unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ScktComp, AppEvnts, ShellApi,
  IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TGG = class(TForm)
    OutputBox: TRichEdit;
    Splitter: TSplitter;
    Timer1: TTimer;
    QueryBox: TRichEdit;
    Splitter1: TSplitter;
    InputBox: TRichEdit;
    IdHTTPServer1: TIdHTTPServer;
    procedure InputBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InputBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormShow(Sender: TObject);
    function ConsoleExec(Line: String; WriteToConsole: Boolean = False): String;
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure IdHTTPServer1CreatePostStream(ASender: TIdPeerThread;
      var VPostStream: TStream);
    procedure IdHTTPServer1Exception(AThread: TIdPeerThread;
      AException: Exception);
  private
    procedure ControlWindow(var Msg: TMessage); message WM_SYSCOMMAND;
    procedure IconMouse(var Msg: TMessage); message WM_USER + 1;
    procedure Ic(n: Integer; Icon: TIcon);
  end;

var
  GG: TGG;

implementation

uses
  MetaBase, MetaUtils, MetaLine, IdHTTPHeaderInfo;

{$R *.dfm}

function TGG.ConsoleExec(Line: String; WriteToConsole: Boolean = False): String;
var
  Node, Data: PNode;
begin
  Node := Base.Exec(Line);
  if Node <> nil then
  begin
    Data := Base.GetData(Node);
    if Data <> nil then
    begin
      Result := Data.Name;
      if Length(Result) = 4 then
        Result := IntToStr(StrToInt4(Result))
      else
        if Length(Result) = 8 then
          Result := FloatToStr(StrToFloat8(Result))
        else
          Result := EncodeName(Result);
    end;
  end;
  if Result = '' then
    Result := 'NULL';
  GG.OutputBox.Lines.Text := Result;
  if WriteToConsole then
    GG.InputBox.Lines.Add(Line);
end;

function HttpResponse(Line: String): String;
begin
  Result := 'HTTP/1.1 200 OK'#10#10 + Line;
  GG.QueryBox.Text := GG.QueryBox.Text + Result;
  GG.QueryBox.Lines.Add('************************'#10);
end;

procedure TGG.InputBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F9 then Close;
  if Key = VK_ESCAPE then PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TGG.InputBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    ConsoleExec(InputBox.Lines[InputBox.Lines.Count-1]);
end;

//Style Form mini
procedure TGG.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do Style := (Style or WS_POPUP) and not WS_DLGFRAME;
end;

procedure TGG.FormCreate(Sender: TObject);
var
  i: Integer;
  Options: TStringList;
const
  OptionsFileName = 'config.ini';
begin
  if FileExists(OptionsFileName) then
  begin
    Options := TStringList.Create;
    Options.LoadFromFile(OptionsFileName);
    IdHTTPServer1.DefaultPort := StrToIntDef(Options.Values['ServerPort'], 80);
    Options.Free;
  end;
  try
    IdHTTPServer1.Active := True;
    QueryBox.Lines.Add('DefaultPort: ' + IntToStr(IdHTTPServer1.DefaultPort));
  except
    on E: Exception do
      QueryBox.Lines.Add('Error: Port ' + IntToStr(IdHTTPServer1.DefaultPort) + ' already open. Change ServerPort in config file.');
  end;
  for i:=0 to InputBox.Lines.Count - 1 do
    ConsoleExec(InputBox.Lines[i]);
end;

procedure TGG.FormShow(Sender: TObject);
begin
  InputBox.SelStart := Length(InputBox.Lines.Text);
end;

// TRAY
procedure TGG.Ic(n: Integer; Icon: TIcon);
var Nim: TNotifyIconData;
  tip : array[0..63] of Char;
begin
  with Nim do
  begin
    cbSize := SizeOf(Nim);
    Wnd := Self.Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    hicon := Icon.Handle;
    uCallbackMessage := WM_USER + 1;
    lstrcpyn(szTip, PChar(GG.Caption), SizeOf(szTip));
  end;
  case n of
    1: Shell_NotifyIcon(Nim_Add, @Nim);
    2: Shell_NotifyIcon(Nim_Delete, @Nim);
    3: Shell_NotifyIcon(Nim_Modify, @Nim);
  end;
end;

procedure TGG.ControlWindow(var Msg: TMessage);
begin
  if Msg.WParam = SC_MINIMIZE then
  begin
    Ic(1, Application.Icon);
    ShowWindow(Handle, SW_HIDE);
    ShowWindow(Application.Handle, SW_HIDE);   
  end
  else
    inherited;
end;

procedure TGG.IconMouse(var Msg: TMessage);
var p: TPoint;
begin
  GetCursorPos(p);
  case Msg.LParam of
    WM_LBUTTONUP, WM_LBUTTONDBLCLK:
      begin
        Ic(2, Application.Icon);
        ShowWindow(Application.Handle, SW_SHOW);
        ShowWindow(Handle, SW_SHOW);
      end;
    WM_RBUTTONUP:
      begin
        SetForegroundWindow(Handle);
        PostMessage(Handle, WM_NULL, 0, 0);
      end;
  end;
end;

function MemoryStreamToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

procedure TGG.IdHTTPServer1CommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Node: TStringList;
  i:Integer;
  Stream: TMemoryStream;
  Document, Path, Id: String;
begin
  Document := Copy(ARequestInfo.Document, 2, MaxInt);
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *'); //Разрешение на выполнения запросов
  if ARequestInfo.Command = 'GET' then
  begin
    Base.Module := nil;
    Base.Prev := nil;
    AResponseInfo.ContentText := Base.GetNodeBody(Base.Exec(Document));
    //QueryBox.Lines.Add(ARequestInfo.Command + #10 + AResponseInfo.ContentText);
  end;
  if ARequestInfo.Command = 'POST' then
  begin
    try
      Stream := TMemoryStream.Create;
      Stream.LoadFromStream(ARequestInfo.PostStream);
      Node := TStringList.Create;
      Node.Text := MemoryStreamToString(Stream);

      with Base do
      begin
        Module := nil;
        Prev := nil;
        Exec(Document);
        SetLength(Module.Local, 0);
        Module.SaveTime := 0;
        SaveNode(Module);
        Module := nil;
        Prev := nil;
        for i:=0 to Node.Count - 1 do
          Exec(Node.Strings[i]);
        AResponseInfo.ContentText := GetNodeBody(Module) + #10;
      end;

      QueryBox.Lines.Add('ЗАПРОС'#10 + Node.Text);
      QueryBox.Lines.Add('ОТВЕТ'#10 + AResponseInfo.ContentText);

    finally
      Node.Free;
      Stream.Free;
    end;
  end;
end;

procedure TGG.IdHTTPServer1CreatePostStream(ASender: TIdPeerThread;
  var VPostStream: TStream);
begin
  VPostStream := TMemoryStream.Create;
end;

procedure TGG.IdHTTPServer1Exception(AThread: TIdPeerThread;
  AException: Exception);
begin
  QueryBox.Lines.Add('Error: ' + StringReplace(AException.Message, #13#10, #32, [rfReplaceAll]));
end;

end.

