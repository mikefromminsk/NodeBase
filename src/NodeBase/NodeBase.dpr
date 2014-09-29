program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, Kernel;

{$R *.res}

begin
  Application.Initialize;
  Base := TKernel.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
