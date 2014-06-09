unit GModule;

interface

uses
  MetaBaseModule, Dialogs;

type
  TG = class (TFocus)
  public
    function Exec(Line: String): PNode; override;
    //procedure CreateVariables(Node: PNode);
  end;

implementation


function TG.Exec(Line: String): PNode;
begin
  Result := inherited Exec(Line);
  //if Result.Generator
  ShowMessage(GetNodeBody(Result));
end;

end.