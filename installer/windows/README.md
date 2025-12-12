# Windows Installer Build Instructions

## Requirements

1. **NSIS (Nullsoft Scriptable Install System)**
   - Download from: https://nsis.sourceforge.io/
   - Install NSIS 3.x or later

## Building the Installer

### Method 1: Using NSIS GUI

1. Right-click on `install.nsi`
2. Select "Compile NSIS Script"
3. The installer will be created as `ArchitectHelper_Setup_v1.0.exe`

### Method 2: Using Command Line

```bash
makensis install.nsi
```

## Installation Process

The installer will:

1. **Install Files:**
   - LISP utilities to `%APPDATA%\Autodesk\ApplicationPlugins\ArchitectHelper\`
   - Excel templates
   - Documentation

2. **Configure AutoCAD:**
   - Add support path for LISP files
   - Install acad.lsp startup script
   - Configure auto-load settings

3. **Create Shortcuts:**
   - Start Menu folder with:
     - Link to installation folder
     - User guide
     - Uninstaller

## Manual Installation (Alternative)

If you prefer manual installation:

1. **Copy Files:**
   ```
   Copy src/lisp/* to [AutoCAD Support Folder]/architect-helper/
   ```

2. **Add to Support Path:**
   - In AutoCAD: Tools → Options → Files → Support File Search Path
   - Add: Path to architect-helper folder

3. **Edit acad.lsp:**
   - Location: `%APPDATA%\Autodesk\UserDataCache\[AutoCAD Version]\AutoCAD\acad.lsp`
   - Add this line:
     ```lisp
     (if (findfile "architect-helper/autoload/acad.lsp")
       (load "architect-helper/autoload/acad.lsp")
     )
     ```

4. **Restart AutoCAD**

## Uninstallation

- Use Windows "Add or Remove Programs"
- Or run the uninstaller from Start Menu → Architect Helper Hub → Uninstall

## Troubleshooting

**Tools don't load:**
- Check AutoCAD support file search path includes the installation folder
- Verify acad.lsp is in the correct location
- Check for LISP error messages in AutoCAD command line

**Commands not recognized:**
- Type `(AH:HELLO)` at command line to test if core utilities loaded
- Type `AH:HELP` for command list

**Excel templates not found:**
- Templates are in: `[Install Dir]\excel-templates\`
- Copy to your project folder and customize as needed

## Support

For issues or questions:
- Check the User Guide
- Visit: architect-helper-hub.com
- GitHub: github.com/your-repo/architect-helper-hub
