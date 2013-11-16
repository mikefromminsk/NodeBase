unit ConsoleMG;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, COnsole, ExtCtrls;

type
  TGC = class(TGG)
    GBox: TPanel;
    GSplitter: TSplitter;
  end;

var
  GC: TGC;

implementation

{$R *.dfm}

end.
