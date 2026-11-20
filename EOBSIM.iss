; Compile with ISCC /DBuildDir="Win64\Release" EOBSIM.iss
; Set BuildDir to the directory containing the chosen EOBSIM.exe.
#ifndef BuildDir
  #define BuildDir "Win32\Release"
#endif
#define MyAppName "EOSIM - Electronic Organ Bath Simulation"
#define MyAppVersion "1.0.0"

[Setup]
AppId={{8CFD5D7B-F08C-49D4-9E4E-412749D9E547}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={autopf}\EOSIM
DefaultGroupName=EOSIM
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=EOBSIM-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile=EOBSIM_Icon.ico
UninstallDisplayIcon={app}\EOBSIM.exe
ChangesAssociations=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "associate"; Description: "Associate .EOB experiment files with EOSIM"; Flags: unchecked

[Files]
Source: "{#BuildDir}\EOBSIM.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "EOSIM-help.html"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\EOSIM"; Filename: "{app}\EOBSIM.exe"
Name: "{autodesktop}\EOSIM"; Filename: "{app}\EOBSIM.exe"; Tasks: desktopicon

[Registry]
Root: HKA; Subkey: "Software\Classes\.eob\OpenWithProgids"; ValueType: string; ValueName: "EOSIM.Experiment"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associate
Root: HKA; Subkey: "Software\Classes\EOSIM.Experiment"; ValueType: string; ValueData: "EOSIM Experiment"; Flags: uninsdeletekey; Tasks: associate
Root: HKA; Subkey: "Software\Classes\EOSIM.Experiment\DefaultIcon"; ValueType: string; ValueData: "{app}\EOBSIM.exe,0"; Tasks: associate
Root: HKA; Subkey: "Software\Classes\EOSIM.Experiment\shell\open\command"; ValueType: string; ValueData: """{app}\EOBSIM.exe"" ""%1"""; Tasks: associate

[Run]
Filename: "{app}\EOBSIM.exe"; Description: "{cm:LaunchProgram,EOSIM}"; Flags: nowait postinstall skipifsilent
