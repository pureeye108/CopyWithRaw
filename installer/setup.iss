; ============================================================
; Copy with RAW - Inno Setup Script
; Builds a single-click Windows installer (.exe)
; ============================================================

#define MyAppName      "Copy with RAW"
#define MyAppVersion   "1.0.0"
#define MyAppPublisher "Photography Tools"
#define MyAppURL       "https://github.com/pureeye108/CopyWithRaw"
#define MyAppID        "{B3F4A2C1-7E8D-4F9A-B2C3-D4E5F6A7B8C9}"

[Setup]
AppId={{#MyAppID}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\CopyWithRAW
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
OutputDir=..\dist
OutputBaseFilename=CopyWithRAW-Setup-v{#MyAppVersion}
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\RunHidden.vbs

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\src\CopyWithRAW.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\src\RunHidden.vbs";   DestDir: "{app}"; Flags: ignoreversion

[Registry]
; --- Store user config ---
Root: HKLM; Subkey: "SOFTWARE\CopyWithRAW"; ValueType: string; ValueName: "WLDestination";     ValueData: "{code:GetWLDest}";   Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM; Subkey: "SOFTWARE\CopyWithRAW"; ValueType: string; ValueName: "DefaultPickerFolder"; ValueData: "{code:GetPickerDest}"; Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM; Subkey: "SOFTWARE\CopyWithRAW"; ValueType: string; ValueName: "InstallPath";         ValueData: "{app}";               Flags: uninsdeletekey

; ---------------------------------------------------------------
; JPEG  (.jpg)
; ---------------------------------------------------------------
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyWithRAW";           ValueType: string; ValueName: "";                 ValueData: "Copy with RAW";        Flags: uninsdeletekey
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyWithRAW";           ValueType: string; ValueName: "Icon";             ValueData: "imageres.dll,-5322"
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyWithRAW";           ValueType: string; ValueName: "MultiSelectModel"; ValueData: "Player"
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyWithRAW\command";   ValueType: string; ValueName: "";                 ValueData: "wscript.exe ""{app}\RunHidden.vbs"" ""%1"""
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWL";              ValueType: string; ValueName: "";                 ValueData: "Copy to Selected WL";  Flags: uninsdeletekey
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWL";              ValueType: string; ValueName: "Icon";             ValueData: "imageres.dll,-5322"
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWL";              ValueType: string; ValueName: "MultiSelectModel"; ValueData: "Player"
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWL\command";      ValueType: string; ValueName: "";                 ValueData: "wscript.exe ""{app}\RunHidden.vbs"" ""%1"" ""WL:"""
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWLAuto";          ValueType: string; ValueName: "";                 ValueData: "Copy to WL (Original Folder)"; Flags: uninsdeletekey
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWLAuto";          ValueType: string; ValueName: "Icon";             ValueData: "imageres.dll,-5322"
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWLAuto";          ValueType: string; ValueName: "MultiSelectModel"; ValueData: "Player"
Root: HKCR; Subkey: "SystemFileAssociations\.jpg\shell\CopyToWLAuto\command";  ValueType: string; ValueName: "";                 ValueData: "wscript.exe ""{app}\RunHidden.vbs"" ""%1"" ""WL:"" ""AutoSubfolder"""

; ---------------------------------------------------------------
; JPEG  (.jpeg)
; ---------------------------------------------------------------
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyWithRAW";          ValueType: string; ValueName: "";                 ValueData: "Copy with RAW";        Flags: uninsdeletekey
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyWithRAW";          ValueType: string; ValueName: "Icon";             ValueData: "imageres.dll,-5322"
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyWithRAW";          ValueType: string; ValueName: "MultiSelectModel"; ValueData: "Player"
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyWithRAW\command";  ValueType: string; ValueName: "";                 ValueData: "wscript.exe ""{app}\RunHidden.vbs"" ""%1"""
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWL";             ValueType: string; ValueName: "";                 ValueData: "Copy to Selected WL";  Flags: uninsdeletekey
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWL";             ValueType: string; ValueName: "Icon";             ValueData: "imageres.dll,-5322"
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWL";             ValueType: string; ValueName: "MultiSelectModel"; ValueData: "Player"
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWL\command";     ValueType: string; ValueName: "";                 ValueData: "wscript.exe ""{app}\RunHidden.vbs"" ""%1"" ""WL:"""
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWLAuto";         ValueType: string; ValueName: "";                 ValueData: "Copy to WL (Original Folder)"; Flags: uninsdeletekey
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWLAuto";         ValueType: string; ValueName: "Icon";             ValueData: "imageres.dll,-5322"
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWLAuto";         ValueType: string; ValueName: "MultiSelectModel"; ValueData: "Player"
Root: HKCR; Subkey: "SystemFileAssociations\.jpeg\shell\CopyToWLAuto\command"; ValueType: string; ValueName: "";                 ValueData: "wscript.exe ""{app}\RunHidden.vbs"" ""%1"" ""WL:"" ""AutoSubfolder"""

; ---------------------------------------------------------------
; RAW formats (all share the same pattern via Pascal code below)
; ---------------------------------------------------------------

[Code]
// ---------------------------------------------------------------
// Custom wizard pages: WL destination + default picker folder
// ---------------------------------------------------------------
var
  WLDestPage:    TInputDirWizardPage;
  PickerDestPage: TInputDirWizardPage;

function GetWLDest(Param: String): String;
begin
  Result := WLDestPage.Values[0];
end;

function GetPickerDest(Param: String): String;
begin
  Result := PickerDestPage.Values[0];
end;

procedure InitializeWizard;
begin
  WLDestPage := CreateInputDirPage(wpSelectDir,
    'Wildlife Destination Folder',
    'Where should "Copy to Selected WL" copy your files?',
    'This is the base folder for "Copy to Selected WL" and "Copy to WL (Original Folder)". ' +
    'A subfolder may be created inside this location.',
    False, '');
  WLDestPage.Add('Wildlife destination:');
  WLDestPage.Values[0] := 'D:\Selected\Wildlife';

  PickerDestPage := CreateInputDirPage(WLDestPage.ID,
    'Default Folder Picker Location',
    'Where should the "Copy with RAW" folder picker open by default?',
    'When you choose "Copy with RAW", the folder selection dialog will open here. ' +
    'Leave blank to open at the last used location.',
    False, '');
  PickerDestPage.Add('Default picker folder:');
  PickerDestPage.Values[0] := 'D:\Selected';
end;

// ---------------------------------------------------------------
// Register RAW context menu entries after install
// ---------------------------------------------------------------
const
  RAW_EXTS = 'nef|cr2|cr3|arw|dng|raf|orf|rw2|nrw|pef|srw|srf|sr2|crw';

procedure RegisterRAWExtensions;
var
  Exts: TStringList;
  i: Integer;
  Ext, SubkeyBase, VbsPath, CmdBase: String;
begin
  VbsPath := ExpandConstant('{app}\RunHidden.vbs');
  CmdBase := 'wscript.exe "' + VbsPath + '" "%1"';

  Exts := TStringList.Create;
  Exts.Delimiter := '|';
  Exts.DelimitedText := RAW_EXTS;

  for i := 0 to Exts.Count - 1 do
  begin
    Ext := Exts[i];
    SubkeyBase := 'SystemFileAssociations\.' + Ext + '\shell\';

    // Copy with JPEG
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyWithRAW',          '',                 'Copy with JPEG');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyWithRAW',          'Icon',             'imageres.dll,-5322');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyWithRAW',          'MultiSelectModel', 'Player');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyWithRAW\command',  '',                 CmdBase);

    // Copy to Selected WL
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWL',             '',                 'Copy to Selected WL');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWL',             'Icon',             'imageres.dll,-5322');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWL',             'MultiSelectModel', 'Player');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWL\command',     '',                 CmdBase + ' "WL:"');

    // Copy to WL (Original Folder)
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWLAuto',         '',                 'Copy to WL (Original Folder)');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWLAuto',         'Icon',             'imageres.dll,-5322');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWLAuto',         'MultiSelectModel', 'Player');
    RegWriteStringValue(HKCR, SubkeyBase + 'CopyToWLAuto\command', '',                 CmdBase + ' "WL:" "AutoSubfolder"');
  end;

  Exts.Free;
end;

procedure UnregisterRAWExtensions;
var
  Exts: TStringList;
  i: Integer;
  Ext, SubkeyBase: String;
begin
  Exts := TStringList.Create;
  Exts.Delimiter := '|';
  Exts.DelimitedText := RAW_EXTS;

  for i := 0 to Exts.Count - 1 do
  begin
    Ext := Exts[i];
    SubkeyBase := 'SystemFileAssociations\.' + Ext + '\shell\';
    RegDeleteKeyIncludingSubkeys(HKCR, SubkeyBase + 'CopyWithRAW');
    RegDeleteKeyIncludingSubkeys(HKCR, SubkeyBase + 'CopyToWL');
    RegDeleteKeyIncludingSubkeys(HKCR, SubkeyBase + 'CopyToWLAuto');
  end;

  Exts.Free;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    RegisterRAWExtensions;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
    UnregisterRAWExtensions;
end;
