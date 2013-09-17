unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TGG = class(TForm)
    Console: TRichEdit;
    InputData: TRichEdit;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GG: TGG;

implementation

{$R *.dfm}

procedure Add(Str: String);
begin
  GG.Console.Lines.Add(Str);
end;

procedure TGG.FormCreate(Sender: TObject);
var
  i: Integer;
  nvar, ndata: Integer;
begin
  Randomize;


  ndata := InputData.Lines.Count;
  for i:=0 to ndata - 1 do
    Add('!' + InputData.Lines[i] + #10);

  Add(IntToSTr(InputData.Lines.Count) + #10);
  for i:=0 to ndata - 1 do
    Add(IntToSTr(Length(InputData.Lines[i])) + #10);

  nvar := Random(5);
  for i:=0 to nvar do
    Add('var' + IntToStr(i) + #10);

end;

end.
