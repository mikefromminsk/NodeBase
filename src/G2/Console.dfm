object GG: TGG
  Left = 192
  Top = 124
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
  object ListBox: TListBox
    Left = 0
    Top = 41
    Width = 912
    Height = 401
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 23
    TabOrder = 0
    OnDblClick = ListBoxDblClick
  end
  object Address: TMemo
    Left = 0
    Top = 0
    Width = 912
    Height = 41
    Align = alTop
    BevelInner = bvLowered
    BiDiMode = bdLeftToRight
    Ctl3D = False
    ParentBiDiMode = False
    ParentCtl3D = False
    TabOrder = 1
  end
end
