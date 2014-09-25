program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

begin
  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
