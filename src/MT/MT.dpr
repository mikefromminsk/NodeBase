program MT;

uses
  Forms,
  MTConsole in 'MTConsole.pas' {GG};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
