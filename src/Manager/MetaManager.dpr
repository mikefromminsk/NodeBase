program MetaManager;

uses
  Forms,
  Manager in 'Manager.pas' {GG},
  MetaBaseModule in '..\M\MetaBaseModule.pas',
  MetaLine in '..\M\MetaLine.pas',
  MetaUtils in '..\M\MetaUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGG, GG);
  Application.Run;
end.
