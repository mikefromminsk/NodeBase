unit GeneratorConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Kernel, Generator, Utils, Link;

type
  TGeneratorConsole = class(TForm)
    GenerateBox: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ShowNode(Node: TNode; List: TListBox);
  end;

var
  GeneratorConsoleForm: TGeneratorConsole;
  Generator: TGenerator;

implementation

{$R *.dfm}

procedure TGeneratorConsole.FormCreate(Sender: TObject);
var Link: TLink;
begin
  Generator := TGenerator.Create;

  with Generator do
  begin
    UserNode('/dll/math32.node$activate');
    ShowNode(GenerateNode, GenerateBox);
    
    Root.Attr[naStartID] := '1000';
    FindSolution(UserNode('je?roundto?x&-2;&3,14'));
    
  end;
  {ShowNode(Generator.Task, TaskBox); }
end;

procedure TGeneratorConsole.ShowNode(Node: TNode; List: TListBox);
var
  Body: String;
  Str, Res: String;
  i: Integer;

  function ShowParams(Node: TNode): String;
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

  procedure Add(Str: String);
  begin
    List.Items.Add(Str);
  end;

begin
  if (Node = nil) or (List = nil) then Exit;

  with Generator do
  begin
    List.Clear;
    Add('unit ' + GetIndex(FUnit) + ';');
    Add('');
    Add('interface');
    Add('');
    Add('uses');
    for i:=0 to High(FUnit.Local) do
    begin
      Str := GetIndex(FUnit.Local[i]) + ShowParams(FUnit.Local[i]);
      Str := '  ' + Str + ';';
      Add(Str);
    end;
    Res := '';
    if Node.Value <> nil then
    begin
      if GetValue(Node).FType = ntString then
        Res := ': Result = ' + EncodeStr(GetValue(Node).Data)
      else
        Res := ': Result = ' + GetIndex(GetValue(Node));
    end;
    Add('');
    Add('implementation');
    Add('');
    Add('//...');
    Add('');
    Add('function ' + GetIndex(Node.ParentName) + GetIndex(Node) + ShowParams(Node) + Res + ';');

    Add('var');
    for i:=0 to High(Node.Local) do
    begin
      Str := GetIndex(Node.Local[i]) + ShowParams(Node.Local[i]);
      Str := '  ' + Str + ';';
      Add(Str);
    end;

    Add('begin');
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
          Str := Str + ' then ' + GetIndex(GetSource(Node.ValueType));
        if Node.FElse <> nil then
          Str := Str + ' else ' + GetIndex(GetSource(Node.FElse));
      end;

      Str := '  ' + Str + ';';
      Add(Str);
      Node := Node.Next;
    end;
    Add('end;');
    Add('');
    Add('//...');
    Add('');
    Add('end.');
  end;
end;


end.
