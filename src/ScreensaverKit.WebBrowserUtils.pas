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
{ Contains an embedabble and kiosk like web browser class                      }
{                                                                              }
{ Unit owner:    Misel Krstovic                                                }
{ Last modified: March 2, 2019                                                 }
{                                                                              }
{******************************************************************************}

unit ScreensaverKit.WebBrowserUtils;

interface

uses
  MSHTML, SHDocVw, WinInet, IdIcmpClient, Types;

const
  // Local system has a valid connection to the Internet, but it might or might
  // not be currently connected.
  INTERNET_CONNECTION_CONFIGURED = $40;
  // Local system uses a local area network to connect to the Internet.
  INTERNET_CONNECTION_LAN = $02;
  // Local system uses a modem to connect to the Internet
  INTERNET_CONNECTION_MODEM = $01;
  // Local system is in offline mode.
  INTERNET_CONNECTION_OFFLINE = $20;
  // Local system uses a proxy server to connect to the Internet
  INTERNET_CONNECTION_PROXY = $04;
  // Local system has RAS installed.
  INTERNET_RAS_INSTALLED = $10;

  SCREENSAVERKIT_USER_AGENT = 'ScreensaverKit/1.0';
  SCREENSAVERKIT_PING_HOST = 'https://www.google.com/';

type
  TScreensaverWebBrowser = class(TWebBrowser)
    // TODO: Refactor TWebBrowser from example
    class function CheckInternetConnection: boolean;
  end;

implementation

class function TScreensaverWebBrowser.CheckInternetConnection: boolean;
var
  InetState: DWORD;
  hHttpSession, hReqUrl: HInternet;
begin
  Result := InternetGetConnectedState(@InetState, 0);
  if (Result (*and (InetState and INTERNET_CONNECTION_CONFIGURED = INTERNET_CONNECTION_CONFIGURED) *)) then begin
    // So far we ONLY know there's a valid connection. See if we can grab some
    // known URL ...
    hHttpSession := InternetOpen(
      PChar(SCREENSAVERKIT_USER_AGENT),
      INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0
    );
    try
      hReqUrl := InternetOpenURL(hHttpSession, PChar(SCREENSAVERKIT_PING_HOST), nil, 0, 0, 0);
      Result := hReqUrl <> nil;
      InternetCloseHandle(hReqUrl);
    finally
      InternetCloseHandle(hHttpSession);
    end;
  end else begin
    if (InetState and INTERNET_CONNECTION_OFFLINE = INTERNET_CONNECTION_OFFLINE) then
      Result := False; // We know for sure we are offline.
  end;
end;

end.
