unit MetaGenerator;

interface

uses MetaBase, Dialogs;

type
  TGenerator = class(TMeta)
    function Get(Line: String): PNode; //override;
  end;

var
  Generator: TGenerator;

implementation



function TGenerator.Get(Line: String): PNode;
begin
  inherited Get(Line);
  ShowMessage(Line);
end;


end.
