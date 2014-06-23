unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GModule, MetaBaseModule, ExtCtrls;

type
  TGG = class(TForm)
    ListBox: TListBox;
    Address: TMemo;
    SeqBox: TListBox;
    Splitter: TSplitter;
    procedure FormShow(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure AddressKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    procedure ShowNode(Node: PNode);
    procedure ShowSequence(Node: PNode);
  end;

var
  GG: TGG;
  Base: TGFocus;
  FocusNode: PNode;

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
    FuncNode := NewNode(NextID + '#' + NextID);
    CreateFunc(FuncNode, FunctionLevel);
    Run(FuncNode);
    ShowNode(FuncNode);
  end;
end;

procedure TGG.ShowNode(Node: PNode);
var
  Body: String;
  i: Integer;
begin
  if Node = nil then Exit;
  FocusNode := Node;
  Body := Base.GetNodeBody(Node);
  with ListBox, Base do
  begin
    Body := StringReplace(Body, #10, ' ', []);
    Body := StringReplace(Body, #10#10, #10, [rfReplaceAll]);
    Items.Text := Body;
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
  ShowSequence(Node);
end;

procedure TGG.ShowSequence(Node: PNode);
var
  Body: String;
begin
  SeqBox.Clear;
  while Node <> nil do
  begin
    Body := Base.GetNodeBody(Node);
    if Pos(#10, Body) <> 0 then
      Delete(Body, Pos(#10, Body), MaxInt);
    SeqBox.Items.Add(Body);
    Node := Node.Next;
  end;
end;

procedure TGG.ListBoxDblClick(Sender: TObject);
begin
  if ListBox.ItemIndex <> 0
  then ShowNode(Base.NewNode(ListBox.Items[ListBox.ItemIndex]))
  else ShowNode(Base.NewNode(Address.Text).ParentLocal);
end;

procedure TGG.AddressKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    ShowNode(Base.NewNode(Address.Text));
end;

end.
