program M;

uses
  Forms, Console, MetaBase;

{$R *.res}

var i: Integer;

begin

  Application.Initialize;
  Base := TMeta.Create;
  Application.CreateForm(TGG, GG);


  //GG.InputBox.Clear;
  {for i:=0 to GG.InputBox.Lines.Count - 1 do
    GG.M(GG.InputBox.Lines[i], False); }

  Application.Run;
end.
