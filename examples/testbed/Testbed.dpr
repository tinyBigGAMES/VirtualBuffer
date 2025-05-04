{===============================================================================
 __   ___     _             _ ___       __  __
 \ \ / (_)_ _| |_ _  _ __ _| | _ )_  _ / _|/ _|___ _ _™
  \ V /| | '_|  _| || / _` | | _ \ || |  _|  _/ -_) '_|
   \_/ |_|_|  \__|\_,_\__,_|_|___/\_,_|_| |_| \___|_|
 Thread-Safe, Generic Virtual Memory Buffer for Delphi

 Copyright © 2025-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/VirtualBuffer

 See LICENSE file for license information
===============================================================================}

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  VirtualBuffer in '..\..\src\VirtualBuffer.pas',
  UTestbed in 'UTestbed.pas';

begin
  RunTests();
end.
