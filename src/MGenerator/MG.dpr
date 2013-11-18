program MG;

uses
  Forms, MGConsole, MetaGenerator;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMGen, MGen);
  Application.Run;
end.
