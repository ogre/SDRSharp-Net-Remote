; SDRSharp Net Remote
;
; http://eartoearoak.com/software/sdrsharp-net-remote
;
; Copyright 2014 - 2017 Al Brown
;
; A network remote control plugin for SDRSharp
;
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, or (at your option)
; any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

#define MyAppName "SDRSharp Net Remote"
#define MyAppVersion GetFileVersion(AddBackslash(SourcePath) + "x86\SDRSharp.NetRemote.dll")
#define MyAppPublisher "Al Brown"
#define MyAppURL "http://eartoearoak.com/software/sdrsharp-net-remote"

[Setup]
AppId={{9B6C377F-1560-4441-8602-78CECC537F07}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultGroupName={#MyAppName}
DefaultDirName={pf}\SDRSharp
AlwaysShowDirOnReadyPage=yes
LicenseFile=license.txt
InfoBeforeFile=help.txt
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes
EnableDirDoesntExistWarning=True
DirExistsWarning=no
DisableProgramGroupPage=auto
MinVersion=0,5.01sp3
AppendDefaultDirName=False
UsePreviousAppDir=False

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "x86\SDRSharp.NetRemote.dll"; DestDir: "{app}"; Flags: ignoreversion; Check: not Install64
Source: "x64\SDRSharp.NetRemote.dll"; DestDir: "{app}"; Flags: ignoreversion; Check: Install64

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[ThirdParty]
UseRelativePaths=True

[Messages]
SelectDirLabel3=Please select the SDR# installation folder

[Code]
var
  PlatformPage: TInputOptionWizardPage;

procedure InitializeWizard;
begin
  PlatformPage := CreateInputOptionPage(wpSelectDir,
    'Platform Type', '32 or 64 bits',
    'This plugin supports the 32 or 64 bit versions of SDRSharp.' + #13#10 + #13#10 + 'Select the version you use, if you are unsure it''s probably 32 bit.',
    True, False);
    PlatformPage.Add('32 bit (Default)');
    PlatformPage.Add('64 bit');
    PlatformPage.Values[0] := True;
end;

function Install64(): Boolean;
begin
  Result := not PlatformPage.Values[0];
end;

procedure Error(Message: String);
begin
  MsgBox('An error occured!' + #13#10 + Message, mbError, MB_OK);
end;

function XMLName(): String;
begin
  result := ExpandConstant('{app}\Plugins.xml')
end;

function XMLLoad(): Variant;
var
  Filename: String;
  XMLDocument: Variant;
begin
  Filename := XMLName();
  FileCopy(Filename, Filename + '.bak', False);
  XMLDocument := CreateOleObject('Msxml2.DOMDocument.6.0');
  XMLDocument.async := False;
  XMLDocument.load(Filename);
  if XMLDocument.parseError.errorCode <> 0 then
      MsgBox(ExpandConstant('SDRSharp was not found in {app}'), mbError, MB_OK);
  result := XMLDocument;
end;

procedure XMLSave(XMLDocument: Variant);
var
  Filename: String;
begin
  Filename := XMLName();
  XMLDocument.save(Filename);
end;

procedure AddXML();
var
  XMLDocument: Variant; 
  XMLNode: Variant;
  XMLNodeNew: Variant; 
begin
  try
    XMLDocument := XMLLoad();
    if (XMLDocument.parseError.errorCode = 0) then
    begin
      XMLNode := XMLDocument.selectSingleNode('sharpPlugins');
      XMLNodeNew := XMLDocument.createNode(1, 'add', '');
      XMLNodeNew.setAttribute('key', 'Net Remote');
      XMLNodeNew.setAttribute('value','SDRSharp.NetRemote.NetRemotePlugin,SDRSharp.NetRemote');
      XMLNode.appendChild(XMLNodeNew)
      XMLSave(XMLDocument);
    end;
  except
    Error(GetExceptionMessage);
  end;
end;

procedure DelXML();
var
  XMLDocument: Variant; 
  XMLNode: Variant;
begin
  try
    XMLDocument := XMLLoad();
    if XMLDocument.parseError.errorCode = 0 then
    begin
      XMLNode := XMLDocument.selectSingleNode('/sharpPlugins/add[@key="Net Remote"]');
      if not VarIsNull(XMLNode) then
      begin
        XMLNode.parentNode.removeChild(XMLNode);
        XMLSave(XMLDocument);
      end;
    end;
  except
    {Error(GetExceptionMessage);} {VarIsNull(XMLNode) fails}
  end;
end;

procedure CurStepChanged(Step: TSetupStep);
begin
  if (Step = ssPostInstall) then
  begin
    DelXML();
    AddXML();
  end;
end;

procedure CurUninstallStepChanged(Step: TUninstallStep);
begin
  if (Step = usUninstall) then
    DelXML();   
end;
