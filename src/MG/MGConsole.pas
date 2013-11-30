unit MGConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, MetaGenerator;

type
  TMGConcole = class(TForm)
    InputBox: TRichEdit;
    ModuleBox: TRichEdit;
    Splitter: TSplitter;
    procedure FormShow(Sender: TObject);
    procedure InputBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Send(Line: String; WriteToConsole: Boolean = True);
  end;

var
  MGConcole: TMGConcole;

implementation

{$R *.dfm}

uses MetaBase;

procedure TMGConcole.Send(Line: String; WriteToConsole: Boolean = True);
var Node: PNode;
begin
  Node := Gen.Get(Line);
  if WriteToConsole = True then
    InputBox.Lines.Add(Line);
//  ModuleBox.Lines.Text := Gen.GetNodeText(Node);
end;

procedure TMGConcole.FormShow(Sender: TObject);
var i: Integer;
begin
  InputBox.SelStart := Length(InputBox.Lines.Text);
  for i:=0 to InputBox.Lines.Count - 1 do
    Send(InputBox.Lines[i], False);
end;

procedure TMGConcole.InputBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    Send(InputBox.Lines[InputBox.Lines.Count-1]);
end;

end.
