program MG;

uses
  Forms, ConsoleMG, MetaBase;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGC, GC);

  Application.Run;
end.
