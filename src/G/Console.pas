unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GModule, StdCtrls;

type
  TForm1 = class(TForm)
    List: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MG: TG;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  MG := TG.Create;
  //MG.Execute('@2');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  RandomVariable := System.Random(1000);
end;

end.
