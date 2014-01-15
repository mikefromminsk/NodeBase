object Form1: TForm1
  Left = 192
  Top = 124
  Width = 1060
  Height = 441
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
  object StructEdit: TRichEdit
    Left = 336
    Top = 16
    Width = 329
    Height = 345
    Lines.Strings = (
      '<body cut="^begin\s(.*)" group="1">'
      #9'<block inherited="body"/>'
      #9'<set cut="(.*?):=(.*?);"/>'
      #9'<end exit="^end;"/>'
      '</body>')
    TabOrder = 0
    WordWrap = False
  end
  object Button3: TButton
    Left = 728
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 1
    OnClick = Button3Click
  end
  object ResultEdit: TRichEdit
    Left = 16
    Top = 16
    Width = 313
    Height = 345
    TabOrder = 2
    WordWrap = False
  end
  object BuildStructEdit: TRichEdit
    Left = 672
    Top = 16
    Width = 361
    Height = 345
    Lines.Strings = (
      '<func>'
      '<funchead s="function [funcname]([params]):[restype];" >'
      #9'<params s="[param];">'
      #9#9'<param s="[pname]:[ptype]"/>'
      #9'</params>'
      '</funchead>'
      ''
      '</func>')
    TabOrder = 3
    WordWrap = False
  end
  object Button1: TButton
    Left = 600
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 16
    Top = 368
    Width = 313
    Height = 21
    TabOrder = 5
    Text = 'begin begin Result:=i+1;end;end;'
  end
end
