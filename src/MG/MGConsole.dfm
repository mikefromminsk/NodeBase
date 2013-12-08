object MGConcole: TMGConcole
  Left = 210
  Top = 124
  BorderStyle = bsSingle
  ClientHeight = 486
  ClientWidth = 432
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 245
    Top = 0
    Height = 486
    Align = alRight
  end
  object InputBox: TRichEdit
    Left = 0
    Top = 0
    Width = 245
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
      'func$R1000G1?2&2')
    ParentFont = False
    TabOrder = 0
    WordWrap = False
    OnKeyUp = InputBoxKeyUp
  end
  object ModuleBox: TRichEdit
    Left = 248
    Top = 0
    Width = 184
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
