object Form1: TForm1
  Left = 336
  Top = 140
  Width = 280
  Height = 73
  Caption = #1057#1087#1080#1089#1086#1082' '#1087#1088#1086#1094#1077#1089#1089#1086#1074
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 52
    Height = 13
    Caption = #1054#1078#1080#1076#1072#1085#1080#1077
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 8080
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 112
  end
end
