object GG: TGG
  Left = 234
  Top = 150
  Width = 533
  Height = 816
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Splitter: TSplitter
    Left = 0
    Top = 34
    Width = 525
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object ListBox: TListBox
    Left = 0
    Top = 33
    Width = 525
    Height = 1
    Align = alTop
    BorderStyle = bsNone
    ItemHeight = 17
    TabOrder = 0
  end
  object Address: TMemo
    Left = 0
    Top = 0
    Width = 525
    Height = 33
    Align = alTop
    BevelInner = bvNone
    BiDiMode = bdLeftToRight
    Ctl3D = False
    ParentBiDiMode = False
    ParentCtl3D = False
    TabOrder = 1
    OnChange = AddressChange
  end
  object SeqBox: TListBox
    Left = 0
    Top = 37
    Width = 525
    Height = 745
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 17
    TabOrder = 2
  end
  object Timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerTimer
    Left = 8
    Top = 40
  end
end
