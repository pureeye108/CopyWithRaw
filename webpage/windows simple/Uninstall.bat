@echo off

:: Create a temporary registry file
set REG_FILE=%TEMP%\CopyWithRAW_Uninstall.reg

echo Windows Registry Editor Version 5.00 > "%REG_FILE%"
echo. >> "%REG_FILE%"

:: For .jpg
echo [-HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyWithRAW] >> "%REG_FILE%"
echo [-HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyToWL] >> "%REG_FILE%"
echo [-HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\CopyToWLAuto] >> "%REG_FILE%"
echo. >> "%REG_FILE%"

:: For .jpeg
echo [-HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyWithRAW] >> "%REG_FILE%"
echo [-HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyToWL] >> "%REG_FILE%"
echo [-HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\CopyToWLAuto] >> "%REG_FILE%"

:: Apply the registry file
regedit.exe /s "%REG_FILE%"

:: Clean up
del "%REG_FILE%"

echo "Copy with RAW" has been successfully removed from the context menu!
pause
