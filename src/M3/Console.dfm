object GG: TGG
  Left = 219
  Top = 115
  Width = 397
  Height = 510
  BorderIcons = [biSystemMenu]
  Color = clGrayText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 410
    Width = 381
    Height = 4
    Cursor = crHandPoint
    Align = alBottom
    Color = cl3DDkShadow
    MinSize = 1
    ParentColor = False
    ResizeStyle = rsLine
  end
  object InputBox: TRichEdit
    Left = 0
    Top = 0
    Width = 381
    Height = 410
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    Lines.Strings = (
      '/../dll/math.dll.meta$R1'
      ''
      'func?a:float#res'
      'res=0,0'
      'i=1,0'
      'dx=1,0'
      'while'
      'fje?i&a#exit|'
      'i=finc?i'
      'res=fadd?res&dx'
      'dx=fdiv?1,0&fsqr?i'
      'jmp#lab|'
      'while^lab'
      'here^exit'
      'res=fsqrt?fmul?res&6,0'
      '')
    ParentColor = True
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
    OnKeyDown = InputBoxKeyDown
    OnKeyUp = InputBoxKeyUp
  end
  object OutputBox: TRichEdit
    Left = 0
    Top = 414
    Width = 381
    Height = 58
    Align = alBottom
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentColor = True
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
    WordWrap = False
    OnKeyPress = OutputBoxKeyPress
  end
  object Server: TServerSocket
    Active = False
    Port = 80
    ServerType = stNonBlocking
    OnClientRead = ServerClientRead
    OnClientError = ServerClientError
    Left = 352
    Top = 8
  end
  object Timer1: TTimer
    Left = 312
    Top = 8
  end
end
