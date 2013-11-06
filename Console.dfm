object GG: TGG
  Left = 219
  Top = 115
  Width = 397
  Height = 510
  BorderIcons = [biSystemMenu]
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 414
    Width = 389
    Height = 4
    Cursor = crHandPoint
    Align = alBottom
    Color = cl3DDkShadow
    ParentColor = False
    ResizeStyle = rsLine
  end
  object InputBox: TRichEdit
    Left = 0
    Top = 0
    Width = 389
    Height = 414
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clGrayText
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    Lines.Strings = (
      '/sys/types.meta'
      ''
      '/sys/math.dll'
      ''
      '/sys/math.dll.meta'
      ''
      'add?1&2')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
    OnKeyDown = InputBoxKeyDown
    OnKeyUp = InputBoxKeyUp
  end
  object OutputBox: TRichEdit
    Left = 0
    Top = 418
    Width = 389
    Height = 58
    Align = alBottom
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clGrayText
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
    WordWrap = False
  end
  object Server: TServerSocket
    Active = True
    Port = 80
    ServerType = stNonBlocking
    OnClientRead = ServerClientRead
    OnClientError = ServerClientError
    Left = 352
    Top = 8
  end
  object Timer1: TTimer
    Left = 288
    Top = 8
  end
end
