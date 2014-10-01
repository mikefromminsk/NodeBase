unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Kernel, Generator, Utils;

type
  TGG = class(TForm)
    SeqBox: TListBox;
    Timer: TTimer;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ShowNode(Node: PNode);
    procedure TimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  end;

var
  GG: TGG;
  Generator: TGenerator;

implementation

{$R *.dfm}

{uses psAPI;


function GetUsedMemory: LONGINT;
var
  pmc: PPROCESS_MEMORY_COUNTERS;
  cb: Integer;
begin
  cb := SizeOf(_PROCESS_MEMORY_COUNTERS);
  GetMem(pmc, cb);
  pmc^.cb := cb;
  if GetProcessMemoryInfo(GetCurrentProcess(), pmc, cb) then
    result:=pmc^.WorkingSetSize
  else
    result:=0;
  FreeMem(pmc);
end;       }

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
   Status: THeapStatus;
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

 procedure AddFmt(const Fmt: string; Args: array of const);
  begin
    SeqBox.Items.Add(Format(Fmt, Args));
  end;
begin
  with Generator do
  begin
    SeqBox.Clear;
  Status := GetHeapStatus;
  AddFmt('TotalAddrSpace = %d', [Status.TotalAddrSpace]);
  AddFmt('TotalUncommitted = %d', [Status.TotalUncommitted]);
  AddFmt('TotalCommitted = %d', [Status.TotalCommitted]);
  AddFmt('TotalAllocated = %d', [Status.TotalAllocated]);
  AddFmt('TotalFree =%d', [Status.TotalFree]);
  AddFmt('FreeSmall =%d', [Status.FreeSmall]);
  AddFmt('FreeBig = %d', [Status.FreeBig]);
  AddFmt('Unused = %d', [Status.Unused]);
  AddFmt('Overhead = %d', [Status.Overhead]);
  AddFmt('HeapErrorCode = %d', [Status.HeapErrorCode]);
    SeqBox.Items.Add('uses');
    for i:=0 to High(Module.Local) do
    begin
      Str := GetIndex(Module.Local[i]) + ShowParams(Module.Local[i]);
      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
    end;
    Res := '';
    if Node.Value <> nil then
    begin
      if GetValue(Node).Attr = naData then
        Res := ': Result = ' + EncodeStr(GetValue(Node).Data)
      else
        Res := ': Result = ' + GetIndex(GetValue(Node));
    end;

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

procedure TGG.Button1Click(Sender: TObject);
begin
  if Timer.Enabled = True then
  begin
    Timer.Enabled := False;
  end
  else
  begin
    Timer.Enabled := True;
    Generator.Clear;
    Generator.Module := Generator.NewNode(Generator.NextID);
    Generator.Execute('/dll/math.node$activate');
  end;
end;

end.
