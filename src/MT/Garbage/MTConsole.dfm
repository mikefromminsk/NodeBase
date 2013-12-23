object GG: TGG
  Left = 192
  Top = 124
  Width = 914
  Height = 380
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
    Left = 320
    Top = 16
    Width = 35
    Height = 20
    Caption = #1048#1084#1103':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 320
    Top = 48
    Width = 31
    Height = 20
    Caption = #1056#1072#1079':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 320
    Top = 80
    Width = 15
    Height = 20
    Caption = #1057':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 320
    Top = 112
    Width = 25
    Height = 20
    Caption = #1055#1086':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object NameBox: TEdit
    Left = 360
    Top = 13
    Width = 161
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object ActionBox: TComboBox
    Left = 360
    Top = 45
    Width = 161
    Height = 28
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 20
    ItemIndex = 0
    ParentFont = False
    TabOrder = 1
    Text = #1054#1076#1080#1085
    Items.Strings = (
      #1054#1076#1080#1085
      #1053#1077#1089#1082#1086#1083#1100#1082#1086
      #1059#1089#1083#1086#1074#1080#1077
      #1047#1072#1084#1077#1085#1080#1090#1100)
  end
  object LeftBox: TEdit
    Left = 360
    Top = 77
    Width = 161
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object RightBox: TEdit
    Left = 360
    Top = 109
    Width = 161
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object Add: TButton
    Left = 408
    Top = 149
    Width = 113
    Height = 28
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object Data: TRichEdit
    Left = 9
    Top = 5
    Width = 304
    Height = 332
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'procedure func(var: type);')
    ParentFont = False
    TabOrder = 5
  end
  object PageControl1: TPageControl
    Left = 536
    Top = 8
    Width = 353
    Height = 329
    ActivePage = TabSheet1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    object TabSheet1: TTabSheet
      Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      object Struct: TRichEdit
        Left = 0
        Top = 0
        Width = 345
        Height = 294
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
  end
end
