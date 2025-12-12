;======================================================================
; ARCHITECT HELPER HUB - NSIS Installer Script
; Description: Windows installer for Architect Helper Hub
; Requirements: NSIS (Nullsoft Scriptable Install System)
;======================================================================

; Installer settings
!define APP_NAME "Architect Helper Hub"
!define APP_VERSION "1.0"
!define APP_PUBLISHER "Architect Helper"
!define APP_INSTALL_DIR "ArchitectHelper"

; Include Modern UI
!include "MUI2.nsh"

; General settings
Name "${APP_NAME} ${APP_VERSION}"
OutFile "ArchitectHelper_Setup_v${APP_VERSION}.exe"
InstallDir "$APPDATA\Autodesk\ApplicationPlugins\${APP_INSTALL_DIR}"
RequestExecutionLevel user

; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\..\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

;======================================================================
; Installer Section
;======================================================================
Section "Main Application" SecMain
  SetOutPath "$INSTDIR"

  ; Install LISP files
  CreateDirectory "$INSTDIR\lisp"
  CreateDirectory "$INSTDIR\lisp\core"
  CreateDirectory "$INSTDIR\lisp\blocks"
  CreateDirectory "$INSTDIR\lisp\layers"
  CreateDirectory "$INSTDIR\lisp\sheets"
  CreateDirectory "$INSTDIR\lisp\export"

  File /oname=lisp\core\utils.lsp "..\..\src\lisp\core\utils.lsp"
  File /oname=lisp\blocks\block-manager.lsp "..\..\src\lisp\blocks\block-manager.lsp"
  File /oname=lisp\layers\layer-tools.lsp "..\..\src\lisp\layers\layer-tools.lsp"
  File /oname=lisp\sheets\auto-area-tag.lsp "..\..\src\lisp\sheets\auto-area-tag.lsp"
  File /oname=lisp\export\batch-pdf.lsp "..\..\src\lisp\export\batch-pdf.lsp"

  ; Install Excel templates
  CreateDirectory "$INSTDIR\excel-templates"
  File /oname=excel-templates\sheet-list-template.csv "..\..\src\excel-integration\sheet-list-template.csv"
  File /oname=excel-templates\door-schedule-template.csv "..\..\src\excel-integration\door-schedule-template.csv"
  File /oname=excel-templates\window-schedule-template.csv "..\..\src\excel-integration\window-schedule-template.csv"
  File /oname=excel-templates\room-schedule-template.csv "..\..\src\excel-integration\room-schedule-template.csv"

  ; Install documentation
  CreateDirectory "$INSTDIR\docs"
  File /oname=docs\README.txt "..\..\README.md"
  File /oname=docs\USER-GUIDE.txt "..\..\docs\user-guide.md"

  ; Create AutoCAD support folder path entry
  Call AddToAutoCADSupport

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Create Start Menu shortcuts
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Folder.lnk" "$INSTDIR"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\User Guide.lnk" "$INSTDIR\docs\USER-GUIDE.txt"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

  ; Registry keys for Add/Remove Programs
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"

  MessageBox MB_OK "Installation complete!$\n$\nArchitect Helper Hub has been installed.$\n$\nPlease restart AutoCAD to load the tools."
SectionEnd

;======================================================================
; Function: Add to AutoCAD Support Path
;======================================================================
Function AddToAutoCADSupport
  ; This is simplified - actual implementation would need to:
  ; 1. Detect AutoCAD version(s)
  ; 2. Modify registry to add support path
  ; 3. Handle multiple AutoCAD installations

  ; Placeholder for registry modification
  ; Actual code would modify:
  ; HKCU\Software\Autodesk\AutoCAD\R##.#\ACAD-####:###\Profiles\<<Unnamed Profile>>\General
  ; Key: ACAD

  ; For now, we'll just create the acad.lsp in a common location
  SetOutPath "$APPDATA\Autodesk\UserDataCache\AutoCAD"
  File /oname=acad.lsp "..\autoload\acad.lsp"
FunctionEnd

;======================================================================
; Uninstaller Section
;======================================================================
Section "Uninstall"
  ; Remove files
  RMDir /r "$INSTDIR\lisp"
  RMDir /r "$INSTDIR\excel-templates"
  RMDir /r "$INSTDIR\docs"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"

  ; Remove Start Menu shortcuts
  RMDir /r "$SMPROGRAMS\${APP_NAME}"

  ; Remove registry keys
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

  ; Remove acad.lsp (optional - may want to keep user customizations)
  ; Delete "$APPDATA\Autodesk\UserDataCache\AutoCAD\acad.lsp"

  MessageBox MB_OK "Architect Helper Hub has been uninstalled.$\n$\nPlease restart AutoCAD."
SectionEnd

; End of install.nsi
