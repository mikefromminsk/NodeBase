unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GModule, MetaBaseModule;

type
  TGG = class(TForm)
    ListBox: TListBox;
    Address: TMemo;
    procedure FormShow(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
  public
    procedure ShowNode(Node: PNode);
  end;

var
  GG: TGG;
  Base: TGFocus;

implementation

{$R *.dfm}

procedure TGG.FormShow(Sender: TObject);
var
  FuncNode: PNode;
begin
  Base := TGFocus.Create;
  with Base do
  begin
    Execute('/../dll/math.meta$activate');
    FuncNode := NewNode(NextID);
    CreateFunc(FuncNode);
    ShowNode(FuncNode);
  end;
end;

procedure TGG.ShowNode(Node: PNode);
var
  Body: String;
  i: Integer;
begin
  if Node = nil then Exit;
  Body := Base.GetNodeBody(Node);
  with ListBox, Base do
  begin
    Body :=StringReplace(Body, #10, ' ', []);
    Items.Delimiter := 'ß';
    Items.DelimitedText := StringReplace(Body, #10#10, 'ß', []);
    Address.Text := Items[0];
    Items[0] := '..';
    for i:=1 to Items.Count - 1 do
    begin
      Body := Base.GetNodeBody(Base.NewNode(Items[i]));
      if Pos(#10, Body) <> 0
      then Items[i] := Copy(Body, 1, Pos(#10, Body))
      else Items[i] := Body;
    end;
  end;
end;

procedure TGG.ListBoxDblClick(Sender: TObject);
begin
  if ListBox.ItemIndex <> 0
  then ShowNode(Base.NewNode(ListBox.Items[ListBox.ItemIndex]))
  else ShowNode(Base.NewNode(Address.Text).ParentLocal);
end;

end.
