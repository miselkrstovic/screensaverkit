{******************************************************************************}
{                                                                              }
{ ScreensaverKit                                                               }
{                                                                              }
{ The contents of this file are subject to the MIT License (the "License");    }
{ you may not use this file except in compliance with the License.             }
{ You may obtain a copy of the License at https://opensource.org/licenses/MIT  }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ The Original Code is ScreensaverKit.pas.                                     }
{                                                                              }
{ Contains various graphics related classes and subroutines required for       }
{ creating a chart and its nodes, and visual chart interaction.                }
{                                                                              }
{ Unit owner:    Misel Krstovic                                                }
{ Last modified: October 15, 2017                                              }
{                                                                              }
{******************************************************************************}

unit ScreensaverKit;

interface

uses
  SysUtils,
  Windows,
  Classes,
  Forms,
  Controls,
  ScreensaverKit.SettingUtils;

(*

  ScreenSaver           - Show the Settings dialog box.
  ScreenSaver /c        - Show the Settings dialog box, modal to the
                         foreground window.
  ScreenSaver /p <HWND> - Preview Screen Saver as child of window <HWND>.
  ScreenSaver /s        - Run the Screen Saver.

  ScreenSaver /a <HWND> - change password, modal to window <HWND>


  https://support.microsoft.com/en-us/help/182383/info-screen-saver-command-line-arguments
  http://www.tek-tips.com/faqs.cfm?fid=6914
  http://www.mindspring.com/~cityzoo/scrnsavr.html

*)

type
  TScreensaverMode = (smSettings, smSettingsModal, smPreview, smRun, smPassword, smUnknown);

  TScreensaver = class
  private
    ScreenSaverMode : TScreensaverMode;
    ScreenSaverHandle : HWND;

    Echoes: hWnd;
    Ws: hWnd;
    UoF: TagUserObjectFlags;

    function GetFirstArgument(): String;
    function GetSecondArgument(): String;
    procedure DecodeScreenSaverMode();

    procedure TaskDialog(const Title, Msg: string);
    function InvokeDebugDialog(): TModalResult;
    procedure RegisterWindowStation;
  public
    Settings: TScreensaverSettings;

    // Screensaver mode interrogation
    function IsSettingsMode(): Boolean;
    function IsSettingsModalMode(): Boolean;
    function IsPreviewMode(): Boolean;
    function IsRunMode(): Boolean;
    function IsPasswordMode(): Boolean;
    function GetScreenSaverMode(): TScreensaverMode;

    // Handles
    function GetParentHandle(): HWND;

    // Auxiliary
    function CreateDesktopShortcut(): Boolean;

    // Lifecyle
    procedure Initialize;
    procedure Run;

    constructor Create(Name: String);
    destructor Destroy;
  end;

  TScreensaverSettingForm = class(TForm)
  public
    constructor Create(AOwner: TComponent); override;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  CallSuperAttribute = class(TCustomAttribute) // TODO: Enforce subclasses to call inherited
  public
    constructor Create;
  end;

  TScreensaverMainForm = class(TForm)
    [CallSuper]
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    [CallSuper]
    procedure FormResize(Sender: TObject);
    [CallSuper]
    procedure FormShow(Sender: TObject);
  private
    InitialMousePosition: TPoint;

    procedure MsgHandler(var Msg: TMsg; var Handled: Boolean);

    procedure StoreMousePosition();
    function HasMousePositionChanged(): Boolean;

    function IsPrimaryMonitor: Boolean;
  public
    AllowShutdown: Boolean;
    MonitorId: Integer;

    constructor Create(AOwner: TComponent); override;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  procedure StartScreensaver;

var
  Screensaver: TScreensaver;

implementation

uses
  Messages,
  Math,
  Dialogs,
  ScreensaverKit.ShortcutUtils;

const
  SETTINGS_ARGUMENT = '';
  SETTINGS_MODAL_ARGUMENT = '/c';
  PREVIEW_ARGUMENT = '/p';
  RUN_ARGUMENT = '/s';
  PASSWORD_ARGUMENT = '/a';

  SCREENSAVERKIT_MUTEX = 'SCREENSAVERKIT_MUTEX';

function Element(element_number: integer;
                 const delimiter: String;
                 const source: String): String;
var
  lst: TStringList;
begin
  lst := TStringList.Create;
  try
    lst.Sorted := false;
    lst.Duplicates := dupIgnore;
    lst.LineBreak := delimiter;
    lst.Text := source;
    if element_number < lst.Count then begin
      result := lst.Strings[element_number];
    end else begin
      result := '';
    end;
  finally
    lst.Free;
  end;
end;

destructor TScreensaver.Destroy;
begin
  Settings.Free;
end;

function TScreensaver.GetFirstArgument(): String;
begin
  if ParamCount>=1 then begin
    result := LowerCase(Element(0, ':', ParamStr(1)));
  end else begin
    result := '';
  end;
end;

function TScreensaver.GetSecondArgument(): String;
begin
  if ParamCount=2 then begin
    result := ParamStr(2);
  end else if ParamCount=1 then begin
    if Pos(':', ParamStr(1))<>0 then begin
      result := Element(1, ':', ParamStr(1));
    end else begin
      result := '';
    end;
  end else begin
    result := '';
  end;
end;

constructor TScreensaver.Create(Name: String);
begin
  Name := trim(Name);
  if Length(Name)=0 then begin
    Name := 'Default';
  end;

  Settings := TScreensaverSettings.Create('\Software\ScreensaverKit\' + Name);
end;

function TScreensaver.CreateDesktopShortcut(): Boolean;
begin
  result := CreateDesktopShellLink(ParamStr(0));
end;

procedure TScreensaver.DecodeScreenSaverMode();
var
  Command : String;
  Handle  : String;
begin
  // Parse command and set screensaver mode
  Command := GetFirstArgument();
  if Command = PREVIEW_ARGUMENT then begin
    ScreenSaverMode := smPreview;
  end else if Command = SETTINGS_MODAL_ARGUMENT then begin
    ScreenSaverMode := smSettingsModal;
  end else if Command = SETTINGS_ARGUMENT then begin
    ScreenSaverMode := smSettings;
  end else if Command = RUN_ARGUMENT then begin
    ScreenSaverMode := smRun;
  end else begin
    ScreenSaverMode := smUnknown;
  end;

  // Parse handle
  Handle := GetSecondArgument();
  if Length(Handle)>0 then begin
    ScreenSaverHandle := StrToUInt64(Handle);
  end else begin
    ScreenSaverHandle := 0;
  end;
end;

function TScreensaver.GetScreenSaverMode(): TScreensaverMode;
begin
  if LowerCase(ExtractFileExt(ParamStr(0)))='.exe' then begin
    ScreenSaverMode := smRun;
    result := ScreenSaverMode;
  end else begin
    DecodeScreenSaverMode;
    result := ScreenSaverMode;
  end;
end;

function TScreensaver.GetParentHandle(): HWND;
begin
  result := ScreenSaverHandle;
end;

function TScreensaver.IsSettingsMode(): Boolean;
begin
  result := ScreenSaverMode = smSettings;
end;

function TScreensaver.IsSettingsModalMode(): Boolean;
begin
  result := ScreenSaverMode = smSettingsModal;
end;

function TScreensaver.IsPreviewMode(): Boolean;
begin
  result := ScreenSaverMode = smPreview;
end;

function TScreensaver.IsRunMode(): Boolean;
begin
  result := ScreenSaverMode = smRun;
end;

procedure TScreensaver.Initialize;
begin
  Application.Initialize;
  Application.MainFormOnTaskBar := False;
end;

function TScreensaver.IsPasswordMode(): Boolean;
begin
  result := ScreenSaverMode = smPassword;
end;

procedure TScreensaver.RegisterWindowStation;
begin
  //- User Object Flag Setup
  UoF.fInherit := TRUE;
  UoF.dwFlags := WSF_VISIBLE;

  //- Window Station Creation
  CreateWindowStation('Echoes: Window Station', 0, WINSTA_ACCESSCLIPBOARD and WINSTA_ACCESSGLOBALATOMS and WINSTA_CREATEDESKTOP and WINSTA_ENUMDESKTOPS and WINSTA_ENUMERATE and WINSTA_EXITWINDOWS and WINSTA_READATTRIBUTES and WINSTA_READSCREEN and WINSTA_WRITEATTRIBUTES, nil);
  Ws := OpenWindowStation('Echoes: Window Station', TRUE, WINSTA_ACCESSCLIPBOARD and WINSTA_ACCESSGLOBALATOMS and WINSTA_CREATEDESKTOP and WINSTA_ENUMDESKTOPS and WINSTA_ENUMERATE and WINSTA_EXITWINDOWS and WINSTA_READATTRIBUTES and WINSTA_READSCREEN and WINSTA_WRITEATTRIBUTES);
  SetUserObjectInformation(Ws, UOI_FLAGS, @UoF, 0);
end;

{
  Creates a mutex to see if the program is already running.
  https://stackoverflow.com/questions/20669917/one-instance-of-app-per-computer-how
}
function IsSingleInstance(MutexName : string; KeepMutex : boolean = true): boolean;
const
  MUTEX_GLOBAL = 'Global\'; // Prefix to explicitly create the object in the global or session namespace. I.e. both client app (local user) and service (system account)
var
  MutexHandle: THandle;
  SecurityDesc: TSecurityDescriptor;
  SecurityAttr: TSecurityAttributes;
  ErrCode: integer;
begin
  //  By default (lpMutexAttributes = nil) created mutexes are accessible only by
  //  the user running the process. We need our mutexes to be accessible to all
  //  users, so that the mutex detection can work across user sessions.
  //  I.e. both the current user account and the System (Service) account.
  //  To do this we use a security descriptor with a null DACL.
  InitializeSecurityDescriptor(@SecurityDesc, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@SecurityDesc, True, nil, False);
  SecurityAttr.nLength:=SizeOf(SecurityAttr);
  SecurityAttr.lpSecurityDescriptor:=@SecurityDesc;
  SecurityAttr.bInheritHandle:=False;

  //  The mutex is created in the global name space which makes it possible to
  //  access across user sessions.
  MutexHandle := CreateMutex(@SecurityAttr, True, PChar(MUTEX_GLOBAL + MutexName));
  ErrCode := GetLastError;

  //  If the function fails, the return value is 0
  //  If the mutex is a named mutex and the object existed before this function
  //  call, the return value is a handle to the existing object, GetLastError
  //  returns ERROR_ALREADY_EXISTS.
  if {(MutexHandel = 0) or }(ErrCode = ERROR_ALREADY_EXISTS) then begin
    result := false;
    closeHandle(MutexHandle);
  end else begin
    //  Mutex object has not yet been created, meaning that no previous
    //  instance has been created.
    result := true;

    if not KeepMutex then CloseHandle(MutexHandle);
  end;

  // The Mutexhandle is not closed because we want it to exist during the
  // lifetime of the application. The system closes the handle automatically
  // when the process terminates.
end;

procedure TScreensaver.Run;
var
  MainForms: array of TScreensaverMainForm;
  MainForm: TScreensaverMainForm;
  SettingsForm: TScreensaverSettingForm;
  i : Integer;

  Mode: TScreensaverMode;
begin
  Mode := Screensaver.GetScreenSaverMode;

  if DebugHook<>0 then begin
    case InvokeDebugDialog() of
      mrYes: begin
        Mode := smRun;
      end;
      mrNo: begin
        Mode := smSettings;
      end;
      mrCancel: begin
        Mode := smUnknown;
      end;
    end;
  end;

  case Mode of
    smPreview: begin
      try
        if Screensaver.GetParentHandle<>0 then begin
          Application.CreateForm(TFormClass(FindClass('TMainForm')), MainForm);
          Application.Run;
        end;
      except // EClassNotFound
        Application.Terminate;
      end;
    end;
    smSettings: begin
      try
        Application.CreateForm(TFormClass(FindClass('TSettingForm')), SettingsForm);
        Application.Run;
      except // EClassNotFound
        TaskDialog('No options', 'This screen saver had no options that you can set.');
      end;
    end;
    smSettingsModal: begin
      try
        Application.CreateForm(TFormClass(FindClass('TSettingForm')), SettingsForm);
        if Screensaver.GetParentHandle<>0 then begin
          SettingsForm.ParentWindow := Screensaver.GetParentHandle;
        end;
        SettingsForm.ShowModal;
      except // EClassNotFound
        TaskDialog('No options', 'This screen saver had no options that you can set.');
      end;
    end;
    smRun: begin
      if IsSingleInstance(SCREENSAVERKIT_MUTEX, true) then begin
        SetLength(MainForms, Screen.MonitorCount);
        try
          for i := 0 to High(MainForms) do begin
            Application.CreateForm(TFormClass(FindClass('TMainForm')), MainForms[i]);
            MainForms[i].Visible := True;
            MainForms[i].MonitorId := i;
            MainForms[i].BoundsRect := Screen.Monitors[i].BoundsRect;
          end;
          Application.Run;
        except // EClassNotFound
          Application.Terminate;
        end;
      end;
    end;
    smPassword: begin
    end;
  end;
end;

function GetScreensaverName: String;
begin
  result := ChangeFileExt(ExtractFileName(Application.ExeName), '');
end;

procedure TScreensaver.TaskDialog(const Title, Msg: string);
var
  TaskDialog: TTaskDialog;
  Button: TTaskDialogBaseButtonItem;
begin
  with TTaskDialog.Create(nil) do begin
    Caption := GetScreensaverName;
    Title := Title;
    Text := Msg;
    CommonButtons := [tcbOk];
    Execute;
  end;
end;

function TScreensaver.InvokeDebugDialog(): TModalResult;
begin
  result := mrCancel;

  with TTaskDialog.Create(nil) do begin
    Caption := GetScreensaverName;
    Title := 'Debug Mode';
    Text := 'Which feature of the screensaver do you want to test?';
    CommonButtons := [];
    with TTaskDialogButtonItem(Buttons.Add) do begin
      Caption := 'Main';
      CommandLinkHint := '';
      ModalResult := mrYes;
    end;
    with TTaskDialogButtonItem(Buttons.Add) do begin
      Caption := 'Settings';
      CommandLinkHint := '';
      ModalResult := mrNo;
    end;
    with TTaskDialogButtonItem(Buttons.Add) do begin
      Caption := 'Exit';
      CommandLinkHint := '';
      ModalResult := mrCancel;
    end;
    Flags := [tfUseCommandLinks];
    MainIcon := tdiError;
    if Execute then begin
      case ModalResult of
        mrYes: begin
          // Test main form
          result := ModalResult;
        end;
        mrNo: begin
          // Test settings form
          result := ModalResult;
        end;
        mrCancel: begin
          // Cancel
          result := ModalResult;
        end;
      end;
    end;
  end;
end;

{ TScreensaverSettingForm }

constructor TScreensaverSettingForm.Create(AOwner: TComponent);
begin
  inherited;
//  ParentWindow := Screensaver.GetParentHandle;
  BorderStyle := bsDialog;
end;

procedure TScreensaverSettingForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
//  Params.Style := Params.Style or WS_CHILD or WS_VISIBLE;
end;

{ TScreensaverMainForm }

constructor TScreensaverMainForm.Create(AOwner: TComponent);
var
  Dummy: Boolean;
begin
  inherited;

  // Screensaver mode
  BorderStyle := bsNone;
  WindowState := wsMaximized;

  if Screensaver.IsPreviewMode then begin
    // Hook into the small preview window
    ParentWindow := Screensaver.GetParentHandle;
  end else begin
    if IsPrimaryMonitor then begin
        // Initialize mouse coors
        Mouse.CursorPos := Point(-1, -1);

        // Enable mode
        SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, @Dummy, 0);
//        SetCapture(MainForm.Handle);
        ShowCursor(False);

        // Bring window to foreground
        SetForegroundWindow(Handle);
        SetActiveWindow(Handle);
        StoreMousePosition(); // Position stored for later mouse move checks
    end;
  end;

  if not assigned(OnShow) then OnShow := FormShow;
  if not assigned(OnClose) then OnClose := FormClose;
  if not assigned(OnResize) then OnResize := FormResize;
end;

procedure TScreensaverMainForm.CreateParams(var Params: TCreateParams);
var
  ExtendedStyle: Integer;
begin
  inherited;

  if Screensaver.IsPreviewMode then begin

  end;
end;

procedure TScreensaverMainForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  Dummy: Boolean;
begin
//  Action := caFree;

  if not Screensaver.IsPreviewMode then begin
    SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, @Dummy, 0);
    ReleaseCapture;
    ShowCursor(True);

    Application.Terminate;
  end;
end;

procedure TScreensaverMainForm.FormResize(Sender: TObject);
begin
  StoreMousePosition();

  // Re-fix screen bounds
  if not Screensaver.IsPreviewMode then begin
    Application.BringToFront;
    BoundsRect := Screen.Monitors[MonitorId].BoundsRect;
  end;

end;

procedure TScreensaverMainForm.FormShow(Sender: TObject);
begin
  if not Screensaver.IsPreviewMode then begin
    // Intercept messages
    Application.OnMessage := MsgHandler;
  end;
end;

function Distance(XPos, YPos, X, Y: Real): Real;
begin
  Result := sqrt(Power(XPos-X, 2) + Power(YPos-Y, 2));
end;

function TScreensaverMainForm.HasMousePositionChanged: Boolean;
begin
  result := Distance(
    InitialMousePosition.X,
    InitialMousePosition.Y,
    Mouse.CursorPos.X,
    Mouse.CursorPos.Y
  ) > 5.0;
end;

function TScreensaverMainForm.IsPrimaryMonitor: Boolean;
begin
  result := MonitorId = 0;
end;

procedure TScreensaverMainForm.MsgHandler(var Msg: TMsg; var Handled: Boolean);
begin
  if AllowShutdown then begin
    if (Msg.message=WM_MOUSEMOVE) then begin
      if HasMousePositionChanged then begin
        Handled := True;
        Close;
      end;
    end else if (Msg.message=WM_KEYUP) then begin
      Handled := True;
      Close;
    end else if (Msg.message=WM_KEYDOWN) then begin
      Handled := True;
      Close;
    end;
  end;
end;

procedure TScreensaverMainForm.StoreMousePosition;
begin
  InitialMousePosition := Mouse.CursorPos;
end;

{ CallSuperAttribute }

constructor CallSuperAttribute.Create;
begin

end;

procedure StartScreensaver;
var
  hWnd: THandle;
begin
  hWnd := GetDesktopWindow;
  SendMessage(hWnd, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
end;

initialization
  Screensaver := TScreensaver.Create(GetScreensaverName);
finalization
  Screensaver.Free;
end.
