unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ScktComp, AppEvnts, ShellApi;

type
  TGG = class(TForm)
    OutputBox: TRichEdit;
    Splitter: TSplitter;
    Server: TServerSocket;
    Timer1: TTimer;
    QueryBox: TRichEdit;
    Splitter1: TSplitter;
    InputBox: TRichEdit;
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
    procedure ControlWindow(var Msg: TMessage); message WM_SYSCOMMAND;
    procedure IconMouse(var Msg: TMessage); message WM_USER + 1;
    procedure Ic(n: Integer; Icon: TIcon);
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
  Result := 'HTTP/1.1 200 OK'#10#10 + Line;
  GG.QueryBox.Text := GG.QueryBox.Text + Result;
  GG.QueryBox.Lines.Add('************************'#10);
end;

procedure TGG.ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  Query, Head: TStrings;
  Body, Ansver: String;
  i: Integer;
  PrevModule: PNode;
begin
  Query := TStringList.Create;
  Head := TStringList.Create;
  Body := '';

  Query.Text := Socket.ReceiveText;

  Head.Delimiter := ' ';
  Head.DelimitedText := Query.Strings[0];

  QueryBox.Text := QueryBox.Text + Query.Text;
  QueryBox.Lines.Add('************************'#10);

  if Head.Strings[0] = 'POST' then
  begin
    with Base do
    begin
      PrevModule := Base.Module;
      Base.Prev := nil;
      Base.Module := nil;
      for i:=Query.IndexOf('') + 1 to Query.Count - 1 do
      begin
        body := Query.Strings[i];
        Get(Query.Strings[i]);
      end;

      Socket.SendText(HttpResponse(GetNodeBody(Base.Module)));       //GetNodeBody(Module)
      Base.Module := PrevModule;
      Base.Prev := nil;
    end;


  end;
  if Head.Strings[0] = 'GET' then
  begin
    Body := Copy(Head.Strings[1], 2, MaxInt);
    Socket.SendText(HttpResponse(Base.GetNodeBody(Base.Get(Body))));
  end;

  Socket.Close;
  Query.Free;
  Head.Free;
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
  if Key = VK_F9 then Close;
  if Key = VK_ESCAPE then PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
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

// TRAY
procedure TGG.Ic(n: Integer; Icon: TIcon);
var Nim: TNotifyIconData;
begin
  with Nim do
  begin
    cbSize := SizeOf(Nim);
    Wnd := Self.Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    hicon := Icon.Handle;
    uCallbackMessage := WM_USER + 1;
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
    Ic(1, Application.Icon);  // Добавляем значок в трей
    ShowWindow(Handle, SW_HIDE);  // Скрываем программу
    ShowWindow(Application.Handle, SW_HIDE);  // Скрываем кнопку с TaskBar'а
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
        ShowWindow(Application.Handle, SW_SHOW); // Восстанавливаем кнопку программы
        ShowWindow(Handle, SW_SHOW); // Восстанавливаем окно программы
      end;
    WM_RBUTTONUP:
      begin
        SetForegroundWindow(Handle);  // Восстанавливаем программу в качестве переднего окна
        //PopupMenu1.Popup(p.X,p.Y);  // Заставляем всплыть тот самый TPopUp о котором я говорил чуть раньше
        PostMessage(Handle, WM_NULL, 0, 0);
      end;
  end;
end;


end.

