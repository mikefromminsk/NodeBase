unit PascalConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Kernel, Generator, Utils, Link;

type
  TPascalConsole = class(TForm)
    GenerateBox: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ShowNode(Node: TNode; List: TListBox);
    procedure GenerateBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  end;

var
  PascalConsoleForm: TPascalConsole;
  Generator: TGenerator;

implementation

{$R *.dfm}

procedure TPascalConsole.ShowNode(Node: TNode; List: TListBox);
var
  Body: String;
  Str, Res: String;
  i: Integer;

  function GetName(Node: TNode): String;
  begin
    if (Node.Source <> nil) and (Node.Source.ParentName <> nil) then
    begin
      Result := Generator.GetIndex(Node.Source.ParentName);
    end
    else
    begin
      Result := Generator.GetIndex(Node);
      Delete(Result, 1, 1);
      //Result[1] := ' ';
    end;
  end;

  function ShowParams(Node: TNode): String;
  var Str: String;
  i: Integer;
  begin
    if Node.Params = nil then begin Result := ''; Exit; end;
    Str := Str + '(';
    for i:=0 to High(Node.Params) do
      Str := Str + Getname(Node.Params[i]) + ', ';
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
    Add('unit ' + GetName(FUnit) + ';');
    Add('');
    Add('interface');
    Add('');
    Add('uses');
    for i:=0 to High(FUnit.Local) do
    begin
      Str := GetName(FUnit.Local[i]) + ShowParams(FUnit.Local[i]);
      Str := '  ' + Str + ';';
      Add(Str);
    end;
    Res := '';
    if Node.Value <> nil then
    begin
      if GetValue(Node).FType = ntString then
        Res := ': Result = ' + EncodeStr(GetValue(Node).Data)
      else
        Res := ': Result = ' + GetName(GetValue(Node));
    end;
    Add('');
    Add('implementation');
    Add('');
    Add('//...');
    Add('');
    Add('function ' + {GetName(Node.ParentName) +} GetName(Node) + ShowParams(Node) + Res + ';');

    Add('var');
    for i:=0 to High(Node.Local) do
    begin
      Str := GetName(Node.Local[i]) + ShowParams(Node.Local[i]);
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
      Str := GetName(Node);
      if Node.Source <> nil then
        Str := GetName(GetSource(Node));
      if Node.Value <> nil then
      begin
        Str := Str + ' := ' + GetName(GetSource(Node.Value));
        if Node.Value <> nil then
          if Node.Value.Source <> nil then
            Str := Str + ShowParams(GetSource(Node.Value));
      end;

      if (Node.FTrue <> nil) or (Node.FElse <> nil) then
      begin
        Str := 'if ' + Str;
        if Node.FTrue <> nil then
          Str := Str + ' then ' + GetName(GetSource(Node.ValueType));
        if Node.FElse <> nil then
          Str := Str + ' else ' + GetName(GetSource(Node.FElse));
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

procedure TPascalConsole.GenerateBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Line: string;
  i : Integer;
  R : TRect;
  WordPos: Integer;
const
  SysWords: Array[0..9] of String = ('function', 'uses', 'unit', 'interface',
    'implementation', 'begin', 'end', 'var', 'if', 'else');
begin
  R.Left := Rect.Left;
  R.Top := Rect.Top ;
  R.Bottom := Rect.Bottom;
  with Control as TListBox do
  begin
    if odSelected in State then
      Canvas.Brush.Color := clHighlight
    else
      Canvas.Brush.Color := clWindow;
    Canvas.FillRect(Rect);

    Line := Items[Index];
    Canvas.Font.Style := Canvas.Font.Style - [fsBold];
    DrawText(Canvas.Handle, PChar(Line), Length(Line), R, DT_LEFT);

    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
    for i:=0 to High(SysWords) do
    begin
      WordPos := Pos(SysWords[i], Line);
      if WordPos <> 0 then
      begin
        R.Left := Canvas.TextWidth(Copy(Line, 1, WordPos - 1));
        R.Right := R.Left + Canvas.TextWidth(SysWords[i]);
        DrawText(Canvas.Handle, PChar(SysWords[i]), Length(SysWords[i]), R, DT_LEFT);
      end;
    end;
  end;
end;





procedure TPascalConsole.FormCreate(Sender: TObject);
begin
  Generator := TGenerator.Create;

  with Generator do
  begin
    RunNode('/dll/math32.node$activate');
    RunNode('');
    Task := NewNode('je?roundto?x&-2;&3,14');
    RunNode('');
    Root.Attr[naStartID] := '1000';
    FindSolution;
    ShowNode(Generator.Task, GenerateBox);
  end;
end;



end.
