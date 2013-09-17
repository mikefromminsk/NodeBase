object Form1: TForm1
  Left = 192
  Top = 114
  Width = 870
  Height = 640
  Caption = 'Form1'
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
  object SG: TStringGrid
    Left = 24
    Top = 160
    Width = 665
    Height = 41
    ColCount = 20
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 0
  end
  object Button1: TButton
    Left = 336
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Cauchy'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Chart1: TChart
    Left = 16
    Top = 232
    Width = 289
    Height = 177
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Title.Text.Strings = (
      'TChart')
    TabOrder = 2
    object Series1: TLineSeries
      Marks.ArrowLength = 8
      Marks.Visible = False
      SeriesColor = clRed
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object Button2: TButton
    Left = 424
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Arrays'
    TabOrder = 3
    OnClick = Button2Click
  end
  object SG2: TStringGrid
    Left = 512
    Top = 232
    Width = 337
    Height = 25
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 4
  end
end
