unit KernelConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ScktComp, AppEvnts, ShellApi,
  IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdTCPConnection, IdTCPClient, IdHTTP, Menus,
  Kernel, Utils, Link, IdHTTPHeaderInfo;

type
  TKernelConsole = class(TForm)
    OutputBox: TRichEdit;
    Splitter: TSplitter;
    Timer1: TTimer;
    QueryBox: TRichEdit;
    Splitter1: TSplitter;
    InputBox: TRichEdit;
    IdHTTPServer1: TIdHTTPServer;
    RightClickToIcon: TPopupMenu;
    Exit: TMenuItem;
    Console: TMenuItem;
    procedure InputBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InputBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormShow(Sender: TObject);
    function ConsoleExec(Line: String; WriteToConsole: Boolean = False): TNode;
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure IdHTTPServer1CreatePostStream(ASender: TIdPeerThread;
      var VPostStream: TStream);
    procedure IdHTTPServer1Exception(AThread: TIdPeerThread;
      AException: Exception);
    procedure FormDestroy(Sender: TObject);
    procedure ExitClick(Sender: TObject);
    procedure ConsoleClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure ControlWindow(var Msg: TMessage); message WM_SYSCOMMAND;
    procedure IconMouse(var Msg: TMessage); message WM_USER + 1;
    procedure IconMode(n: Integer; Icon: TIcon);
  end;

var
  KernelConsoleForm: TKernelConsole;
  Kernel: TKernel;

implementation

{$R *.dfm}

procedure TKernelConsole.FormCreate(Sender: TObject);
var
  i: Integer;
  Node: TNode;
begin
  Kernel := TKernel.Create;

  for i:=0 to InputBox.Lines.Count - 1 do
    ConsoleExec(InputBox.Lines[i]);


end;

function TKernelConsole.ConsoleExec(Line: String; WriteToConsole: Boolean = False): TNode;
var
  Value: TNode;
  Str: String;
begin
  Result := Kernel.UserNode(Line);
  if Result <> nil then
  begin
    Value := Kernel.GetValue(Result);
    if Value <> nil then
    begin
      Str := Value.Data;
      if Length(Str) = 8 then
        Str := FloatToStr(StrToFloat8(Str))
      else
        Str := EncodeStr(Str);
    end;
  end;
  if Str = '' then
    Str := 'NULL';
  OutputBox.Lines.Text := Str;
  if WriteToConsole then
    InputBox.Lines.Add(Line);
end;

function HttpResponse(Line: String): String;
begin
  Result := 'HTTP/1.1 200 OK'#10#10 + Line;
  KernelConsoleForm.QueryBox.Text := KernelConsoleForm.QueryBox.Text + Result;
  KernelConsoleForm.QueryBox.Lines.Add('************************'#10);
end;

procedure TKernelConsole.InputBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F9 then Close;
  if Key = VK_ESCAPE then PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TKernelConsole.InputBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    ConsoleExec(InputBox.Lines[InputBox.Lines.Count-1]);
end;

//Style Form mini
procedure TKernelConsole.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do Style := (Style or WS_POPUP) and not WS_DLGFRAME;
end;

procedure TKernelConsole.FormShow(Sender: TObject);
begin
  if not FileExists(RootFileName) then
    QueryBox.Lines.Add('Not exist root file (' + RootFileName + ')');
  try
    IdHTTPServer1.DefaultPort := StrToIntDef(Kernel.Root.Attr[naServerPort], 80);
    IdHTTPServer1.Active := True;
    QueryBox.Lines.Add('DefaultPort: ' + IntToStr(IdHTTPServer1.DefaultPort));
  except
    on E: Exception do
      QueryBox.Lines.Add('Error: Port ' + IntToStr(IdHTTPServer1.DefaultPort) +
        ' already open. Change ServerPort in ' + RootFileName +' file.');
  end;

  InputBox.SelStart := Length(InputBox.Lines.Text);
end;

// TRAY
procedure TKernelConsole.IconMode(n: Integer; Icon: TIcon);
var Nim: TNotifyIconData;
//  tip : array[0..63] of Char;
begin
  with Nim do
  begin
    cbSize := SizeOf(Nim);
    Wnd := Self.Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    hicon := Icon.Handle;
    uCallbackMessage := WM_USER + 1;
    lstrcpyn(szTip, PChar(Caption), SizeOf(szTip));
  end;
  case n of
    1: Shell_NotifyIcon(Nim_Add, @Nim);
    2: Shell_NotifyIcon(Nim_Delete, @Nim);
    3: Shell_NotifyIcon(Nim_Modify, @Nim);
  end;
end;

procedure TKernelConsole.ControlWindow(var Msg: TMessage);
begin
  if Msg.WParam = SC_MINIMIZE then
  begin
    ShowWindow(Handle, SW_HIDE);
    ShowWindow(Application.Handle, SW_HIDE);
    IconMode(1, Application.Icon);
  end
  else
    inherited;
end;

procedure TKernelConsole.IconMouse(var Msg: TMessage);
var p: TPoint;
begin
  GetCursorPos(p);
  case Msg.LParam of
    WM_LBUTTONUP, WM_LBUTTONDBLCLK:
      begin
        ShowWindow(Handle, SW_SHOW);
        ShowWindow(Application.Handle, SW_SHOW);
      end;
    WM_RBUTTONUP:
      begin
        RightClickToIcon.Popup(p.X, p.Y);
        {SetForegroundWindow(Handle);
        PostMessage(Handle, WM_NULL, 0, 0);}
      end;
  end;
end;

function MemoryStreamToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

procedure TKernelConsole.IdHTTPServer1CommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Node: TStringList;
  i:Integer;
  Stream: TMemoryStream;
  Document: String;
begin
  Document := Copy(ARequestInfo.Document, 2, MaxInt);
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *'); //Разрешение на выполнения запросов


  if ARequestInfo.Command = 'GET' then
  begin
    if Document = '' then   // return html console
      AResponseInfo.ContentStream := TFileStream.Create(ConsoleFileName, fmOpenRead or fmShareCompat)  // to local dir
    else
      AResponseInfo.ContentText := Kernel.GetNodeBody(Kernel.NewNode(Document));
  end;
  if ARequestInfo.Command = 'POST' then
  begin
    try
      Stream := TMemoryStream.Create;
      Stream.LoadFromStream(ARequestInfo.PostStream);
      Node := TStringList.Create;
      Node.Text := MemoryStreamToString(Stream);

      with Kernel do
      begin
        FUnit := nil;
        Prev := nil;
        UserNode(Document);
        SetLength(FUnit.Local, 0);
        FUnit := nil;
        Prev := nil;
        for i:=0 to Node.Count - 1 do
          UserNode(Node.Strings[i]);
        AResponseInfo.ContentText := GetNodeBody(FUnit) + #10;
      end;

      QueryBox.Lines.Add('ЗАПРОС'#10 + Node.Text);
      QueryBox.Lines.Add('ОТВЕТ'#10 + AResponseInfo.ContentText);

    finally
      Node.Free;
      Stream.Free;
    end;
  end;
end;

procedure TKernelConsole.IdHTTPServer1CreatePostStream(ASender: TIdPeerThread;
  var VPostStream: TStream);
begin
  VPostStream := TMemoryStream.Create;
end;

procedure TKernelConsole.IdHTTPServer1Exception(AThread: TIdPeerThread;
  AException: Exception);
begin
  QueryBox.Lines.Add('Error: ' + StringReplace(AException.Message, #13#10, #32, [rfReplaceAll]));
end;

procedure TKernelConsole.FormDestroy(Sender: TObject);
begin
  IconMode(2, Application.Icon);
end;

procedure TKernelConsole.ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TKernelConsole.ConsoleClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar('http://localhost:' + IntToStr(IdHTTPServer1.DefaultPort)), nil, nil, SW_SHOW);
end;

procedure TKernelConsole.Timer1Timer(Sender: TObject);
var
  Count: Integer;
  Node: Tnode;
  i: Integer;
begin
  {with Kernel do
  begin
    //SaveUnit(FUnit);

    Node := NewNode(NextID);

    for i:=0 to 10000 do
      SetLocal(Node, NewNode(NextID));

    FreeUnit(Node);
  end; }

//  ShowMessage(Node.Name);

{  Kernel.Clear;
  Kernel.FUnit := Kernel.NewNode('@1');
  Node := ConsoleExec('func$activate?750,0', True);
  if Node <> nil then
    Node := nil;   }
end;

end.

