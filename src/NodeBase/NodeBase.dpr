program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

var 
  Link: TLink;
begin
  Link := TLink.BaseParse('NameIDSource$Vars1:Type?Param1:type1=1&Param1:type#Value>True|FElse'#10'Next'#10#10'Local');

  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
