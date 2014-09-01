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
    Splitter: TSplitter;
    Timer: TTimer;
    GarbageCollectorTimer: TTimer;
    Button1: TButton;
    Button2: TButton;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddressChange(Sender: TObject);
    procedure GarbageCollectorTimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  public
    procedure ShowNode(Node: PNode);
    procedure ShowPascalCode(Node: PNode);
  end;

var
  GG: TGG;
  FocusNode: PNode;
  GFocus: TGFocus;
  
implementation

{$R *.dfm}

procedure TGG.ShowNode(Node: PNode);
begin
  if Node = nil then Exit;
  ListBox.Items.Text := GFocus.GetNodeBody(Node);
  Address.OnChange := nil;
  Address.Text := GFocus.GetIndex(Node);
  Address.OnChange := AddressChange;
  ShowPascalCode(Node);
end;

procedure TGG.ShowPascalCode(Node: PNode);
var
  Body: String;
  Str, Res: String;
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
    SeqBox.Items.Add('uses');
    for i:=0 to High(Module.Local) do
    begin
      Str := GetIndex(Module.Local[i]) + ShowParams(Module.Local[i]);
      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
    end;
    Res := '';
    if Node.Value <> nil then
      Res := ': Result = ' + GetIndex(GetValue(Node));
    SeqBox.Items.Add('function ' + GetIndex(Node.ParentName) + GetIndex(Node) + ShowParams(Node) + Res + ';');

    SeqBox.Items.Add('var');
    for i:=0 to High(Node.Local) do
    begin
      Str := GetIndex(Node.Local[i]) + ShowParams(Node.Local[i]);
      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
    end;

    SeqBox.Items.Add('begin');
    Node := Node.Next;
    while Node <> nil do
    begin
      Body := GFocus.GetNodeBody(Node);
      if Pos(#10, Body) <> 0 then
        Delete(Body, Pos(#10, Body), MaxInt);
      Str := GetIndex(Node);
      if Node.Source <> nil then
        Str := GetIndex(GetSource(Node));
      if Node.Value <> nil then
      begin
        Str := Str + ' := ' + GetIndex(GetSource(Node.Value));
        if Node.Value <> nil then
          if Node.Value.Source <> nil then
            Str := Str + ShowParams(GetSource(Node.Value));
      end;

      if (Node.FTrue <> nil) or (Node.FElse <> nil) then
      begin
        Str := 'if ' + Str;
        if Node.FTrue <> nil then
          Str := Str + ' then ' + GetIndex(GetSource(Node.FType));
        if Node.FElse <> nil then
          Str := Str + ' else ' + GetIndex(GetSource(Node.FElse));
      end;

      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
      Node := Node.Next;
    end;
    SeqBox.Items.Add('end;');
  end;
end;

procedure TGG.TimerTimer(Sender: TObject);
begin
  ShowNode(GFocus.Generate);
end;

procedure TGG.FormShow(Sender: TObject);
begin
  ShowNode(GFocus.Generate);
end;

procedure TGG.AddressChange(Sender: TObject);
begin
  ShowNode(GFocus.NewNode(Address.Text));
end;

procedure TGG.GarbageCollectorTimerTimer(Sender: TObject);
var count: Integer;
begin
  Count := GFocus.NodesCount;
  GFocus.GarbageCollector;
  ShowMessage(IntToStr(GFocus.NodesCount - Count));
end;

procedure TGG.Button1Click(Sender: TObject);
begin
  Timer.Enabled := not Timer.Enabled;
end;

procedure TGG.Button2Click(Sender: TObject);
var count: Integer;
begin
  Count := GFocus.NodesCount;
  GFocus.GarbageCollector;
  ShowMessage(IntToStr(GFocus.NodesCount - Count));
end;

end.
