program NodeGenerator;

uses
  Forms, Console, Generator,
  Kernel in '..\NodeBase\Kernel.pas',
  Link in '..\NodeBase\Link.pas',
  Utils in '..\NodeBase\Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
