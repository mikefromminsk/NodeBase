program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

var i: Integer;
  Link: TLink;
begin
  Link := TLink.RecParse('NameIDNamesValues?Params#Value>True|FElse'#10'Next'#10#10'Local');

  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
