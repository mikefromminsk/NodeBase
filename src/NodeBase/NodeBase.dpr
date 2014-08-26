program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

var i: Integer;


begin


  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);


  //GG.InputBox.Clear;
  {for i:=0 to GG.InputBox.Lines.Count - 1 do
    GG.M(GG.InputBox.Lines[i], False); }
  try
    Application.Run;
  except
    on E: Exception do
      ShowMessage(e.Message);
  end;
end.
