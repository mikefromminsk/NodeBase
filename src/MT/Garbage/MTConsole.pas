unit MTConsole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, XPMan, ComCtrls, XMLIntf, XmlDoc, Menus;

type

  XTree = IXMLDocument;
  XNode = IXMLNode;

  TGG = class(TForm)
    NameBox: TEdit;
    ActionBox: TComboBox;
    LeftBox: TEdit;
    RightBox: TEdit;
    Add: TButton;
    Data: TRichEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Struct: TRichEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  GG: TGG;
  Files: TStringList;
  StructTree: XTree;
  StructNode: XNode;
implementation

{$R *.dfm}


end.
