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
    Left = 293
    Top = 0
    Height = 611
    Align = alRight
  end
  object SeqBox: TListBox
    Left = 0
    Top = 0
    Width = 293
    Height = 611
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 17
    TabOrder = 0
  end
  object TaskBox: TListBox
    Left = 296
    Top = 0
    Width = 299
    Height = 611
    Align = alRight
    BorderStyle = bsNone
    ItemHeight = 17
    TabOrder = 1
  end
end
