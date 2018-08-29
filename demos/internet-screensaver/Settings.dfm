object SettingForm: TSettingForm
  Left = 0
  Top = 0
  Caption = 'Screen Saver Settings'
  ClientHeight = 454
  ClientWidth = 543
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    543
    454)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = -1
    Top = 414
    Width = 545
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
    ExplicitTop = 464
    ExplicitWidth = 680
  end
  object OkButton: TButton
    Left = 315
    Top = 421
    Width = 107
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Save'
    Default = True
    TabOrder = 2
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 428
    Top = 421
    Width = 107
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = CancelButtonClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 335
    Width = 537
    Height = 50
    Caption = 'Content'
    TabOrder = 1
    object Label3: TLabel
      Left = 16
      Top = 21
      Width = 65
      Height = 13
      Caption = 'URL Address:'
    end
    object UrlEdit: TEdit
      Left = 104
      Top = 18
      Width = 353
      Height = 21
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 15
    Width = 537
    Height = 314
    Caption = 'Splash'
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 21
      Width = 88
      Height = 13
      Caption = 'Background Color:'
    end
    object Label2: TLabel
      Left = 12
      Top = 56
      Width = 68
      Height = 13
      Caption = 'Splash Image:'
    end
    object LoadImageButton: TButton
      Left = 104
      Top = 272
      Width = 107
      Height = 25
      Caption = 'Set Logo'
      TabOrder = 0
      OnClick = LoadImageButtonClick
    end
    object ClearImageButton: TButton
      Left = 217
      Top = 272
      Width = 107
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
      OnClick = ClearImageButtonClick
    end
    object MonitorPanel: TPanel
      Left = 102
      Top = 46
      Width = 387
      Height = 220
      Color = clBtnHighlight
      ParentBackground = False
      TabOrder = 2
      object SplashImage: TImage
        Left = 48
        Top = 48
        Width = 289
        Height = 129
        Align = alCustom
        Center = True
        Proportional = True
        Stretch = True
        OnClick = SplashImageClick
      end
    end
    object SplashColor: TButtonColor
      Left = 102
      Top = 16
      Width = 50
      TabOrder = 3
      OnClick = SplashColorClick
    end
  end
  object ShortcutButton: TButton
    Left = 8
    Top = 421
    Width = 152
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Create Desktop Shortcut'
    TabOrder = 4
    TabStop = False
    WordWrap = True
    OnClick = ShortcutButtonClick
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 
      'All (*.gif;*.cur;*.pcx;*.ani;*.gif;*.png;*.jpg;*.jpeg;*.bmp;*.ti' +
      'f;*.tiff;*.ico;*.emf;*.wmf)|*.gif;*.cur;*.pcx;*.ani;*.gif;*.png;' +
      '*.jpg;*.jpeg;*.bmp;*.tif;*.tiff;*.ico;*.emf;*.wmf|CompuServe GIF' +
      ' Image (*.gif)|*.gif|Cursor files (*.cur)|*.cur|PCX Image (*.pcx' +
      ')|*.pcx|ANI Image (*.ani)|*.ani|GIF Image (*.gif)|*.gif|Portable' +
      ' Network Graphics (*.png)|*.png|JPEG Image File (*.jpg)|*.jpg|JP' +
      'EG Image File (*.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bmp|TIFF Images ' +
      '(*.tif)|*.tif|TIFF Images (*.tiff)|*.tiff|Icons (*.ico)|*.ico|En' +
      'hanced Metafiles (*.emf)|*.emf|Metafiles (*.wmf)|*.wmf'
    FilterIndex = 0
    Left = 488
    Top = 8
  end
end
