program M;

uses
  Forms,
  Console in 'Console.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
