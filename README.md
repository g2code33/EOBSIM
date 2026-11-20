# EOSIM — Electronic Organ Bath Simulation

EOBSIM is the Delphi project and executable name. EOSIM is the application
name. The application simulates organ-bath experiments with guinea pig ileum,
chick biventer, rabbit arterial ring and rabbit jejunum preparations, including
drug additions, stimulation and chart recording.

## Status and licensing

This is an **unverified modernization in progress**, not a tested release.
Delphi, Windows and Inno Setup were not available in the development
sandbox; neither platform, the simulation, nor the installer has been built
or tested. Win64 in particular needs validation of both the application and
its third-party components. The interface has a new title and font, but is
not a full UI redesign.

The upstream source does not appear to have a license granting redistribution
or modification rights. See [third-party notices](THIRD_PARTY_NOTICES.md)
and obtain necessary permissions before distributing this work.

## Build on Windows

You need Delphi 11 Alexandria or 12 Athens with VCL. The project configures
Win32 and Win64, but the legacy component package and both targets still need
verification with your compiler.

1. Obtain SESComponentsXE separately from
   https://github.com/johndempster/SESComponentsXE at revision
   `6ab766082fd2ccf42dcc55e4ac6fe3b1ccb7cc37`. Review its terms.
2. Build and install its **Win32 design-time** package in the IDE, following
   its README. The IDE may offer to upgrade the package project. Add the
   component source folder to the Delphi library path for each target. The
   application uses `ScopeDisplay`, `ValidatedEdit` and `HTMLLabel`; the
   design-only package itself is not linked into the executable.
3. Set the environment variable `SESCOMPONENTS_DIR` to the component source
   folder before launching Delphi (or configure an equivalent project search
   path). Open `EOBSIM.dproj`, select Win32 or Win64 and build. Build output
   is configured for `Win32\Release`, `Win64\Release`, etc.
4. Copy `EOSIM-help.html` beside the executable. Test creating, saving and
   reopening experiments, chart controls, printing and help before use.

If the component package fails to build for your Delphi version, the
component dependency requires additional porting; installation alone is not
a guarantee of compatibility. In particular, the upstream ScopeDisplay unit
still contains 32-bit pointer casts that must be audited and corrected for
Win64. SESComponentsXE has its own licensing status.

## Installer

With Inno Setup 6 installed and a Release executable built, run from the
repository directory, for example:

```bat
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DBuildDir=Win64\Release EOBSIM.iss
```

Use `Win32\Release` for a 32-bit build. The installer includes the executable
and HTML help; file association is optional. The installer has not been tested.

## Experiment files

New files use `.EOB`. The underlying format was inherited rather than
redesigned; changing the extension alone does not make old files incompatible.
Older experiment files may be opened by selecting or renaming them with the
`.EOB` extension, but compatibility has **not** been tested. Keep backups.

## Files

- `EOBSIM.dpr`, `EOBSIM.dproj`: application and Delphi project.
- `EOBSIMMain.pas/.dfm`: simulation and main window.
- `NewExperimentUnit`, `PrintUnit`, `Shared`: supporting units.
- `EOSIM-help.html`: concise local help.
- `EOBSIM.iss`: installer script.
- `THIRD_PARTY_NOTICES.md`: source and rights information.
