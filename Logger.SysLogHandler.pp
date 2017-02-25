{*******************************************************}

{   Renegade BBS                                        }

{   Copyright (c) 1990-2013 The Renegade Dev Team       }
{   Copyleft  (ↄ) 2016-2017 Renegade BBS                }

{   This file is part of Renegade BBS                   }

{   Renegade is free software: you can redistribute it  }
{   and/or modify it under the terms of the GNU General }
{   Public License as published by the Free Software    }
{   Foundation, either version 3 of the License, or     }
{   (at your option) any later version.                 }

{   Renegade is distributed in the hope that it will be }
{   useful, but WITHOUT ANY WARRANTY; without even the  }
{   implied warranty of MERCHANTABILITY or FITNESS FOR  }
{   A PARTICULAR PURPOSE.  See the GNU General Public   }
{   License for more details.                           }

{   You should have received a copy of the GNU General  }
{   Public License along with Renegade.  If not, see    }
{   <http://www.gnu.org/licenses/>.                     }

{*******************************************************}
{   _______                                  __         }
{  |   _   .-----.-----.-----.-----.---.-.--|  .-----.  }
{  |.  l   |  -__|     |  -__|  _  |  _  |  _  |  -__|  }
{  |.  _   |_____|__|__|_____|___  |___._|_____|_____|  }
{  |:  |   |                 |_____|                    }
{  |::.|:. |                                            }
{  `--- ---'                                            }
{*******************************************************}
{$mode objfpc}
{$interfaces corba}
{$linklib c}
{$codepage utf8}
{$h+}

unit Logger.SysLogHandler;

interface

uses
  Classes,
  FPJson,
  Logger.HandlerInterface;

const
  LOG_PID = $01;  // log the pid with each message
  LOG_CONS = $02;  // log on the console if errors in sending
  LOG_ODELAY = $04;  // delay open until first syslog() (default)
  LOG_NDELAY = $08;  // don't delay open
  LOG_NOWAIT = $10;  // don't wait for console forks; (DEPRECATED)
  LOG_PERROR = $20;  // log to stderr as well

  LOG_KERN = 0 shl 3;  // kernel messages
  LOG_USER = 1 shl 3;  // random user-level messages
  LOG_MAIL = 2 shl 3;  // mail system
  LOG_DAEMON = 3 shl 3;  // system daemons
  LOG_AUTH = 4 shl 3;  // security/authorization messages
  LOG_SYSLOG = 5 shl 3;  // messages generated internally by syslogd
  LOG_LPR = 6 shl 3;  // line printer subsystem
  LOG_NEWS = 7 shl 3;  // network news subsystem
  LOG_UUCP = 8 shl 3;  // UUCP subsystem
  LOG_CRON = 9 shl 3;  // clock daemon
  LOG_AUTHPRIV = 10 shl 3; // security/authorization messages (private)

var
  UnixFacility: longint;

type
  SysLogHandler = class(TObject, LoggingHandlerInterface)
  private
    FUnixFacility: longint;
    procedure SetFacility(const UnixFacility: longint);
  public
    constructor Create(const LoggingFacility: longint);

    function Open(Identifier: UTF8String): boolean;
    function Close(): boolean;
    function Write(const LogData: UTF8String): boolean;
  published
    property UnixFacility: longint read FUnixFacility write SetFacility;
  end;

procedure closelog; cdecl; external;
procedure openlog(__ident: PChar; __option: longint; __facilit: longint); cdecl; external;
function setlogmask(__mask: longint): longint; cdecl; external;
procedure syslog(__pri: longint; __fmt: PChar; args: array of const); cdecl; external;

implementation

constructor SysLogHandler.Create(const LoggingFacility: longint);
begin
  FUnixFacility := LoggingFacility;
end;

procedure SysLogHandler.SetFacility(const UnixFacility: longint);
begin
  FUnixFacility := UnixFacility;
end;

function SysLogHandler.Open(Identifier: UTF8String): boolean;
var
  SysLogIdentifier: PAnsiChar;
begin
  SysLogIdentifier := PAnsiChar(Identifier);
  openlog(SysLogIdentifier, LOG_PID xor LOG_CONS xor LOG_NDELAY, FUnixFacility);
  Result := True;
end;

function SysLogHandler.Close(): boolean;
begin
  closelog;
  Result := True;
end;

function SysLogHandler.Write(const LogData: UTF8String): boolean;
var
  SysLogData: PAnsiChar;
begin
  SysLogData := PAnsiChar(LogData);
  syslog(FUnixFacility, SysLogData, []);
  Result := True;
end;

end.
