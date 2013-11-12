unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Timer1: TTimer;
    Edit8: TEdit;
    Button2: TButton;
    Edit9: TEdit;
    Edit10: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
procedure Shows();
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  step, max, min, count, now, into, from, into_cyr: Extended;
  id: Integer;
implementation

{$R *.dfm}



procedure TForm1.Shows();
begin
inc(id);
  Edit10.Text := FloatToStr((max-now)/(max-min));
  Edit9.Text := FloatToStr(into_cyr);
  Edit8.Text := IntToStr(id);
  Edit7.Text := FloatToStr(step);
  Edit6.Text := FloatToStr(count);
  Edit5.Text := FloatToStr(into);
  Edit4.Text := FloatToStr(from);
  Edit3.Text := FloatToStr(max);
  Edit2.Text := FloatToStr(min);
  Edit1.Text := FloatToStr(now);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
{    now := (step/count) * (IfThen(into = 0, 1, into/from) + (max-now)/(max-min) ); }
  step := StrToFloat(Edit7.Text);
  count:= StrToFloatDef(Edit6.Text, 0);
  into := StrToFloatDef(Edit5.Text, 0);
  from := StrToFloatDef(Edit4.Text, 0);
  max  := StrToFloatDef(Edit3.Text, 0);
  min  := StrToFloatDef(Edit2.Text, 0);
  now  := StrToFloatDef(Edit1.Text, 0);   
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;

  step := 10;
  max  := 20;
  min  := -10;
  count:= 0;
  now  := 10;
  into := 0;
  from := 50000;
end;





procedure TForm1.Button1Click(Sender: TObject);
begin

  count := Random(2) + 1;//count + 1;
  into := Random(Round(from-1)) + 1;
  if Random(3)= 0 then
    into := 0;

  into_cyr := (step/count) * (0 + (max-now)/(max-min) );

  now := now + into_cyr;

  Shows;
end;



end.
