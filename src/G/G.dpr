program G;

uses
  Forms,
  Console in 'Console.pas' {Form1},
  MetaBaseModule in '..\M\MetaBaseModule.pas',
  MetaUtils in '..\M\MetaUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
