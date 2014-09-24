program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

var
  Link : TLink;

begin
  link := TLink.BaseParse('@123');
//  SHowMessage(Link.name);
  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
