object GG: TGG
  Left = 833
  Top = 218
  Width = 533
  Height = 510
  BorderIcons = [biSystemMenu]
  Caption = 'NodeBase'
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
    Top = 414
    Width = 525
    Height = 4
    Cursor = crHandPoint
    Align = alBottom
    Color = cl3DDkShadow
    MinSize = 1
    ParentColor = False
    ResizeStyle = rsLine
  end
  object Splitter1: TSplitter
    Left = 236
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
    Width = 525
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
    Left = 240
    Top = 0
    Width = 285
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
    Width = 236
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
      '/dll/math32.node$activate'
      ''
      'func?a:float#res'
      'i'
      'dx'
      'res=0'
      'i=1'
      'dx=1'
      'while'
      'je?i&a>exit'
      'i=inc?i'
      'res=add?res&dx'
      'dx=fdiv?1&sqr?i'
      '1>while'
      'here^exit'
      'res=sqrt?mul?res&6'
      ''
      'func$activate?750')
    ParentColor = True
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
    WordWrap = False
    OnKeyDown = InputBoxKeyDown
    OnKeyUp = InputBoxKeyUp
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
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
  object RightClickToIcon: TPopupMenu
    Left = 312
    Top = 48
    object Console: TMenuItem
      Caption = 'Console'
      OnClick = ConsoleClick
    end
    object Exit: TMenuItem
      Caption = 'Exit'
      OnClick = ExitClick
    end
  end
end
