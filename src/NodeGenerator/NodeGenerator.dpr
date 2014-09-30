program NodeGenerator;

uses
  Forms, Console, Generator,
  Kernel in '..\NodeKernel\Kernel.pas',
  Utils in '..\NodeKernel\Utils.pas',
  Link in '..\NodeKernel\Link.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
