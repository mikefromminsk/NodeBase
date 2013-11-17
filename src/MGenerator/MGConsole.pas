unit MGConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Console, StdCtrls, ComCtrls, ExtCtrls;

type
  TMGen = class(TGG)
    RichEdit1: TRichEdit;
    Splitter1: TSplitter;
  end;

var
  MGen: TMGen;

implementation

{$R *.dfm}

end.
