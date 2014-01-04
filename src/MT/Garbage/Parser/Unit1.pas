unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, (**)Parser(**);

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Memo2: TMemo;
    Memo3: TMemo;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var S: String;
begin
  S := Memo1.Text;
  S := StringReplace(S, #10, ' ', [rfReplaceAll, rfIgnoreCase]);
  S := StringReplace(S, '  ', ' ', [rfReplaceAll, rfIgnoreCase]);
  Memo1.Text := S;
  Memo3.Text := RunParser(Memo2.Text, Memo1.Text);
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Button1.Click;
    Key := #0;
  end;
end;

end.
