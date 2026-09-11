# Copy with RAW

A Windows shell extension that adds right-click context menu options to copy JPEG and RAW photo files together — including XMP sidecar files.

Works with **FastStone Image Viewer** as an external program too.

---

## Features

- **Select JPEGs → copies matching RAW files automatically**
- **Select RAW files → copies matching JPEG files automatically**
- Supports all major RAW formats: `.nef`, `.cr2`, `.cr3`, `.arw`, `.dng`, `.raf`, `.orf`, `.rw2`, `.nrw`, `.pef`, `.srw`, `.srf`, `.sr2`, `.crw`
- Copies associated **XMP sidecar** files
- Smart name matching — `_BIR3454JPEG 12.jpg` automatically finds `_BIR3454.nef`
- Modern Windows folder picker (Explorer-style, supports pasting paths)
- **Three right-click options:**
  | Menu Item | Behaviour |
  |---|---|
  | **Copy with RAW / JPEG** | Opens folder picker, then optionally creates a subfolder |
  | **Copy to Selected WL** | Copies straight to your configured Wildlife folder, asks for optional subfolder |
  | **Copy to WL (Original Folder)** | One-click — copies to Wildlife folder using the source folder's name as subfolder |
- Works silently — no flashing console windows
- Multi-select support — select hundreds of files at once

---

## Installation

### Option 1 — Download the installer (recommended)

1. Go to the [Releases](../../releases) page.
2. Download `CopyWithRAW-Setup-vX.X.X.exe`.
3. Run it and follow the wizard.
   - You will be asked for your **Wildlife destination folder** (e.g. `D:\Selected\Wildlife`).
   - You will be asked for a **default folder picker location** (e.g. `D:\Selected`).
4. Done! Right-click any `.jpg`, `.jpeg`, or RAW file to use the new menu options.

### Option 2 — Build from source

Requirements: [Inno Setup 6](https://jrsoftware.org/isdl.php) installed.

```powershell
git clone https://github.com/pureeye108/CopyWithRaw.git
cd CopyWithRaw
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\setup.iss
# Installer is created in: dist\CopyWithRAW-Setup-v1.0.0.exe
```

---

## FastStone Image Viewer integration

After installing, you can link the tool into FastStone for keyboard-shortcut access:

1. Open FastStone → press **F12** → go to the **Programs** tab.
2. Click **Add** and create entries pointing to the scripts in your install folder (default: `C:\Program Files\CopyWithRAW\`):

| Name | Command |
|---|---|
| Copy with RAW (pick folder) | `wscript.exe "C:\Program Files\CopyWithRAW\RunHidden.vbs" "%src%" "PICKER:" "SkipSubfolderPrompt" "OpenDestination"` |
| Copy to WL | `wscript.exe "C:\Program Files\CopyWithRAW\RunHidden.vbs" "%src%" "WL:"` |
| Copy to WL (Auto folder) | `wscript.exe "C:\Program Files\CopyWithRAW\RunHidden.vbs" "%src%" "WL:" "AutoSubfolder"` |

3. Assign hotkeys (e.g. `Alt+1`, `Alt+2`, `Alt+3`).

---

## How the file matching works

The tool uses **prefix matching** to pair JPEGs with RAWs:

- If you select `_BIR3454JPEG 12.jpg`, it looks for any RAW file whose name is a prefix of `_BIR3454JPEG 12` — finding `_BIR3454.nef`.
- If you select `_BIR3454.nef`, it looks for any JPEG whose name **starts with** `_BIR3454` — finding `_BIR3454JPEG 12.jpg`.
- XMP sidecars (e.g. `_BIR3454.nef.xmp` or `_BIR3454.xmp`) are also copied automatically.

---

## Uninstalling

Use **Add or Remove Programs** in Windows Settings, or run the uninstaller from the install folder.

---

## Project structure

```
copy-with-raw/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions: auto-build installer on push/release
├── src/
│   ├── CopyWithRAW.ps1        # Main PowerShell logic
│   └── RunHidden.vbs          # Silent launcher (no flashing console)
├── installer/
│   └── setup.iss              # Inno Setup script → produces .exe installer
├── dist/                      # (git-ignored) Built installer output
├── LICENSE
└── README.md
```

---

## Building the installer on GitHub

Push a tag to trigger an automatic release build:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will compile `setup.iss` using Inno Setup and attach the `.exe` to the GitHub Release automatically.

---

## License

MIT — see [LICENSE](LICENSE).
