@echo off
title GOS

if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)
cd "%~dp0"
chcp 65001 >nul
echo ┏┓┏┓┏┓
echo ┃┓┃┃┗┓
echo ┗┛┗┛┗┛
echo Gaming Optimization Script
echo.
echo Hello, %USERNAME%.
echo.
echo Please select an option:
echo ------------------------------------------------------------------------------------
echo 1. Enable Game Mode
echo 2. Game Mode + Network Fix             (Choose only if you have connection issues)
echo 3. Repair Windows                                (Restart is recommended)
echo 4. Restore Default Settings                      (Restart is recommended)
echo 5. Network Optimize                                 (Restart Required)
echo 6. Enable Windows Update
echo 7. Create GOS Shortcut
echo 8. Exit
echo ------------------------------------------------------------------------------------
:choice
REM Use the CHOICE command to prompt for input
choice /C 12345678 /N /M "Enter your choice (1-8): "

REM Perform actions based on choice
if errorlevel 8 goto exit
if errorlevel 7 goto shortcut
if errorlevel 6 goto winupd
if errorlevel 5 goto nettweaks
if errorlevel 4 goto activate
if errorlevel 3 goto repair
if errorlevel 2 goto full
if errorlevel 1 goto game

:game
color 0a
net stop wuauserv
net stop "Windows Update"

for %%S in (
  "AllJoyn Router Service" "BITS" "BitLocker Drive Encryption Service" "Bluetooth Support Service" 
  "BthAvctpSvc" "CertPropSvc" "Connected Devices Platform Service" "CscService" "DiagTrack" 
  "Diagnostic Policy Service" "Distributed Link Tracking Client" "Downloaded Maps Manager" "DPS" 
  "DusmSvc" "Fax" "Function Discovery Resource Publication" 
  "Geolocation Service" "icssvc" "LanmanServer" "lmhosts" "MapsBroker" "Microsoft iSCSI Initiator Service" 
  "Netlogon" "Offline Files" "Parental Controls" "Payments and NFC/SE Manager" "Phone Service" 
  "PhoneSvc" "Print Spooler" "Program Compatibility Assistant Service" "RemoteRegistry" "Retail Demo Service" 
  "RmSvc" "SCardSvr" "Secondary Logon" "SessionEnv" "SENS" "Smart Card" "Smart Card Device Enumeration Service" 
  "Spooler" "SSDPSRV" "stisvc" "Superfetch" "SysMain" "TabletInputService" "TermService" 
  "Touch Keyboard and Handwriting Panel Service" "UmRdpService" "UPnP Device Host" "UsoSvc" 
  "wercplsupport" "WerSvc" "WbioSrvc" "Windows Biometric Service" "Windows Camera Frame Server" 
  "Windows Error Reporting Service" "Windows Image Acquisition (WIA)" "Windows Insider Service" 
  "Windows Media Player Network Sharing Service" "Windows Search" "Windows Update" "WpcMonSvc" 
  "wuauserv" "Xbox Accessory Management Service" "Xbox Live Auth Manager" 
  "Xbox Live Game Save" "Xbox Live Networking Service" "Themes" "TrkWks" "FontCache" "DoSvc" "SENS" 
  "xboxgip" "xbgm" "XblGameSave" "XblAuthManager" "seclogon" "WSearch" "Tablet PC Input Service"
  "XboxGipSvc" "WaaSMedicSvc" "TextInputManagementService" "WebBrowserInfrastructureService" "WpnService"
) do net stop %%S
net stop "Function Discovery Provider Host" /y

for %%S in (
  "BITS" "SysMain" "SSDPSRV" "WSearch" "WbioSrvc" "Spooler" "RemoteRegistry" 
  "wercplsupport" "DPS" "TermService" "WpcMonSvc" "DiagTrack" "MapsBroker" "wisvc" 
  "icssvc" "CertPropSvc" "PhoneSvc" "BthAvctpSvc" "lmhosts" "WerSvc" "RmSvc" 
  "DusmSvc" "TabletInputService" "UsoSvc"
) do sc config %%S start= disabled
del /f /s /q "C:\Windows\SoftwareDistribution\Download"
exit

:full

rd /s /q  %LOCALAPPDATA%\D3DSCache
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

for %%S in (
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
  "wuauserv" "Xbox Accessory Management Service" "Xbox Live Auth Manager" 
  "Xbox Live Game Save" "Xbox Live Networking Service" "Themes" "TrkWks" "FontCache" "DoSvc" "SENS" 
  "xboxgip" "xbgm" "XblGameSave" "XblAuthManager" "seclogon" "WSearch" "Tablet PC Input Service"
  "XboxGipSvc" "WaaSMedicSvc" "TextInputManagementService" "WebBrowserInfrastructureService" "WpnService"
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

:nettweaks

net start winnat

echo Applying Network Adapter Registry Settings...
for /f %%r in ('reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}" /f "PCI\VEN" /d /s^|Findstr HKEY') do (
    REG ADD "%%r" /v "*EEE" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LsoV1IPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LsoV2IPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LsoV2IPv6" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*WakeOnPattern" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*GreenEthernet" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*ChecksumOffloadIPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*ChecksumOffloadIPv6" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*TCPChecksumOffloadIPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*TCPChecksumOffloadIPv6" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*UDPChecksumOffloadIPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*UDPChecksumOffloadIPv6" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LsoV1IPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LsoV2IPv4" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LsoV2IPv6" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*TaskOffload" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LargeSendOffloadV1" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*LargeSendOffloadV2" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*ARPOffload" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*NSOffload" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*PowerSavingMode" /t REG_SZ /d "0" /f >NUL
    REG ADD "%%r" /v "*IPChecksumOffloadIPv4" /t REG_SZ /d "0" /f >NUL


)

net start winnat
ipconfig /flushdns
ipconfig /release
ipconfig /renew
net stop winnat
net start winnat

set /p restart="Would you like to restart your PC now? (Y/N): "

if /i "%restart%"=="Y" (
    echo Restarting the computer...
    shutdown /r /t 10
) else (
    echo You can restart the PC later manually.
)

exit

:winupd
sc config wuauserv start= auto
net start wuauserv
sc config bits start= auto
net start bits
sc config CryptSvc start= auto
net start CryptSvc
sc config MSIServer start= demand
net start MSIServer
sc config DoSvc start= auto
net start DoSvc
sc config NcaSvc start= demand
net start NcaSvc
sfc /scannow

echo Windows Update started!
set /p restart="Would you like to restart your PC now? (Y/N): "

if /i "%restart%"=="Y" (
    echo Restarting the computer...
    shutdown /r /t 10
) else (
    echo You can restart the PC later manually.
)

:shortcut
REM Variables
set SHORTCUT_NAME=GOS
set TARGET_CMD=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
set ARGUMENTS=-ExecutionPolicy Bypass -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList ''iwr \"https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.bat\" -OutFile \"GOS.bat\"; .\GOS.bat''"

set SHORTCUT_PATH=%USERPROFILE%\Desktop\%SHORTCUT_NAME%.lnk

REM Create Shortcut using PowerShell
powershell.exe -NoProfile -Command ^
$WshShell = New-Object -ComObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); ^
$Shortcut.TargetPath = '%TARGET_CMD%'; ^
$Shortcut.Arguments = '%ARGUMENTS%'; ^
$Shortcut.WorkingDirectory = '%USERPROFILE%'; ^
$Shortcut.WindowStyle = 1; ^
$Shortcut.Description = 'Shortcut to execute GOS script'; ^
$Shortcut.IconLocation = '%TARGET_CMD%,0'; ^
$Shortcut.Save()

echo Shortcut GOS created on Desktop.
pause

:exit
exit
