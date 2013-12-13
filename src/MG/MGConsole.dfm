object MGConcole: TMGConcole
  Left = 210
  Top = 124
  BorderStyle = bsSingle
  ClientHeight = 486
  ClientWidth = 634
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 301
    Top = 0
    Height = 486
    Align = alRight
  end
  object InputBox: TRichEdit
    Left = 0
    Top = 0
    Width = 301
    Height = 486
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      '/../dll/math.meta$R1'
      ''
      'je$R100000?$G1?2&2;&4;#$E1|'
      ''
      '@149')
    ParentFont = False
    TabOrder = 0
    WordWrap = False
    OnKeyUp = InputBoxKeyUp
  end
  object ModuleBox: TRichEdit
    Left = 304
    Top = 0
    Width = 330
    Height = 486
    Align = alRight
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
end
