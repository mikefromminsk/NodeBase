unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    Button1: TButton;
    Timer1: TTimer;
    http: TIdHTTP;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  uLkJSON;

procedure TForm1.Timer1Timer(Sender: TObject);
var response: String;
begin
  response := http.Get('http://localhost:8080');

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  list: TlkJSONlist;
  item: TlkJSONobject;
  json: TlkJSON;
begin
    list := TlkJSONlist.Create;
    item := TlkJSONobject.Create;
    item.Add('pid', 1024);
    item.Add('name', 'paint');
    item.Add('usage', 10);
    item.Add('memory', 150);
    item.Add('params', 'a=12&b=14');
    list.Add(item);

    item := TlkJSONobject.Create;
    item.Add('pid', 1025);
    item.Add('name', 'word');
    item.Add('usage', 15);
    item.Add('memory', 200);
    item.Add('params', 'b=14');
    list.Add(item);
    json := TlkJSON.Create;
    //ShowMessage(json.GenerateText(list));
end;

end.
