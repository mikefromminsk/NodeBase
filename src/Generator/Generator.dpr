program Generator;

uses
  Forms,
  Console,  //SimpleTutor
  NodeBaseKernel in '..\NodeBase\NodeBaseKernel.pas',
  NodeUtils in '..\NodeBase\NodeUtils.pas',
  NodeLink in '..\NodeBase\NodeLink.pas',
  GeneratorModule;

{$R *.res}

begin
  Application.Initialize;
  GFocus := TGFocus.Create;
  GFocus.Execute('/../dll/math.node$activate');
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
