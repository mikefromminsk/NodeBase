program MG;

uses
  Forms,
  ConsoleMG in 'ConsoleMG.pas' {GC};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGC, GC);
  Application.Run;
end.
