program Generator;

uses
  Forms,
  Console,
  Generator,
  Kernel in '..\NodeBase\Kernel.pas',
  Utils in '..\NodeBase\Utils.pas',
  Link in '..\NodeBase\Link.pas';

{$R *.res}

begin
  Application.Initialize;
  GFocus := TGFocus.Create;
  GFocus.Execute('/../dll/math.node$activate');
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
