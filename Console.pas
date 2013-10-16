unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type

  TGG = class(TForm)
    InputBox: TRichEdit;
    OutputBox: TRichEdit;
    Splitter: TSplitter;
    procedure InputBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

var
  GG: TGG;

implementation

uses MetaBase;

{$R *.dfm}

procedure TGG.InputBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_F9) then Close;
end;

end.

