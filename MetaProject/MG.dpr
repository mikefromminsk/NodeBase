program MG;

uses
  Forms, ConsoleMG{, MetaGenerator};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGC, GC);

  Application.Run;
end.
