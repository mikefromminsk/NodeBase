program MG;

uses
  Forms, MGConsole, MetaGenerator;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMGConcole, MGConcole);
  Application.Run;
end.
