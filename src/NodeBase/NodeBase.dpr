program NodeBase;

uses
  Forms, PascalConsole, Creator;

{$R *.res}
                 
begin
  Application.Initialize;
  Application.CreateForm(TPascalConsole, PascalConsoleForm);
  Application.Run;
end.
