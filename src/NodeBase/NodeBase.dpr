program NodeBase;

uses
  Console, Forms, Dialogs, SysUtils, NodeBaseKernel, NodeLink;

{$R *.res}

var i: Integer;

  Link: TLink;
  Str: String;
begin

  Str := 'Source^Name@Id$controls:Ftype?Params#Value|FElse'#10'Next'#10#10'Local1'#10#10'Local2'#10#10'Local3';
  Link := TLink.Create(Str, False);
  Link.ID := '123';
  Application.Initialize;
  Base := TFocus.Create;
  Application.CreateForm(TGG, GG);

  {for i:=0 to 1000 do
    Base.NewNode(Base.NextID);}
  try
    Application.Run;
  except
    on E: Exception do
      //ShowMessage(e.Message);
  end;
end.
