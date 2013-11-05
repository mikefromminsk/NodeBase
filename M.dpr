program M;

uses
  Forms, Console, MetaBase {, MetaLine, Dialogs};

{$R *.res}

var
  i: Integer;
  //Line: TLine;
begin
  {Line := TLine.Create('name$I5');
  ShowMessage(Line.ControlsValues[0]);
  Exit;}

  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Base := TMeta.Create;

  GG.InputBox.Clear;
  for i:=0 to GG.InputBox.Lines.Count - 1 do
    GG.M(GG.InputBox.Lines[i], False);

  GG.M('!123');
  GG.M('');
  GG.M('$I5');

  Application.Run;
end.
