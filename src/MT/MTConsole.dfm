object GG: TGG
  Left = 192
  Top = 124
  Width = 928
  Height = 480
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 912
    Height = 442
    ActivePage = TabSheet2
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1055#1077#1088#1077#1074#1086#1076#1095#1080#1082
      OnShow = TabSheet1Show
      object Splitter1: TSplitter
        Left = 441
        Top = 121
        Height = 286
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 904
        Height = 121
        Align = alTop
        TabOrder = 0
        object FromStruct: TComboBox
          Left = 232
          Top = 72
          Width = 161
          Height = 28
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 20
          ParentFont = False
          TabOrder = 0
        end
        object ToStruct: TComboBox
          Left = 480
          Top = 72
          Width = 161
          Height = 28
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 20
          ParentFont = False
          TabOrder = 1
        end
        object Button1: TButton
          Left = 672
          Top = 72
          Width = 89
          Height = 28
          Caption = #1055#1077#1088#1077#1074#1086#1076
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 121
        Width = 441
        Height = 286
        Align = alLeft
        TabOrder = 1
        object FromData: TRichEdit
          Left = 1
          Top = 1
          Width = 439
          Height = 284
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
      end
      object Panel3: TPanel
        Left = 444
        Top = 121
        Width = 460
        Height = 286
        Align = alClient
        TabOrder = 2
        object ToData: TRichEdit
          Left = 1
          Top = 1
          Width = 458
          Height = 284
          Align = alClient
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1080#1079#1072#1090#1086#1088
      ImageIndex = 1
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 904
        Height = 393
        Align = alTop
        TabOrder = 0
        object LeftBox: TEdit
          Left = 470
          Top = 53
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
        object RightBox: TEdit
          Left = 638
          Top = 53
          Width = 161
          Height = 28
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object Add: TButton
          Left = 808
          Top = 53
          Width = 81
          Height = 28
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100
          TabOrder = 2
          OnClick = AddClick
        end
        object ActionBox: TComboBox
          Left = 176
          Top = 53
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
          TabOrder = 3
          Text = 'One'
          Items.Strings = (
            'One'
            'Array'
            'If'
            'Replace')
        end
        object NameBox: TEdit
          Left = 8
          Top = 53
          Width = 161
          Height = 28
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          Text = 'Ini'
        end
        object TreeView1: TTreeView
          Left = 240
          Top = 104
          Width = 417
          Height = 281
          Indent = 19
          TabOrder = 5
        end
        object ResultBox: TRichEdit
          Left = 656
          Top = 104
          Width = 247
          Height = 281
          Color = clBtnFace
          TabOrder = 6
        end
        object DataBox: TRichEdit
          Left = 1
          Top = 104
          Width = 240
          Height = 281
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          Lines.Strings = (
            'Hello my litle pony.'
            'This for you.')
          ParentFont = False
          TabOrder = 7
          OnMouseUp = DataBoxMouseUp
        end
      end
    end
  end
  object XPManifest1: TXPManifest
    Left = 868
    Top = 40
  end
end
