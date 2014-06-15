unit Manager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MetaBaseModule;

type
  TGG = class(TForm)
    OutList: TListBox;
    procedure FormShow(Sender: TObject);
    procedure ShowNode(Node: PNode);
    procedure OutListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GG: TGG;
  Base: TFocus;

implementation

{$R *.dfm}

procedure TGG.FormShow(Sender: TObject);
begin
  Base := TFocus.Create;
  Base.Execute('@1 @2 @3 @4');
  ShowNode(Base.Module);
end;

procedure TGG.ShowNode(Node: PNode);
var
  List: TStringList;
  Body: String;
begin
  if Node = nil then Exit;

  Body := Base.GetNodeBody(Node);
  with OutList do
  begin
    Items.Clear;
    Items.Delimiter := 'ß';
    Items.DelimitedText := StringReplace(StringReplace(Body, #10#10, 'ß', []), #10, ' ', []);
    GG.Caption := Items[0];
    Items[0] := '..';
  end;
end;

procedure TGG.OutListDblClick(Sender: TObject);
begin
  with OutList do
  begin
    Base.Prev := nil;
    Base.Module := nil;
    if ItemIndex <> 0 then
      ShowNode(Base.Execute(Items[ItemIndex]))
    else
      ShowNode(Base.Execute(GG.Caption).ParentLocal);
  end;
end;

end.
