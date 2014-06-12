unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GModule;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
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
  MG.Execute('@2');
end;

end.
