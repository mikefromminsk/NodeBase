program NodeBrain;

uses
  Forms, GeneratorConsole, Generator;

{$R *.res}
                 
begin
  Application.Initialize;
  Application.CreateForm(TGeneratorConsole, GeneratorConsoleForm);
  Application.Run;
end.
