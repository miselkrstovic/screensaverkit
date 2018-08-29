{******************************************************************************}
{                                                                              }
{ Internet Screensaver                                                         }
{                                                                              }
{ The contents of this file are subject to the MIT License (the "License");    }
{ you may not use this file except in compliance with the License.             }
{ You may obtain a copy of the License at https://opensource.org/licenses/MIT  }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ The Original Code is Settings.pas.                                           }
{                                                                              }
{ Unit owner:    Misel Krstovic                                                }
{ Last modified: October 15, 2017                                              }
{                                                                              }
{******************************************************************************}

unit Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, JvExControls, JvColorBox, JvColorButton, Vcl.ExtDlgs,
  VCLTee.TeCanvas, ScreensaverKit;

type
  TSettingForm = class(TScreensaverSettingForm)
    OkButton: TButton;
    CancelButton: TButton;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    UrlEdit: TEdit;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LoadImageButton: TButton;
    ClearImageButton: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    ShortcutButton: TButton;
    MonitorPanel: TPanel;
    SplashImage: TImage;
    Bevel1: TBevel;
    SplashColor: TButtonColor;
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ClearImageButtonClick(Sender: TObject);
    procedure LoadImageButtonClick(Sender: TObject);
    procedure SplashImageClick(Sender: TObject);
    procedure ShortcutButtonClick(Sender: TObject);
    procedure SplashColorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingsForm: TSettingForm;

implementation

{$R *.dfm}

var
  ImagePath: String;

procedure TSettingForm.OkButtonClick(Sender: TObject);
begin
  // Write settings to registry
  Screensaver.Settings.WriteString('URL', Trim(UrlEdit.Text));
  Screensaver.Settings.WriteString('SplashImagePath', Trim(ImagePath));
  Screensaver.Settings.WriteColor('SplashBackgroundColor', SplashColor.SymbolColor);

  Close;
end;

procedure TSettingForm.ShortcutButtonClick(Sender: TObject);
begin
  if Screensaver.CreateDesktopShortcut() then begin
    MessageDlg('Shortcut was successfully created.', mtInformation, [mbOK], 0);
  end else begin
    MessageDlg('An error occurred while attempting to create shortcut.', mtError, [mbOK], 0);
  end;
end;

procedure TSettingForm.SplashColorClick(Sender: TObject);
begin
  MonitorPanel.Color := SplashColor.SymbolColor;
end;

procedure TSettingForm.SplashImageClick(Sender: TObject);
begin
  LoadImageButtonClick(Sender);
end;

procedure TSettingForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingForm.ClearImageButtonClick(Sender: TObject);
begin
  ImagePath := '';
  SplashImage.Picture := nil;
end;

procedure TSettingForm.FormShow(Sender: TObject);
begin
  // Load settings from registry
  UrlEdit.Text := trim(Screensaver.Settings.ReadString('URL', ''));

  ImagePath := trim(Screensaver.Settings.ReadString('SplashImagePath', ''));
  if FileExists(ImagePath) then begin
    try
      SplashImage.Picture.LoadFromFile(ImagePath);
    except
    end;
  end;

  SplashColor.SymbolColor := Screensaver.Settings.ReadColor('SplashBackgroundColor', clBlack);

  MonitorPanel.Color := SplashColor.SymbolColor;
end;

procedure TSettingForm.LoadImageButtonClick(Sender: TObject);
begin
  OpenPictureDialog1.FilterIndex := 0; // This shows almost all filters

  if OpenPictureDialog1.Execute(Handle) then begin
    if FileExists(OpenPictureDialog1.FileName) then begin
      try
        SplashImage.Picture.LoadFromFile(OpenPictureDialog1.FileName);
        ImagePath := OpenPictureDialog1.FileName;
      except
        ShowMessage('Failed to set the splash image.');
      end;
    end;
  end;
end;

initialization
  RegisterClass(TSettingForm);
end.
