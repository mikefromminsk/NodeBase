object Form1: TForm1
  Left = 192
  Top = 124
  Width = 733
  Height = 428
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
  object Label3: TLabel
    Left = 475
    Top = 4
    Width = 52
    Height = 13
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
  end
  object Memo1: TMemo
    Left = 8
    Top = 24
    Width = 233
    Height = 201
    Lines.Strings = (
      'function Name(a: Integer): Integer;'
      'begin'
      '  Result := a + 1;'
      'end;')
    TabOrder = 0
    WordWrap = False
  end
  object Button1: TButton
    Left = 488
    Top = 240
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
  object Memo3: TMemo
    Left = 480
    Top = 24
    Width = 225
    Height = 201
    TabOrder = 3
  end
end
