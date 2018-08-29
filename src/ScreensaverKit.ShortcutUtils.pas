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
{ The Original Code is ScreensaverKit.SettingUtils.pas.                        }
{                                                                              }
{ Contains desktop shortcut creation functions                                 }
{                                                                              }
{ Unit owner:    Misel Krstovic                                                }
{ Last modified: October 11, 2017                                              }
{                                                                              }
{******************************************************************************}

unit ScreensaverKit.ShortcutUtils;

interface

  function CreateDesktopShellLink(const TargetName: string): Boolean;

implementation

uses
  ShlObj, ComObj, ActiveX, SysUtils, Windows, Forms;

const
  MODIFIER_ALT = MOD_ALT shl 8;
  MODIFIER_CTRL = MOD_CONTROL shl 8;
  MODIFIER_SHIFT = MOD_SHIFT shl 8;

function GetDesktopFolder: string;
var
  PIDList: PItemIDList;
  Buffer: array [0..MAX_PATH-1] of Char;
begin
  Result := '';
  SHGetSpecialFolderLocation(Application.Handle, CSIDL_DESKTOP, PIDList);
  if Assigned(PIDList) then
    if SHGetPathFromIDList(PIDList, Buffer) then
      Result := Buffer;
end;

function CreateDesktopShellLink(const TargetName: string): Boolean;
var
  IObject: IUnknown;
  ISLink: IShellLink;
  IPFile: IPersistFile;
  PIDL: PItemIDList;
  LinkName: string;
  InFolder: array [0..MAX_PATH-1] of Char;
  Hotkey: Word;
begin
  Result := False;

  IObject := CreateComObject(CLSID_ShellLink);
  ISLink := IObject as IShellLink;
  IPFile := IObject as IPersistFile;

  Hotkey := MODIFIER_CTRL + MODIFIER_ALT + Ord('l');

  with ISLink do
  begin
    SetHotkey($064C);
    SetDescription('Screensaver shortcut');
    SetPath(PChar(TargetName));
    SetWorkingDirectory(PChar(ExtractFilePath(TargetName)));
  end;

  SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL);
  SHGetPathFromIDList(PIDL, InFolder) ;

  LinkName := IncludeTrailingBackslash(GetDesktopFolder);
  LinkName := LinkName + ChangeFileExt(ExtractFileName(TargetName), '') + '.lnk';

  if not FileExists(LinkName) then
    if IPFile.Save(PWideChar(LinkName), False) = S_OK then
      Result := True;
end;

end.
