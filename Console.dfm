object GG: TGG
  Left = 192
  Top = 114
  Width = 454
  Height = 334
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 241
    Top = 0
    Height = 300
  end
  object Console: TRichEdit
    Left = 0
    Top = 0
    Width = 241
    Height = 300
    Align = alLeft
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    TabOrder = 0
  end
  object InputData: TRichEdit
    Left = 244
    Top = 0
    Width = 202
    Height = 300
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Lines.Strings = (
      'Hello'
      'world')
    TabOrder = 1
  end
end
