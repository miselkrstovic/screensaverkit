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
{ The Original Code is Main.pas.                                               }
{                                                                              }
{ Unit owner:    Misel Krstovic                                                }
{ Last modified: October 15, 2017                                              }
{                                                                              }
{******************************************************************************}

unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, SHDocVw, Vcl.OleCtrls, Vcl.ComCtrls, JvExComCtrls, JvProgressBar,
  UContainer, JvExControls, JvWaitingProgress, JvExExtCtrls, JvExtComponent,
  JvPanel, ScreensaverKit, IdBaseComponent, IdAntiFreezeBase, Vcl.IdAntiFreeze,
  JvSpecialProgress;

type
  TMainForm = class(TScreensaverMainForm)
    WebBrowser1: TWebBrowser;
    GracePeriodTimer: TTimer;
    SplashPanel: TPanel;
    SplashImage: TImage;
    SplashProgressBar: TJvSpecialProgress;
    MessageLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GracePeriodTimerTimer(Sender: TObject);
    procedure WebBrowser1NavigateError(ASender: TObject; const pDisp: IDispatch;
      const URL, Frame, StatusCode: OleVariant; var Cancel: WordBool);
    procedure FormDestroy(Sender: TObject);
    procedure SplashProgressBarEnded(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; const URL: OleVariant);
    procedure WebBrowser1ProgressChange(ASender: TObject; Progress,
      ProgressMax: Integer);
  private
    { Private declarations }
    fWBContainer: TWBContainer;

    ErrorOccurred: Boolean;
    SettingURL: String;
    ImagePath : String;

    procedure EnableProgressBar;
    procedure DisableProgressBar;
  public
    { Public declarations }
    procedure DisplayMessage(AMessage: String);
  end;

var
  MainForm: TMainForm;


implementation

{$R *.dfm}

uses
  ScreensaverKit.WebBrowserUtils, WinInet, GraphUtil, UxTheme, CommCtrl, Math,
  IdIcmpClient;

{
  https://lawrencebarsanti.wordpress.com/2010/01/03/lighten-colors-programmatically-with-delphi/
}
function Brighten(AColor: TColor): TColor;
var
  H, S, L: Word;
begin
  ColorRGBToHLS(AColor, H, L, S);

  // Luminacity fix
  L := L + 100;
  if L>255 then L := 255;

  Result := ColorHLSToRGB(H, L, S);
end;

function Darken(AColor: TColor): TColor;
var
  H, S, L: Word;
begin
  ColorRGBToHLS(AColor, H, L, S);

  // Luminacity fix
  if (L - 100)<0 then begin
    L := 0;
  end else begin
    L := L - 100;
  end;

  Result := ColorHLSToRGB(H, 100, S);
end;

function Highlight(AColor: TColor): TColor;
begin
  if AColor<$808080 then begin
    result := Brighten(AColor);
  end else begin
    result := Darken(AColor);
  end;
end;

{
  ColorToHTML is taken from the CodeSnip database at
  http://www.delphidabbler.com/codesnip
}
function ColorToHTML(const Color: TColor): string;
var
  ColorRGB: Integer;
begin
  ColorRGB := ColorToRGB(Color);
  Result := Format(
    '#%0.2X%0.2X%0.2X',
    [GetRValue(ColorRGB), GetGValue(ColorRGB), GetBValue(ColorRGB)]
  );
end;

procedure TMainForm.DisableProgressBar;
begin
  SplashProgressBar.Visible := False;
end;

procedure TMainForm.DisplayMessage(AMessage: String);
begin
  MessageLabel.Caption := Trim(AMessage);
end;

procedure TMainForm.EnableProgressBar;
begin
  // Setup progress bar
  SplashProgressBar.Visible := True;

  SplashProgressBar.Color :=  Self.Color;
  SplashProgressBar.StartColor := Highlight(Self.Color);
  SplashProgressBar.EndColor := Highlight(Self.Color);

  SplashProgressBar.ControlStyle := SplashProgressBar.ControlStyle - [csFramed, csOverrideStylePaint];
end;

procedure TMainForm.FormCreate(Sender: TObject);
const
  // Template for default CSS style
  cCSSTplt = 'body {'#13#10
    + '    background-color: %0:s;'#13#10
    + '    color: %1:s;'#13#10
    + '    font-family: "%2:s";'#13#10
    + '    font-size: %3:dpt;'#13#10
    + '    margin: 4px;'#13#10
    + '}'#13#10
    + 'h1 {'#13#10
    + '    font-size: %3:dpt;'#13#10
    + '    font-weight: bold;'#13#10
    + '    text-align: center;'#13#10
    + '}'#13#10
    + 'input#button {'#13#10
    + '    color: %1:s;'#13#10
    + '    font-family: "%2:s";'#13#10
    + '    font-size: %3:dpt;'#13#10
    + '}'#13#10
    + '.ruled {'#13#10
    + '    border-bottom: %4:s solid 2px;'#13#10
    + '    padding-bottom: 6px;'#13#10
    + '}';
var
  FmtCSS: string;  // Stores default CSS
  Loaded: Boolean;
begin
  DisplayMessage(''); // Clear the message

  if Screensaver.IsPreviewMode then begin
    // Special chaneges for preview mode
    SplashImage.Align := alClient;
  end;

  // Load url from registry
  SettingURL := Trim(Screensaver.Settings.ReadString('URL', ''));

  // Load splash image path from registry
  ImagePath := Trim(Screensaver.Settings.ReadString('SplashImagePath', ''));
  if Length(ImagePath)>0 then begin
    if FileExists(ImagePath) then begin
      try
        SplashImage.Picture.LoadFromFile(ImagePath);
        Loaded := True;
      except
      end;
    end;
  end;

  // Load splash background color from registry
  Self.Color := Screensaver.Settings.ReadColor('SplashBackgroundColor', clBlack);

  MessageLabel.Color := Self.Color;
  MessageLabel.Font.Color := Highlight(Self.Color);

  if not Screensaver.IsPreviewMode then begin
    if (Length(ImagePath)>0) and (Loaded=False) then begin
      if Length(SettingURL)=0 then begin
        DisplayMessage('Failed to load splash image, and no url was set.');
      end else begin
        DisplayMessage('Failed to load splash image.');
      end;
    end else begin
      if Length(SettingURL)=0 then begin
        DisplayMessage('No url was set.');
      end else begin
        // Do nothing
      end;
    end;

    // Create the CSS from system colours
    FmtCSS := Format(
      cCSSTplt,
      [ColorToHTML(Self.Color), ColorToHTML(Self.Font.Color),
      Self.Font.Name, Self.Font.Size,
      ColorToHTML(clInactiveCaption)]
    );

    // Create web browser container and set required properties
    fWBContainer := TWBContainer.Create(WebBrowser1);
    fWBContainer.UseCustomCtxMenu := True;    // use our popup menu
    fWBContainer.Show3DBorder := False;       // no border
    fWBContainer.ShowScrollBars := False;     // no scroll bars
    fWBContainer.AllowTextSelection := False; // no text selection (**)
//    fWBContainer.CSS := FmtCSS;               // CSS to be used
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fWBContainer.Free;  // free the container pbject
end;

function CheckInternetConnection: boolean;
var
  Origin : cardinal;

  Client: TIdIcmpClient;
  Rec: Integer;
begin
  Result:= False;

  // TODO: Need a better syncrhonous way to check connectivity
  // Check if we have network link
//  if InternetGetConnectedState(@Origin, 0) then begin
//    // Check if path to internet
//    Client := TIdIcmpClient.Create(nil);
//    try
//      Application.ProcessMessages;
//
//      Client.Host:= '8.8.8.8';
//      Client.Ping();
//      Sleep(2000);
//      Rec := Client.ReplyStatus.BytesReceived;
//      if Rec > 0 then Result := True else Result:= False;
//    finally
//      Client.Free;
//    end;
//  end;

  result := InternetGetConnectedState(@Origin, 0);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  inherited;

  if not Screensaver.IsPreviewMode then begin
    if CheckInternetConnection then begin
      EnableProgressBar;

      // Start proxied navigation
      fWBContainer.HostedBrowser.Navigate(SettingURL);
    end else begin
      DisplayMessage('No internet connection available.');
    end;
  end else begin
    DisableProgressBar;
  end;
end;

procedure TMainForm.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
begin
  if not ErrorOccurred then begin
    DisableProgressBar;
    SplashPanel.SendToBack;
  end;
end;

procedure TMainForm.WebBrowser1NavigateError(ASender: TObject;
  const pDisp: IDispatch; const URL, Frame, StatusCode: OleVariant;
  var Cancel: WordBool);
begin
  SplashPanel.BringToFront;
  DisplayMessage('Failed to load url content.');
  ErrorOccurred := True;
  DisableProgressBar;
end;

procedure TMainForm.WebBrowser1ProgressChange(ASender: TObject; Progress,
  ProgressMax: Integer);
begin
  SplashProgressBar.Position := Progress;
  SplashProgressBar.Maximum := ProgressMax;
end;

procedure TMainForm.GracePeriodTimerTimer(Sender: TObject);
begin
  GracePeriodTimer.Enabled := False;
  AllowShutdown := True;
end;

procedure TMainForm.SplashProgressBarEnded(Sender: TObject);
begin
  DisableProgressBar;
end;

initialization
  RegisterClass(TMainForm);
end.
