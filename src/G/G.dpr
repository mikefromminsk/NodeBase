program G;

uses
  Forms,
  Console in 'Console.pas' {GG},
  MetaBaseModule in '..\M\MetaBaseModule.pas',
  MetaUtils in '..\M\MetaUtils.pas',
  MetaLine in '..\M\MetaLine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
