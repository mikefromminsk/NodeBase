object Form1: TForm1
  Left = 192
  Top = 124
  Width = 499
  Height = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 41
    Height = 13
    Caption = #1044#1072#1085#1085#1099#1077
  end
  object Label2: TLabel
    Left = 243
    Top = 4
    Width = 51
    Height = 13
    Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072
  end
  object Memo1: TMemo
    Left = 8
    Top = 24
    Width = 233
    Height = 201
    Lines.Strings = (
      'http://www.google.by/search?client=opera&q=waegwg')
    TabOrder = 0
    WordWrap = False
  end
  object Button1: TButton
    Left = 400
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Parse'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo2: TMemo
    Left = 248
    Top = 24
    Width = 225
    Height = 201
    Lines.Strings = (
      '  <URL Mask="*.">'
      '   <Path Mask="*%3f;*."/>'
      '   <Param Mask="*%26:*.">'
      '    <Value Mask="%3d*."/>'
      '    <Type Mask="%3a*."/>'
      '    <Name Mask="*."/>'
      '   </Param>'
      '  </URL>')
    TabOrder = 2
  end
end
