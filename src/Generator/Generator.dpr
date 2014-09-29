program NodeGenerator;

uses
  Forms,
  Console,
  GeneratorModule,
  Kernel in '..\NodeBase\Kernel.pas',
  Utils in '..\NodeBase\Utils.pas',
  Link in '..\NodeBase\Link.pas';

{$R *.res}

begin
  Generator := TGenerator.Create;
  Generator.Execute('/../dll/math.node$activate');

  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
