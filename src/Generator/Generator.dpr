program Generator;

uses
  Forms,
  Console,
  NodeBaseKernel in '..\NodeBase\NodeBaseKernel.pas',
  NodeUtils in '..\NodeBase\NodeUtils.pas',
  NodeLink in '..\NodeBase\NodeLink.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
