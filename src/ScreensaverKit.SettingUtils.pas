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
{ Contains a simple registry based settings class                              }
{                                                                              }
{ Unit owner:    Misel Krstovic                                                }
{ Last modified: October 10, 2017                                              }
{                                                                              }
{******************************************************************************}

unit ScreensaverKit.SettingUtils;

interface

uses
  Windows, SysUtils, Registry, Classes, UiTypes;

type
  TScreensaverSettings = class
    _CriticalSection : TMultiReadExclusiveWriteSynchronizer;
    _Conf : TRegistry;
    _Key : String;
    _Create : Boolean;
  public
    constructor Create(Key : String);
    destructor Destroy; override;

    procedure GetKeyNames(Strings: TStrings);
    procedure GetValueNames(Strings: TStrings);

    function ReadBool(const Name: String; const Default: Boolean): Boolean;
    procedure WriteBool(const Name: String; Value: Boolean);
    function ReadString(const Name: String; const Default: String): String;
    procedure WriteString(const Name, Value: String);
    function ReadColor(const Name: String; const Default: TColor): TColor;
    procedure WriteColor(const Name: String; const Value: TColor);
    function ReadInteger(const Name: String; const Default: Integer): Integer;
    procedure WriteInteger(const Name: String; Value: Integer);
    function DeleteKey(const Key : String): Boolean;
    function SetKey(const Key : String; CanCreate : Boolean): Boolean; // todo: return properly
  end;

implementation

uses
  Graphics;

{ TScreensaverOptions }

// Class constructors and destructors

constructor TScreensaverSettings.Create(Key : String);
begin
  _CriticalSection := TMultiReadExclusiveWriteSynchronizer.Create;

  _Conf := TRegistry.Create(KEY_ALL_ACCESS); // KEY_READ;
  _Conf.RootKey := HKEY_CURRENT_USER;

  _Create := True;
  _Key := Key;
end;

destructor TScreensaverSettings.Destroy;
begin
  _Conf.Free;
  _CriticalSection.Free;

  inherited;
end;

// Class methods

function TScreensaverSettings.DeleteKey(const Key: String): Boolean;
begin
  _CriticalSection.BeginWrite;
  try
    result := _Conf.DeleteKey(Key);
  finally
    _CriticalSection.EndWrite;
  end;
end;

procedure TScreensaverSettings.GetKeyNames(Strings: TStrings);
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      _Conf.GetKeyNames(Strings);
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

procedure TScreensaverSettings.GetValueNames(Strings: TStrings);
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      _Conf.GetValueNames(Strings);
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

function TScreensaverSettings.ReadBool(const Name: String; const Default: Boolean): Boolean;
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      try
        result := _Conf.ReadBool(Name);
      except
        result := Default;
      end;
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

function TScreensaverSettings.ReadInteger(const Name: String;
  const Default: Integer): Integer;
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      try
        result := _Conf.ReadInteger(Name);
      except
        result := Default;
      end;
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

function TScreensaverSettings.ReadString(const Name: String; const Default: String): String;
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      try
        result := _Conf.ReadString(Name);
      except
        result := Default;
      end;

      if length(result)=0 then result := Default;
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

function TScreensaverSettings.ReadColor(const Name: String; const Default: TColor): TColor;
begin
  result := StringToColor(trim(ReadString(name, ColorToString(Default))));
end;

function TScreensaverSettings.SetKey(const Key: String;
  CanCreate: Boolean): Boolean;
begin
  _CriticalSection.BeginWrite;
  try
    _Key := Key;
    _Create := CanCreate;

    result := true; // Dummy result, since actual thing is done elsewhere
  finally
    _CriticalSection.EndWrite;
  end;
end;

procedure TScreensaverSettings.WriteBool(const Name: string; Value: Boolean);
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      _Conf.WriteBool(Name, Value);
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

procedure TScreensaverSettings.WriteInteger(const Name: String; Value: Integer);
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      _Conf.WriteInteger(Name, Value);
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

procedure TScreensaverSettings.WriteString(const Name, Value: String);
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      _Conf.WriteString(Name, Value);
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

procedure TScreensaverSettings.WriteColor(const Name: String; const Value: TColor);
begin
  _CriticalSection.BeginWrite;
  try
    _Conf.OpenKey(_Key, _Create);
    try
      _Conf.WriteString(Name, ColorToString(Value));
    finally
      _Conf.CloseKey;
    end;
  finally
    _CriticalSection.EndWrite;
  end;
end;

end.
