object Form1: TForm1
  Left = 350
  Top = 170
  Width = 544
  Height = 341
  Caption = #1055#1088#1086#1089#1090#1086' '#1087#1086#1080#1089#1082#1086#1074#1080#1082
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
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 113
    Height = 297
    ItemHeight = 13
    TabOrder = 0
  end
  object ListBox2: TListBox
    Left = 120
    Top = 0
    Width = 121
    Height = 297
    ItemHeight = 13
    TabOrder = 1
  end
  object ListBox3: TListBox
    Left = 248
    Top = 0
    Width = 273
    Height = 257
    ItemHeight = 13
    TabOrder = 2
  end
  object Button1: TButton
    Left = 248
    Top = 264
    Width = 273
    Height = 33
    Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
    TabOrder = 3
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 24
  end
  object http: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 56
    Top = 24
  end
end
