@echo off
setlocal

:: Get the directory of this batch file
set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%CopyWithRAW.ps1

set VBS_SCRIPT=%SCRIPT_DIR%RunHidden.vbs

:: Ensure the path uses double backslashes for the registry
set VBS_SCRIPT_ESCAPED=%VBS_SCRIPT:\=\\%

:: Create a temporary registry file
set REG_FILE=%TEMP%\CopyWithRAW_Install.reg

echo Windows Registry Editor Version 5.00 > "%REG_FILE%"
echo. >> "%REG_FILE%"

:: For .jpg
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyWithRAW] >> "%REG_FILE%"
echo @="Copy with RAW" >> "%REG_FILE%"
echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
echo "MultiSelectModel"="Player" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyWithRAW\command] >> "%REG_FILE%"
echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\"" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyToWL] >> "%REG_FILE%"
echo @="Copy to Selected WL" >> "%REG_FILE%"
echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
echo "MultiSelectModel"="Player" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyToWL\command] >> "%REG_FILE%"
echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\" \"D:\\Selected\\Wildlife\"" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyToWLAuto] >> "%REG_FILE%"
echo @="Copy to WL (Original Folder)" >> "%REG_FILE%"
echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
echo "MultiSelectModel"="Player" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyToWLAuto\command] >> "%REG_FILE%"
echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\" \"D:\\Selected\\Wildlife\" \"AutoSubfolder\"" >> "%REG_FILE%"
echo. >> "%REG_FILE%"


:: For .jpeg
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyWithRAW] >> "%REG_FILE%"
echo @="Copy with RAW" >> "%REG_FILE%"
echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
echo "MultiSelectModel"="Player" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyWithRAW\command] >> "%REG_FILE%"
echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\"" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyToWL] >> "%REG_FILE%"
echo @="Copy to Selected WL" >> "%REG_FILE%"
echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
echo "MultiSelectModel"="Player" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyToWL\command] >> "%REG_FILE%"
echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\" \"D:\\Selected\\Wildlife\"" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyToWLAuto] >> "%REG_FILE%"
echo @="Copy to WL (Original Folder)" >> "%REG_FILE%"
echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
echo "MultiSelectModel"="Player" >> "%REG_FILE%"
echo. >> "%REG_FILE%"
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyToWLAuto\command] >> "%REG_FILE%"
echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\" \"D:\\Selected\\Wildlife\" \"AutoSubfolder\"" >> "%REG_FILE%"

:: For RAW extensions: .nef .cr2 .cr3 .arw .dng .raf .orf .rw2 .nrw .pef .srw .srf .sr2 .crw
for %%E in (nef cr2 cr3 arw dng raf orf rw2 nrw pef srw srf sr2 crw) do (
    echo. >> "%REG_FILE%"
    echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.%%E\shell\CopyWithRAW] >> "%REG_FILE%"
    echo @="Copy with JPEG" >> "%REG_FILE%"
    echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
    echo "MultiSelectModel"="Player" >> "%REG_FILE%"
    echo. >> "%REG_FILE%"
    echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.%%E\shell\CopyWithRAW\command] >> "%REG_FILE%"
    echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\"" >> "%REG_FILE%"
    echo. >> "%REG_FILE%"
    echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.%%E\shell\CopyToWL] >> "%REG_FILE%"
    echo @="Copy to Selected WL" >> "%REG_FILE%"
    echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
    echo "MultiSelectModel"="Player" >> "%REG_FILE%"
    echo. >> "%REG_FILE%"
    echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.%%E\shell\CopyToWL\command] >> "%REG_FILE%"
    echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\" \"D:\\Selected\\Wildlife\"" >> "%REG_FILE%"
    echo. >> "%REG_FILE%"
    echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.%%E\shell\CopyToWLAuto] >> "%REG_FILE%"
    echo @="Copy to WL (Original Folder)" >> "%REG_FILE%"
    echo "Icon"="imageres.dll,-5322" >> "%REG_FILE%"
    echo "MultiSelectModel"="Player" >> "%REG_FILE%"
    echo. >> "%REG_FILE%"
    echo [HKEY_CLASSES_ROOT\SystemFileAssociations\.%%E\shell\CopyToWLAuto\command] >> "%REG_FILE%"
    echo @="wscript.exe \"%VBS_SCRIPT_ESCAPED%\" \"%%1\" \"D:\\Selected\\Wildlife\" \"AutoSubfolder\"" >> "%REG_FILE%"
)

:: Apply the registry file
regedit.exe /s "%REG_FILE%"

:: Clean up
del "%REG_FILE%"

echo Done! Context menu added for .jpg, .jpeg, and all RAW formats.
pause
