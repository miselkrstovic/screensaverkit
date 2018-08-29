program InternetScreensaver;

uses
  Main in 'Main.pas' {MainForm},
  Settings in 'Settings.pas' {SettingsForm},
  UNulContainer in 'UNulContainer.pas',
  IntfDocHostUIHandler in 'IntfDocHostUIHandler.pas',
  UContainer in 'UContainer.pas',
  ScreensaverKit in '..\..\src\ScreensaverKit.pas',
  ScreensaverKit.SettingUtils in '..\..\src\ScreensaverKit.SettingUtils.pas',
  ScreensaverKit.ShortcutUtils in '..\..\src\ScreensaverKit.ShortcutUtils.pas',
  ScreensaverKit.WebBrowserUtils in '..\..\src\ScreensaverKit.WebBrowserUtils.pas';

{$R *.res}
{$E scr}

begin
  Screensaver.Initialize;
  Screensaver.Run;
end.
