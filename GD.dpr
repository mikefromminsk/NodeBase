program GD;

uses
  Forms,
  Console in 'Console.pas' {GG};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
