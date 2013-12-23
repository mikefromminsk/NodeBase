unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    RichEdit1: TRichEdit;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
var
  i: Integer;
  Selected: Char;
begin
  for i:=0 to Length(RichEdit1.Lines.Text)-1 do begin
    RichEdit1.SelStart:=i;
    RichEdit1.SelLength:=1;
    if Length(RichEdit1.SelText)<>1 then
      Continue;
    Selected:=RichEdit1.SelText[1];
    case ord(Selected) of
      192..255{рус}: RichEdit1.SelAttributes.Color:=clRed;
      else
        RichEdit1.SelAttributes.Color:=clBlack;
    end; // case
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
  Selected: Char;
begin
  for i:=0 to Length(RichEdit1.Lines.Text)-1 do begin
    RichEdit1.SelStart:=i;
    RichEdit1.SelLength:=1;
    if Length(RichEdit1.SelText)<>1 then
      Continue;
    Selected:=RichEdit1.SelText[1];
    case ord(Selected) of
      65..90{ENG}, 97..122{eng}: RichEdit1.SelAttributes.Color:=clRed;
      else
        RichEdit1.SelAttributes.Color:=clBlack;
    end; // case
  end;
end;

end.
