unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Kernel, Generator;

type
  TGG = class(TForm)
    SeqBox: TListBox;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure ShowNode(Node: PNode);
    procedure TimerTimer(Sender: TObject);
  end;

var
  GG: TGG;
  Generator: TGenerator;

implementation

{$R *.dfm}

procedure TGG.FormCreate(Sender: TObject);
begin
  Generator := TGenerator.Create;
  Generator.Execute('/dll/math.node$activate');
  
  ShowNode(Generator.Generate);
end;


procedure TGG.ShowNode(Node: PNode);
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
      Str := Str + Generator.GetIndex(Node.Params[i]) + ', ';
    Delete(Str, Length(Str) - 1, 2);
    Str := Str + ')';
    Result := Str;
  end;
begin
  with Generator do
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
      Body := Generator.GetNodeBody(Node);
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
  ShowNode(Generator.Generate);
end;

end.
