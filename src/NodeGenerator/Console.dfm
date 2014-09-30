object GG: TGG
  Left = 234
  Top = 150
  Width = 414
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
  object SeqBox: TListBox
    Left = 0
    Top = 0
    Width = 406
    Height = 611
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 17
    TabOrder = 0
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 8
    Top = 8
  end
end
