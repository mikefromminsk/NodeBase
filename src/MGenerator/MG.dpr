program MG;

uses
  Forms,
  MGConsole in 'MGConsole.pas' {MGen};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMGen, MGen);
  Application.Run;
end.
