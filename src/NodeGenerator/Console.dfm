object GG: TGG
  Left = 234
  Top = 150
  Width = 603
  Height = 645
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
  object Splitter: TSplitter
    Left = 592
    Top = 0
    Height = 611
    Align = alRight
  end
  object GenerateBox: TListBox
    Left = 0
    Top = 0
    Width = 592
    Height = 611
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 17
    TabOrder = 0
  end
end
