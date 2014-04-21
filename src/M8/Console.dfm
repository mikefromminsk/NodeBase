object GG: TGG
  Left = 204
  Top = 115
  Width = 759
  Height = 510
  BorderIcons = [biSystemMenu]
  Caption = 'MetaBase'
  Color = clGrayText
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
    Width = 751
    Height = 4
    Cursor = crHandPoint
    Align = alBottom
    Color = cl3DDkShadow
    MinSize = 1
    ParentColor = False
    ResizeStyle = rsLine
  end
  object Splitter1: TSplitter
    Left = 292
    Top = 0
    Width = 4
    Height = 414
    Align = alRight
    Color = cl3DDkShadow
    MinSize = 1
    ParentColor = False
  end
  object OutputBox: TRichEdit
    Left = 0
    Top = 418
    Width = 751
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
    TabOrder = 0
    WordWrap = False
  end
  object QueryBox: TRichEdit
    Left = 296
    Top = 0
    Width = 455
    Height = 414
    Align = alRight
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
    OnKeyDown = InputBoxKeyDown
    OnKeyUp = InputBoxKeyUp
  end
  object InputBox: TRichEdit
    Left = 0
    Top = 0
    Width = 292
    Height = 414
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
      '/../dll/math.meta$activate'
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
      'jmp#while|'
      'here^exit'
      'res=fsqrt?fmul?res&6,0'
      ''
      'func$activate;?750,0')
    ParentColor = True
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
    WordWrap = False
    OnKeyDown = InputBoxKeyDown
    OnKeyUp = InputBoxKeyUp
  end
  object Timer1: TTimer
    Left = 312
    Top = 8
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    CommandHandlers = <>
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnException = IdHTTPServer1Exception
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    OnCreatePostStream = IdHTTPServer1CreatePostStream
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 344
    Top = 8
  end
end
