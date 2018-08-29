object MainForm: TMainForm
  Left = 0
  Top = 0
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsNone
  Caption = 'Screen Saver'
  ClientHeight = 486
  ClientWidth = 700
  Color = clBlack
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 700
    Height = 486
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    TabOrder = 0
    OnProgressChange = WebBrowser1ProgressChange
    OnDocumentComplete = WebBrowser1DocumentComplete
    OnNavigateError = WebBrowser1NavigateError
    ExplicitLeft = 29
    ExplicitTop = 256
    ExplicitWidth = 635
    ExplicitHeight = 483
    ControlData = {
      4C000000594800003B3200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object SplashPanel: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 486
    Align = alClient
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      700
      486)
    object SplashImage: TImage
      Left = 160
      Top = 136
      Width = 369
      Height = 217
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Center = True
      Proportional = True
      Stretch = True
    end
    object SplashProgressBar: TJvSpecialProgress
      Left = 16
      Top = 458
      Width = 671
      Height = 12
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'SplashProgressBar'
      EndColor = clGray
      Solid = True
      StartColor = clGray
    end
    object MessageLabel: TLabel
      Left = 16
      Top = 405
      Width = 671
      Height = 39
      Alignment = taCenter
      Anchors = [akLeft, akRight, akBottom]
      AutoSize = False
      Caption = 'Screensaver Message'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -32
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object GracePeriodTimer: TTimer
    Interval = 1500
    OnTimer = GracePeriodTimerTimer
    Left = 16
    Top = 16
  end
end
