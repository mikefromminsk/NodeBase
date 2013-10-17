unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, MBase, MUtils, ScktComp, AppEvnts;

type
  TGG = class(TForm)
    WebForm: TPanel;
    Console: TRichEdit;
    WebSplitter: TSplitter;
    Result: TRichEdit;
    Server: TServerSocket;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure ConsoleKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ServerClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GG: TGG;

implementation

{$R *.dfm}

function M(Line: String; WriteToConsole: Boolean = True): String;
var
  Node, Data: PNode;
begin
  Node := MTree.Get(Line);               
  if Node <> nil then
  begin
    Data := MTree.GetData(Node);
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
  GG.Result.Lines.Text := Result;
  if WriteToConsole then
    GG.Console.Lines.Add(Line);
end;

procedure TGG.FormCreate(Sender: TObject);
begin
  M('/types.meta');
  M('');
  M('/Math/math.dll');
  M('');
  M('/Math/math.dll.meta');
  M('');
  M('func?a:float#res');
  M('res=0,0');
  M('i=1,0');
  M('dx=1,0');
  M('while');
  M('fje?i&a#exit|');
  M('i=finc?i');
  M('res=fadd?res&dx');
  M('dx=fdiv?1,0&fsqr?i');
  M('jmp#lab|');
  M('while^lab');
  M('here^exit');
  M('res=fsqrt?fmul?res&6,0');
  M('');
  //t1 := GetTickCount;
  M('func?750,0');
  //ShowMessage(IntToStr(GetTickCount - t1)); }
end;

procedure TGG.ConsoleKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    M(Console.Lines[Console.Lines.Count-1], False);
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

end.

