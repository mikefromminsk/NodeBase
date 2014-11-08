program NodeBrain;

uses
  Forms,
  KernelConsole, Kernel,
  GeneratorConsole, Generator;

{$R *.res}

begin
  Application.Initialize;
  //Application.CreateForm(TKernelConsole, KernelConsoleForm);
  Application.CreateForm(TGeneratorConsole, GeneratorConsoleForm);
  Application.Run;
end.
