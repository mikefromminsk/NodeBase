program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, Kernel, Link;

{$R *.res}

begin
  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
