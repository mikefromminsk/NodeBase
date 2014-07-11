object GG: TGG
  Left = 234
  Top = 150
  Width = 928
  Height = 480
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Arial Narrow'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 23
  object Splitter1: TSplitter
    Left = 0
    Top = 153
    Width = 912
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object ListBox: TListBox
    Left = 0
    Top = 33
    Width = 912
    Height = 120
    Align = alTop
    BorderStyle = bsNone
    ItemHeight = 23
    TabOrder = 0
    OnDblClick = ListBoxDblClick
  end
  object Address: TMemo
    Left = 0
    Top = 0
    Width = 912
    Height = 33
    Align = alTop
    BevelInner = bvLowered
    BiDiMode = bdLeftToRight
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial Narrow'
    Font.Style = []
    ParentBiDiMode = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    OnKeyDown = AddressKeyDown
  end
  object SeqBox: TListBox
    Left = 0
    Top = 156
    Width = 912
    Height = 286
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 23
    TabOrder = 2
  end
end
