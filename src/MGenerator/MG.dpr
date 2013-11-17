program MG;

uses
  Forms, MGConsole, MetaGenerator;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMGen, MGen);
  Generator := TGenerator.Create;
  Generator.Get('!1');
  Application.Run;
end.
