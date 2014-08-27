unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, NodeBaseKernel, NodeLink, GeneratorModule;

type
  TGG = class(TForm)
    ListBox: TListBox;
    Address: TMemo;
    SeqBox: TListBox;
    Splitter1: TSplitter;
    Timer: TTimer;
    procedure ListBoxDblClick(Sender: TObject);
    procedure AddressKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    procedure ShowNode(Node: PNode);
    procedure ShowSequence(Node: PNode);
  end;

var
  GG: TGG;
  FocusNode: PNode;

implementation

{$R *.dfm}

procedure TGG.ShowNode(Node: PNode);
var
  Body: String;
  i: Integer;
begin
  if Node = nil then Exit;
  FocusNode := Node;
  Body := GFocus.GetNodeBody(Node);
  with ListBox, GFocus do
  begin
    Body := StringReplace(Body, #10, ' ', []);
    Body := StringReplace(Body, #10#10, #10, [rfReplaceAll]);
    Items.Text := Body;
    Address.Text := Copy(Items[0], Pos('@', Items[0]), Pos('$', Items[0]) - Pos('@', Items[0]));
    Items[0] := '..';
    for i:=1 to Items.Count - 1 do
    begin
      Body := GetNodeBody(NewNode(Items[i]));
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
  //Link: TLink;
  Str: String;
  i: Integer;

  function ShowParams(Node: PNode): String;
  var Str: String;
  i: Integer;
  begin
    if Node.Params = nil then begin Result := ''; Exit; end;
    Str := Str + '(';
    for i:=0 to High(Node.Params) do
      Str := Str + GFocus.GetIndex(Node.Params[i]) + ', ';
    Delete(Str, Length(Str) - 1, 2);
    Str := Str + ')';
    Result := Str;
  end;
begin
  with GFocus do
  begin

    SeqBox.Clear;
    SeqBox.Items.Add('var');
    for i:=0 to High(Node.Local) do
    begin
      Str := GetIndex(Node.Local[i]) + ShowParams(Node.Local[i]);
      Str := '  ' + Str;
      SeqBox.Items.Add(Str);
    end;

    SeqBox.Items.Add('begin');
    Node := Node.Next;
    while Node <> nil do
    begin
      Body := GFocus.GetNodeBody(Node);
      if Pos(#10, Body) <> 0 then
        Delete(Body, Pos(#10, Body), MaxInt);
      //Link := TLink.Create(Body);
      Str := GetIndex(Node);
      if Node.Source <> nil then
        Str := GetIndex(Node.Source);
      if Node.Value <> nil then
      begin
        Str := Str + ' := ' + GetIndex(Node.Value.Source);
        if Node.Value <> nil then
          if Node.Value.Source <> nil then
            Str := Str + ShowParams(Node.Value.Source);
      end;

      if (Node.FTrue <> nil) or (Node.FElse <> nil) then
      begin
        Str := 'if ' + Str;
        if Node.FTrue <> nil then
          Str := Str + ' then ' + GetIndex(Node.FType.Source);
        if Node.FElse <> nil then
          Str := Str + ' else ' + GetIndex(Node.FElse.Source);
      end;

      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
      Node := Node.Next;
    end;
    SeqBox.Items.Add('end;');
  end;
end;

procedure TGG.ListBoxDblClick(Sender: TObject);
begin
  if ListBox.ItemIndex <> 0
  then ShowNode(GFocus.NewNode(ListBox.Items[ListBox.ItemIndex]))
  else ShowNode(GFocus.NewNode(Address.Text).ParentLocal);
end;

procedure TGG.AddressKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    ShowNode(GFocus.NewNode(Address.Text));
end;

procedure TGG.TimerTimer(Sender: TObject);
begin
  ShowNode(GFocus.Generate);
end;

procedure TGG.FormShow(Sender: TObject);
begin
  ShowNode(GFocus.Generate);
end;

end.
