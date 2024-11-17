@echo off
title GOS

if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)
cd "%~dp0"

echo Gaming Optimization Script
echo.
echo Hello, %USERNAME%.
echo.
echo Please select an option:
echo ------------------------------------------------------------------------------------
echo 1. Enable Game Mode
echo 2. Game Mode + Network Optimize         (Choose only if you have connection issues)
echo 3. Repair Windows                                (Restart is recommended)
echo 4. Restore Default Settings                      (Restart is recommended)
echo 5. Install Winget
echo 6. Exit
echo ------------------------------------------------------------------------------------
:choice
REM Use the CHOICE command to prompt for input
choice /C 123456 /N /M "Enter your choice (1-6): "

REM Perform actions based on choice
if errorlevel 6 goto exit
if errorlevel 5 goto winget
if errorlevel 4 goto activate
if errorlevel 3 goto repair
if errorlevel 2 goto full
if errorlevel 1 goto game

:game
color 0a
net stop wuauserv
net start "Windows Update"

for %%S in (
  "AllJoyn Router Service" "BITS" "BitLocker Drive Encryption Service" "Bluetooth Support Service" 
  "BthAvctpSvc" "CertPropSvc" "Connected Devices Platform Service" "CscService" "DiagTrack" 
  "Diagnostic Policy Service" "Distributed Link Tracking Client" "Downloaded Maps Manager" "DPS" 
  "DusmSvc" "Fax" "Function Discovery Provider Host" "Function Discovery Resource Publication" 
  "Geolocation Service" "icssvc" "LanmanServer" "lmhosts" "MapsBroker" "Microsoft iSCSI Initiator Service" 
  "Netlogon" "Offline Files" "Parental Controls" "Payments and NFC/SE Manager" "Phone Service" 
  "PhoneSvc" "Print Spooler" "Program Compatibility Assistant Service" "RemoteRegistry" "Retail Demo Service" 
  "RmSvc" "SCardSvr" "Secondary Logon" "SessionEnv" "SENS" "Smart Card" "Smart Card Device Enumeration Service" 
  "Spooler" "SSDPSRV" "stisvc" "Superfetch" "SysMain" "TabletInputService" "TermService" 
  "Touch Keyboard and Handwriting Panel Service" "UmRdpService" "UPnP Device Host" "UsoSvc" 
  "wercplsupport" "WerSvc" "WbioSrvc" "Windows Biometric Service" "Windows Camera Frame Server" 
  "Windows Error Reporting Service" "Windows Image Acquisition (WIA)" "Windows Insider Service" 
  "Windows Media Player Network Sharing Service" "Windows Search" "Windows Update" "WpcMonSvc" 
  "wscsvc" "wuauserv" "Xbox Accessory Management Service" "Xbox Live Auth Manager" 
  "Xbox Live Game Save" "Xbox Live Networking Service"
) do net stop %%S

for %%S in (
  "BITS" "SysMain" "SSDPSRV" "WSearch" "WbioSrvc" "Spooler" "RemoteRegistry" 
  "wercplsupport" "DPS" "TermService" "WpcMonSvc" "DiagTrack" "MapsBroker" "wisvc" 
  "icssvc" "CertPropSvc" "PhoneSvc" "BthAvctpSvc" "lmhosts" "WerSvc" "RmSvc" 
  "DusmSvc" "TabletInputService" "UsoSvc"
) do sc config %%S start= disabled
del /f /s /q "C:\Windows\SoftwareDistribution\Download"
exit

:full

del /q /f /s "%temp%\*" 2>nul
del /q /f /s "C:\Windows\temp\*" 2>nul
del /q /f /s "C:\Windows\Prefetch\*" 2>nul

if exist "%userprofile%\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete\" (
    del /q /f /s "%userprofile%\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete\*" 2>nul
    rmdir /q /s "%userprofile%\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete" 2>nul
)

del /q /f /s "C:\Windows\SoftwareDistribution\Download\*" 2>nul
net stop winnat
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v Ethernet /t REG_DWORD /d 2 /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v EnableHttp2 /t REG_DWORD /d 1 /f
net start winnat
ipconfig /flushdns
ipconfig /release
ipconfig /renew
color 0a
net start "Windows Update"
winget upgrade --all

for %%S in (
  "AllJoyn Router Service" "BITS" "BitLocker Drive Encryption Service" "Bluetooth Support Service" 
  "BthAvctpSvc" "CertPropSvc" "Connected Devices Platform Service" "CscService" "DiagTrack" 
  "Diagnostic Policy Service" "Distributed Link Tracking Client" "Downloaded Maps Manager" "DPS" 
  "DusmSvc" "Fax" "Function Discovery Provider Host" "Function Discovery Resource Publication" 
  "Geolocation Service" "icssvc" "LanmanServer" "lmhosts" "MapsBroker" "Microsoft iSCSI Initiator Service" 
  "Netlogon" "Offline Files" "Parental Controls" "Payments and NFC/SE Manager" "Phone Service" 
  "PhoneSvc" "Print Spooler" "Program Compatibility Assistant Service" "RemoteRegistry" "Retail Demo Service" 
  "RmSvc" "SCardSvr" "Secondary Logon" "SessionEnv" "SENS" "Smart Card" "Smart Card Device Enumeration Service" 
  "Spooler" "SSDPSRV" "stisvc" "Superfetch" "SysMain" "TabletInputService" "TermService" 
  "Touch Keyboard and Handwriting Panel Service" "UmRdpService" "UPnP Device Host" "UsoSvc" 
  "wercplsupport" "WerSvc" "WbioSrvc" "Windows Biometric Service" "Windows Camera Frame Server" 
  "Windows Error Reporting Service" "Windows Image Acquisition (WIA)" "Windows Insider Service" 
  "Windows Media Player Network Sharing Service" "Windows Search" "Windows Update" "WpcMonSvc" 
  "wscsvc" "wuauserv" "Xbox Accessory Management Service" "Xbox Live Auth Manager" 
  "Xbox Live Game Save" "Xbox Live Networking Service"
) do net stop %%S

for %%S in (
  "BITS" "SysMain" "SSDPSRV" "WSearch" "WbioSrvc" "Spooler" "RemoteRegistry" 
  "wercplsupport" "DPS" "TermService" "WpcMonSvc" "DiagTrack" "MapsBroker" "wisvc" 
  "icssvc" "CertPropSvc" "PhoneSvc" "BthAvctpSvc" "lmhosts" "WerSvc" "RmSvc" 
  "DusmSvc" "TabletInputService" "UsoSvc"
) do sc config %%S start= disabled


set "regPath=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
reg add "%regPath%\Recycle Bin" /v StateFlags0001 /t REG_DWORD /d 0 /f
reg add "%regPath%\Active Setup Temp Folders" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Downloaded Program Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Internet Cache Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Old ChkDsk Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Previous Installations" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Service Pack Cleanup" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Setup Log Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\System error memory dump files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\System error minidump files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Temporary Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Temporary Setup Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Temporary Sync Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Windows Error Reporting" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Windows Upgrade Log Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
cleanmgr /sagerun:1

endlocal
exit

:repair
color 0a
taskkill /f /im explorer.exe
set "regPath=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
reg add "%regPath%\Recycle Bin" /v StateFlags0001 /t REG_DWORD /d 0 /f
reg add "%regPath%\Active Setup Temp Folders" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Downloaded Program Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Internet Cache Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Old ChkDsk Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Previous Installations" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Service Pack Cleanup" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Setup Log Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\System error memory dump files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\System error minidump files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Temporary Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Temporary Setup Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Temporary Sync Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Windows Error Reporting" /v StateFlags0001 /t REG_DWORD /d 2 /f
reg add "%regPath%\Windows Upgrade Log Files" /v StateFlags0001 /t REG_DWORD /d 2 /f
cleanmgr /sagerun:1

chkdsk /scan
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
start explorer.exe
echo.
echo Repair completed.
set /p restart="Would you like to restart your PC now? (Y/N): "

if /i "%restart%"=="Y" (
    echo Restarting the computer...
    shutdown /r /t 10
) else (
    echo You can restart the PC later manually.
)

exit

:activate
color 0a
net stop wuauserv
net start "Windows Update"

for %%S in (
  "AllJoyn Router Service" "BITS" "BitLocker Drive Encryption Service" "Bluetooth Support Service" 
  "BthAvctpSvc" "CertPropSvc" "Connected Devices Platform Service" "CscService" "DiagTrack" 
  "Diagnostic Policy Service" "Distributed Link Tracking Client" "Downloaded Maps Manager" "DPS" 
  "DusmSvc" "Fax" "Function Discovery Provider Host" "Function Discovery Resource Publication" 
  "Geolocation Service" "icssvc" "LanmanServer" "lmhosts" "MapsBroker" "Microsoft iSCSI Initiator Service" 
  "Netlogon" "Offline Files" "Parental Controls" "Payments and NFC/SE Manager" "Phone Service" 
  "PhoneSvc" "Print Spooler" "Program Compatibility Assistant Service" "RemoteRegistry" "Retail Demo Service" 
  "RmSvc" "SCardSvr" "Secondary Logon" "SessionEnv" "SENS" "Smart Card" "Smart Card Device Enumeration Service" 
  "Spooler" "SSDPSRV" "stisvc" "Superfetch" "SysMain" "TabletInputService" "TermService" 
  "Touch Keyboard and Handwriting Panel Service" "UmRdpService" "UPnP Device Host" "UsoSvc" 
  "wercplsupport" "WerSvc" "WbioSrvc" "Windows Biometric Service" "Windows Camera Frame Server" 
  "Windows Error Reporting Service" "Windows Image Acquisition (WIA)" "Windows Insider Service" 
  "Windows Media Player Network Sharing Service" "Windows Search" "Windows Update" "WpcMonSvc" 
  "wscsvc" "wuauserv" "Xbox Accessory Management Service" "Xbox Live Auth Manager" 
  "Xbox Live Game Save" "Xbox Live Networking Service"
) do net start %%S

for %%S in (
  "BITS" "SysMain" "SSDPSRV" "WSearch" "WbioSrvc" "Spooler" "RemoteRegistry" 
  "wercplsupport" "DPS" "TermService" "WpcMonSvc" "DiagTrack" "MapsBroker" "wisvc" 
  "icssvc" "CertPropSvc" "PhoneSvc" "BthAvctpSvc" "lmhosts" "WerSvc" "RmSvc" 
  "DusmSvc" "TabletInputService" "UsoSvc"
) do sc config %%S start= demand

set /p restart="Would you like to restart your PC now? (Y/N): "

if /i "%restart%"=="Y" (
    echo Restarting the computer...
    shutdown /r /t 10
) else (
    echo You can restart the PC later manually.
)

exit

:winget

setlocal

echo Checking if winget is installed...
winget --version >nul 2>&1

if %ERRORLEVEL%==0 (
    echo Winget is already installed.
) else (
    echo Winget is not installed. Proceeding with installation...
    set "URL=https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    set "FILE=%TEMP%\AppInstaller.msixbundle"

    echo Downloading the latest App Installer package for winget...
    powershell -Command "Invoke-WebRequest -Uri %URL% -OutFile %FILE%"

    if exist "%FILE%" (
        echo Download complete. Installing App Installer...
        powershell -Command "Add-AppxPackage -Path '%FILE%'"
        
        if %ERRORLEVEL%==0 (
            echo Winget installed successfully.
            echo Cleaning up downloaded files...
            del "%FILE%"
            echo Done.
        ) else (
            echo Error occurred during installation.
        )
    ) else (
        echo Download failed. Please check your internet connection and try again.
    )
)


echo Do you want to upgrade all your apps? (Y/N)
set /p upgradeChoice=

if /i "%upgradeChoice%"=="Y" (
    echo Upgrading all apps...
    winget upgrade --all
    echo All apps upgraded.
) else (
    echo No apps were upgraded.
)

endlocal
exit

:exit
exit
