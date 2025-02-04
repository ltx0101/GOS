if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "                                                  GOS"
$form.ForeColor = [System.Drawing.Color]::White
$form.Size = New-Object System.Drawing.Size(370, 280)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

function Show-Message($message) {
    [System.Windows.Forms.MessageBox]::Show($message, "GOS", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Enable-GameMode {
    
    $services = @(
    "AllJoyn Router Service", "BITS", "BitLocker Drive Encryption Service", "Bluetooth Support Service",
    "BthAvctpSvc", "CertPropSvc", "Connected Devices Platform Service", "CscService", "DiagTrack",
    "Diagnostic Policy Service", "Distributed Link Tracking Client", "Downloaded Maps Manager", "DPS",
    "DusmSvc", "Fax", "Function Discovery Resource Publication",
    "Geolocation Service", "icssvc", "LanmanServer", "lmhosts", "MapsBroker", "Microsoft iSCSI Initiator Service",
    "Netlogon", "Offline Files", "Parental Controls", "Payments and NFC/SE Manager", "Phone Service",
    "PhoneSvc", "Print Spooler", "Program Compatibility Assistant Service", "RemoteRegistry", "Retail Demo Service",
    "RmSvc", "SCardSvr", "Secondary Logon", "SessionEnv", "SENS", "Smart Card", "Smart Card Device Enumeration Service",
    "Spooler", "SSDPSRV", "stisvc", "Superfetch", "SysMain", "TabletInputService", "TermService",
    "Touch Keyboard and Handwriting Panel Service", "UmRdpService", "UPnP Device Host", "UsoSvc",
    "wercplsupport", "WerSvc", "WbioSrvc", "Windows Biometric Service", "Windows Camera Frame Server",
    "Windows Error Reporting Service", "Windows Image Acquisition (WIA)", "Windows Insider Service",
    "Windows Media Player Network Sharing Service", "Windows Search", "Windows Update", "WpcMonSvc",
    "wuauserv", "Xbox Live Auth Manager",
    "Xbox Live Game Save", "Xbox Live Networking Service", "Themes", "TrkWks", "FontCache", "DoSvc", "SENS",
    "xboxgip", "xbgm", "XblGameSave", "XblAuthManager", "seclogon", "WSearch", "Tablet PC Input Service",
    "WaaSMedicSvc", "TextInputManagementService", "WebBrowserInfrastructureService", "WpnService", "InstallService", "UsoSvc",
    "ActiveX Installer", "AxInstSV", "Application Layer Gateway Service", "Auto Time Zone Updater", "Bluetooth Audio Gateway Service", "Bluetooth Support Service", "BranchCache",
    "Capability Access Manager Service", "Cloud Backup and Restore Service", "Delivery Optimization", "Function Discovery Provider Host",
    "Function Discovery Resource Publication", "Geolocation Service", "GraphicsPerfSvc", "Hyper-V Services", "Internet Connection Sharing (ICS)",
    "Language Experience Service", "Microsoft Store Install Service", "Offline Files", "Performance Logs & Alerts", "Print Spooler", "Remote Access Auto Connection Manager", "QWAVE"
    "vmickvpexchange", "vmicguestinterface", "vmicshutdown", "vmicheartbeat", "vmicvmsession", "vmicrdv", "vmictimesync", "vmicvss", "AppXSvc", "BDESVC", "Fax", "WaaSMedicSvc"
    "wlidsvc", "LicenseManager", "AppXSvc" , "FontCache", "WpnService"
)

foreach ($service in $services) {
    try {
        Stop-Service -Name $service -ErrorAction Stop
        Write-Output \"Stopped service: $service\"
    } catch {
        Write-Output \"Could not stop service: $service\"
    }
}

$servicesd = @(
    "BITS","SysMain","SSDPSRV","WbioSrvc","RemoteRegistry",
    "wercplsupport","DPS","TermService","WpcMonSvc","DiagTrack","MapsBroker","wisvc",
    "icssvc","CertPropSvc","PhoneSvc","BthAvctpSvc","lmhosts","WerSvc","RmSvc",
    "DusmSvc","TabletInputService","RetailDemo"
)

foreach ($serviced in $servicesd) {
    try {
        Set-Service -Name $serviced -StartupType Disabled -ErrorAction Stop
    } catch {
        Write-Output "Failed to disable service: $serviced"
    }
}
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Name "TcpAckFrequency" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Name "TCPNoDelay" -Value 1 -PropertyType DWord -Force
Show-Message "Game Mode enabled!"
}


function Clean-Windows {
    $nvCachePath = "$env:temp\NVIDIA Corporation\NV_Cache"
if (Test-Path -Path $nvCachePath) {
    Remove-Item -Path "$nvCachePath\*" -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path $nvCachePath -Directory | ForEach-Object {
        Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
    }
}

$d3dCachePath = "$env:LOCALAPPDATA\D3DSCache"
if (Test-Path -Path $d3dCachePath) {
    Remove-Item -Path $d3dCachePath -Force -Recurse -ErrorAction SilentlyContinue
}

$tempPaths = @("$env:temp\*", "C:\Windows\temp\*", "C:\Windows\Prefetch\*")
foreach ($path in $tempPaths) {
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
    }
}

$thumbCachePath = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete"
if (Test-Path -Path $thumbCachePath) {
    Remove-Item -Path "$thumbCachePath\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path $thumbCachePath -Force -Recurse -ErrorAction SilentlyContinue
}

$windowsUpdatePath = "C:\Windows\SoftwareDistribution\Download\*"
if (Test-Path -Path $windowsUpdatePath) {
    Remove-Item -Path $windowsUpdatePath -Force -Recurse -ErrorAction SilentlyContinue
}
cleanmgr /verylowdisk
}


function Optimize-Network {

Stop-Service -Name "winnat" -Force -ErrorAction SilentlyContinue
Start-Process -FilePath "reg.exe" -ArgumentList "add HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost /v Ethernet /t REG_DWORD /d 2 /f" -Verb RunAs
Start-Process -FilePath "reg.exe" -ArgumentList "add HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings /v EnableHttp2 /t REG_DWORD /d 1 /f" -Verb RunAs
Start-Service -Name "winnat" -ErrorAction SilentlyContinue

ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh int ip reset
netsh winsock reset

Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Name "TCPNoDelay" -ErrorAction SilentlyContinue
Show-Message "Network optimization applied!"
}


function Repair-Windows {
    Start-Process cmd.exe -ArgumentList "/K", "powershell.exe -Command ""taskkill /f /im explorer.exe; chkdsk /scan; DISM /Online /Cleanup-Image /RestoreHealth; sfc /scannow; shutdown /r /t 5; exit"""
}


function Restore-Defaults {
$servicesToStart = @(
    "AllJoyn Router Service", "BITS", "BitLocker Drive Encryption Service", "Bluetooth Support Service",
    "BthAvctpSvc", "CertPropSvc", "Connected Devices Platform Service", "CscService", "DiagTrack",
    "Diagnostic Policy Service", "Distributed Link Tracking Client", "Downloaded Maps Manager", "DPS",
    "DusmSvc", "Fax", "Function Discovery Resource Publication",
    "Geolocation Service", "icssvc", "LanmanServer", "lmhosts", "MapsBroker", "Microsoft iSCSI Initiator Service",
    "Netlogon", "Offline Files", "Parental Controls", "Payments and NFC/SE Manager", "Phone Service",
    "PhoneSvc", "Print Spooler", "Program Compatibility Assistant Service", "RemoteRegistry", "Retail Demo Service",
    "RmSvc", "SCardSvr", "Secondary Logon", "SessionEnv", "SENS", "Smart Card", "Smart Card Device Enumeration Service",
    "Spooler", "SSDPSRV", "stisvc", "Superfetch", "SysMain", "TabletInputService", "TermService",
    "Touch Keyboard and Handwriting Panel Service", "UmRdpService", "UPnP Device Host", "UsoSvc",
    "wercplsupport", "WerSvc", "WbioSrvc", "Windows Biometric Service", "Windows Camera Frame Server",
    "Windows Error Reporting Service", "Windows Image Acquisition (WIA)", "Windows Insider Service",
    "Windows Media Player Network Sharing Service", "Windows Search", "Windows Update", "WpcMonSvc",
    "wuauserv", "Xbox Live Auth Manager",
    "Xbox Live Game Save", "Xbox Live Networking Service", "Themes", "TrkWks", "FontCache", "DoSvc", "SENS",
    "xboxgip", "xbgm", "XblGameSave", "XblAuthManager", "seclogon", "WSearch", "Tablet PC Input Service",
    "WaaSMedicSvc", "TextInputManagementService", "WebBrowserInfrastructureService", "WpnService", "InstallService", "UsoSvc",
    "ActiveX Installer", "AxInstSV", "Application Layer Gateway Service", "Auto Time Zone Updater", "Bluetooth Audio Gateway Service", "Bluetooth Support Service", "BranchCache",
    "Capability Access Manager Service", "Cloud Backup and Restore Service", "Delivery Optimization", "Function Discovery Provider Host",
    "Function Discovery Resource Publication", "Geolocation Service", "GraphicsPerfSvc", "Hyper-V Services", "Internet Connection Sharing (ICS)",
    "Language Experience Service", "Microsoft Store Install Service", "Offline Files", "Performance Logs & Alerts", "Print Spooler", "Remote Access Auto Connection Manager", "QWAVE"
    "vmickvpexchange", "vmicguestinterface", "vmicshutdown", "vmicheartbeat", "vmicvmsession", "vmicrdv", "vmictimesync", "vmicvss", "AppXSvc", "BDESVC", "Fax", "WaaSMedicSvc"
    "wlidsvc", "LicenseManager", "AppXSvc" , "FontCache", "WpnService"
    )
foreach ($service in $servicesToStart) {
    try {
        Start-Service -Name $service -ErrorAction Stop
        Write-Host "Started service: $service"
    } catch {
        Write-Warning "Failed to start service: $service"
    }
}

$servicesToConfigure = @(
    "BITS", "SysMain", "SSDPSRV", "WSearch", "WbioSrvc", "Spooler", "RemoteRegistry",
    "wercplsupport", "DPS", "TermService", "WpcMonSvc", "DiagTrack", "MapsBroker", "wisvc",
    "icssvc", "CertPropSvc", "PhoneSvc", "BthAvctpSvc", "lmhosts", "WerSvc", "RmSvc",
    "DusmSvc", "TabletInputService", "UsoSvc", "InstallService"
)

foreach ($service in $servicesToConfigure) {
    try {
        Set-Service -Name $service -StartupType Manual -ErrorAction Stop
        Write-Host "Configured service to manual start: $service"
    } catch {
        Write-Warning "Failed to configure service: $service"
    }
}

$restart = Read-Host "Would you like to restart your PC now? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "Restarting the computer..."
    Restart-Computer -Force
} else {
    Write-Host "You can restart the PC later manually."
}

}

function Shortcut {

$ShortcutName = "GOS"
$TargetCmd = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

$Arguments = @"
-ExecutionPolicy Bypass -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList 'iwr `"https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.ps1`" -OutFile `"GOS.ps1`"; .\GOS.ps1'"
"@

$ShortcutPath = "$([environment]::GetFolderPath('Desktop'))\$ShortcutName.lnk"
$IconUrl = "https://raw.githubusercontent.com/ltx0101/GOS/main/GOS.ico"
$IconPath = "$([environment]::GetFolderPath('MyDocuments'))\GOS.ico"
Invoke-WebRequest -Uri $IconUrl -OutFile $IconPath -ErrorAction Stop
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetCmd
$Shortcut.Arguments = $Arguments
$Shortcut.WorkingDirectory = $([environment]::GetFolderPath('UserProfile'))
$Shortcut.WindowStyle = 1
$Shortcut.Description = "Shortcut to execute GOS script"
$Shortcut.IconLocation = $IconPath
$Shortcut.Save()
Show-Message "Shortcut GOS created on Desktop."
}

function Debloat {

$appsToRemove = @(
    "Microsoft.3DBuilder", "Microsoft.Microsoft3DViewer", "Microsoft.AppConnector", "Microsoft.BingFinance", "Microsoft.BingNews", "Microsoft.BingSports", "Microsoft.BingTranslator", "Microsoft.BingWeather", "Microsoft.BingFoodAndDrink",
"Microsoft.BingHealthAndFitness", "Microsoft.BingTravel", "Microsoft.MinecraftUWP", "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.NetworkSpeedTest", "Microsoft.News", "Microsoft.Office.Lens",
"Microsoft.Office.Sway", "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.Office.Desktop", "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Whiteboard", "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps",
"Microsoft.MicrosoftOfficeHub", "Microsoft.XboxGameOverlay", "Microsoft.Xbox.TCUI", "Microsoft.XboxSpeechToTextOverlay", "Microsoft.XboxIdentityProvider", "Microsoft.XboxGameCallableUI", "Microsoft.MixedReality.Portal", "Microsoft.People",
"Microsoft.WindowsAlarms", "Microsoft.WindowsSoundRecorder", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.WindowsStickyNotes", "*EclipseManager*", "*ActiproSoftwareLLC*", "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
"*Duolingo-LearnLanguagesforFree*",  "*PandoraMediaInc*",  "*CandyCrush*",  "*BubbleWitch3Saga*",  "*Wunderlist*",  "*Flipboard*",  "*Twitter*",  "*Facebook*",  "*Royal Revolt*",  "*Sway*",  "*Speed Test*",  "*Dolby*",  "*Viber*",  "*ACGMediaPlayer*",  "*Netflix*",
"*Roblox*", "*BytedancePte.Ltd.TikTok*", "*AmazonVideo.PrimeVideo*", "*MarchOfEmpires*", "*LinkedInforWindows*", "*HiddenCityMysteryofShadows*", "*Hulu*", "*HiddenCity*", "*SpotifyAB.SpotifyMusic*", "*AdobePhotoshopExpress*",
"Microsoft.549981C3F5F10", "Disney.37853FC22B2CE", "MicrosoftTeams", "Microsoft.Todos", "Microsoft.GamingApp", "Microsoft.XboxGamingOverlay", "microsoft.windowscommunicationsapps"

)

foreach ($app in $appsToRemove) {
    $processes = Get-Process | Where-Object { $_.ProcessName -like "*$app*" }
    if ($processes) {
        Write-Host "Stopping process: $app"
        $processes | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

foreach ($app in $appsToRemove) {
    Write-Host "Removing AppxPackage: $app"
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -Like $app } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

foreach ($app in $appsToRemove) {
    Write-Host "Removing provisioned package: $app"
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -Like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
cls
Write-Output "Bloatware has been removed."

Write-Output "Blocking telemetry via Hosts file..."
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$tempHostsPath = "$env:TEMP\hosts.tmp"

Copy-Item -Path $hostsPath -Destination $tempHostsPath -Force
$telemetryHosts = @(
    "vortex.data.microsoft.com",
    "settings-win.data.microsoft.com",
    "watson.telemetry.microsoft.com",
    "telemetry.microsoft.com",
    "oca.telemetry.microsoft.com",
    "sqm.telemetry.microsoft.com"
)
foreach ($telemetryHost in $telemetryHosts) {
    Add-Content -Path $tempHostsPath -Value "127.0.0.1 $telemetryHost"
}
Copy-Item -Path $tempHostsPath -Destination $hostsPath -Force
Remove-Item -Path $tempHostsPath -Force
Write-Output "Telemetry has been disabled."

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DoNotConnectToWindowsUpdateInternetLocations" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableWindowsUpdateAccess" -Type DWord -Value 1
Write-Output "Windows Update has been optimized"

$tasksToDisable = @(
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
)
foreach ($task in $tasksToDisable) {
    if (Get-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue) {
        Disable-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue
    }
}

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
Write-Output "Disabled Windows Error Reporting"

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer
Show-Message "Debloat complete!"
}

# Game Mode Button
$btnGameMode = New-Object System.Windows.Forms.Button
$btnGameMode.Text = "Enable Game Mode " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xE2,0x9A,0xA1))
$btnGameMode.Size = New-Object System.Drawing.Size(230, 40)
$btnGameMode.Location = New-Object System.Drawing.Point(65, 20)
$btnGameMode.Add_Click({ Enable-GameMode })
$btnGameMode.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnGameMode.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnGameMode.FlatAppearance.BorderSize = 0
$tooltipGameMode = New-Object System.Windows.Forms.ToolTip
$tooltipGameMode.SetToolTip($btnGameMode, "Click to enable Game Mode for better performance.")
$btnGameMode.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 15, [System.Drawing.FontStyle]::Regular)

# Clean Windows Button
$btnClean = New-Object System.Windows.Forms.Button
$btnClean.Text = "Clean Windows " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x97,0x91))
$btnClean.Size = New-Object System.Drawing.Size(150, 40)
$btnClean.Location = New-Object System.Drawing.Point(10, 80)
$btnClean.Add_Click({ Clean-Windows })
$btnClean.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClean.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnClean.FlatAppearance.BorderSize = 0
$tooltipClean = New-Object System.Windows.Forms.ToolTip
$tooltipClean.SetToolTip($btnClean, "Click to clean Windows.")
$btnClean.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

# Network Optimization Button
$btnNetwork = New-Object System.Windows.Forms.Button
$btnNetwork.Text = "Optimize Network " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x8C,0x90))
$btnNetwork.Size = New-Object System.Drawing.Size(150, 40)
$btnNetwork.Location = New-Object System.Drawing.Point(10, 130)
$btnNetwork.Add_Click({ Optimize-Network })
$btnNetwork.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnNetwork.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnNetwork.FlatAppearance.BorderSize = 0
$tooltipNetwork = New-Object System.Windows.Forms.ToolTip
$tooltipNetwork.SetToolTip($btnNetwork, "Click to optimize network settings.")
$btnNetwork.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

# Repair Windows Button
$btnRepair = New-Object System.Windows.Forms.Button
$btnRepair.Text = "Repair Windows " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x94,0xA7))
$btnRepair.Size = New-Object System.Drawing.Size(150, 40)
$btnRepair.Location = New-Object System.Drawing.Point(195, 130)
$btnRepair.Add_Click({ Repair-Windows })
$btnRepair.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRepair.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnRepair.FlatAppearance.BorderSize = 0
$tooltipRepair = New-Object System.Windows.Forms.ToolTip
$tooltipRepair.SetToolTip($btnRepair, "Click to repair Windows system files.")
$btnRepair.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

# Restore Defaults Button
$btnRestore = New-Object System.Windows.Forms.Button
$btnRestore.Text = "Restore Defaults " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xE2,0x9A,0x99, 0xEF,0xB8,0x8F))
$btnRestore.Size = New-Object System.Drawing.Size(150, 40)
$btnRestore.Location = New-Object System.Drawing.Point(195, 80)
$btnRestore.Add_Click({ Restore-Defaults })
$btnRestore.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestore.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnRestore.FlatAppearance.BorderSize = 0
$tooltipRestore = New-Object System.Windows.Forms.ToolTip
$tooltipRestore.SetToolTip($btnRestore, "Click to restore default settings.")
$btnRestore.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

# Shortcut Button
$btnShortcut = New-Object System.Windows.Forms.Button
$btnShortcut.Text = "Shortcut " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xE2,0x86,0xAA, 0xEF,0xB8,0x8F))
$btnShortcut.Size = New-Object System.Drawing.Size(150, 40)
$btnShortcut.Location = New-Object System.Drawing.Point(195, 180)
$btnShortcut.Add_Click({ Shortcut })
$btnShortcut.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnShortcut.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnShortcut.FlatAppearance.BorderSize = 0
$tooltipShortcut = New-Object System.Windows.Forms.ToolTip
$tooltipShortcut.SetToolTip($btnShortcut, "Click to create a shortcut.")
$btnShortcut.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

# Debloat Button
$btnDebloat = New-Object System.Windows.Forms.Button
$btnDebloat.Text = "Debloat " + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0xA7,0xB9))
$btnDebloat.Size = New-Object System.Drawing.Size(150, 40)
$btnDebloat.Location = New-Object System.Drawing.Point(10, 180)
$btnDebloat.Add_Click({ Debloat })
$btnDebloat.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnDebloat.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnDebloat.FlatAppearance.BorderSize = 0
$tooltipDebloat = New-Object System.Windows.Forms.ToolTip
$tooltipDebloat.SetToolTip($btnDebloat, "Click to remove any Microsoft pre-installed Bloatware.")
$btnDebloat.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)


# Add buttons to the form
$form.Controls.Add($btnGameMode)
$form.Controls.Add($btnClean)
$form.Controls.Add($btnNetwork)
$form.Controls.Add($btnRepair)
$form.Controls.Add($btnRestore)
$form.Controls.Add($btnShortcut)
$form.Controls.Add($btnDebloat)

# Run the form
[void]$form.ShowDialog()
