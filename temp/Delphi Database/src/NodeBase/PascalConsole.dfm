object PascalConsole: TPascalConsole
  Left = 196
  Top = 89
  Width = 318
  Height = 740
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object GenerateBox: TListBox
    Left = 0
    Top = 0
    Width = 310
    Height = 706
    Style = lbOwnerDrawFixed
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 17
    ParentFont = False
    TabOrder = 0
    OnDrawItem = GenerateBoxDrawItem
  end
end
