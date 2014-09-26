program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, Kernel;

{$R *.res}

begin
  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
