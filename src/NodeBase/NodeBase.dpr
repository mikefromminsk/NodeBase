program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

//var i: Integer;

begin
  Application.Initialize;
  Base := TFocus.Create;


  Application.CreateForm(TGG, GG);
  try
    Application.Run;
  except
    on E: Exception do
      ShowMessage(e.Message);
  end;
end.
