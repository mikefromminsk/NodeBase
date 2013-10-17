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
    procedure FormCreate(Sender: TObject);
  end;

var
  GG: TGG;

implementation

uses MetaBase, MetaUtils;

{$R *.dfm}

function M(Line: String; WriteToConsole: Boolean = True): String;
var
  Node, Data: PNode;
begin
  Node := Base.Get(Line);
  if Node <> nil then
  begin
    Data := Base.GetData(Node);
    if Data <> nil then
      Result := Data.Name;
    if Length(Result) = 4 then
      Result := IntToStr(StrToInt4(Result))
    else if Length(Result) = 8 then
      Result := FloatToStr(StrToFloat8(Result))
    else Result := EncodeName(Result);
  end;
  if Result = '' then
    Result := 'NULL';
  GG.OutputBox.Lines.Text := Result;
  if WriteToConsole then
    GG.InputBox.Lines.Add(Line);
end;

procedure TGG.InputBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_F9) then Close;
end;

procedure TGG.FormCreate(Sender: TObject);
begin
  M('/types.meta');
  M('');
  M('/Math/math.dll');
  M('');
  M('/Math/math.dll.meta');
  M('');
end;

end.

