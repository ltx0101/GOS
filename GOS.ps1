if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
$consolePtr = [Win32]::GetConsoleWindow()
[Win32]::ShowWindow($consolePtr, 0) | Out-Null
Start-Sleep -Milliseconds 100

$ComputerName = $env:COMPUTERNAME
$OS = Get-CimInstance Win32_OperatingSystem
$CPU = Get-CimInstance Win32_Processor
$RAM = Get-CimInstance Win32_ComputerSystem
$Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$IP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "Loopback*"}
$GPU = Get-CimInstance Win32_VideoController
$BIOS = Get-CimInstance Win32_BIOS
$Motherboard = Get-CimInstance Win32_BaseBoard
$MemoryDevices = Get-CimInstance Win32_PhysicalMemory
$Battery = Get-CimInstance Win32_Battery
$SoundDevices = Get-CimInstance Win32_SoundDevice

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$ColorBg = [System.Drawing.Color]::FromArgb(18, 18, 20)
$ColorSurface = [System.Drawing.Color]::FromArgb(31, 31, 35)
$ColorHeader = [System.Drawing.Color]::FromArgb(24, 24, 27)
$ColorBorder = [System.Drawing.Color]::FromArgb(63, 63, 70)
$ColorAccent = [System.Drawing.Color]::FromArgb(245, 158, 11)
$ColorAccentHover = [System.Drawing.Color]::FromArgb(217, 119, 6)
$ColorText = [System.Drawing.Color]::FromArgb(250, 250, 250)
$ColorSubText = [System.Drawing.Color]::FromArgb(161, 161, 170)
$ColorSuccess = [System.Drawing.Color]::FromArgb(52, 211, 153)
$ColorWarning = [System.Drawing.Color]::FromArgb(251, 191, 36)
$ColorError = [System.Drawing.Color]::FromArgb(248, 113, 113)

$form = New-Object System.Windows.Forms.Form
$form.Text = "GOS"
$form.ClientSize = New-Object System.Drawing.Size(860, 720)
$form.StartPosition = "CenterScreen"
$form.BackColor = $ColorBg
$form.ForeColor = $ColorText
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.MinimizeBox = $true

$iconUrl = "https://github.com/ltx0101/GOS/raw/main/GOS.ico"
$iconPath = "$env:Temp\GOS.ico"
Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
$form.Icon = New-Object System.Drawing.Icon($iconPath)


function Set-StatusText {
    param(
        [string]$Text,
        [ValidateSet("Ready","Working","Success","Warning","Error")]
        [string]$State = "Ready"
    )

    $statusLabel.Text = "Status: $Text"

    switch ($State) {
        "Ready"   { $statusLabel.ForeColor = $ColorSuccess }
        "Working" { $statusLabel.ForeColor = $ColorAccent }
        "Success" { $statusLabel.ForeColor = $ColorSuccess }
        "Warning" { $statusLabel.ForeColor = $ColorWarning }
        "Error"   { $statusLabel.ForeColor = $ColorError }
    }

    $statusLabel.Refresh()
}

function Invoke-ActionSafely {
    param(
        [scriptblock]$Action,
        [string]$ActionName
    )
    try {
        Set-StatusText -Text "$ActionName in progress..." -State "Working"
        $form.UseWaitCursor = $true
        [System.Windows.Forms.Application]::DoEvents()
        & $Action
        Set-StatusText -Text "$ActionName completed." -State "Success"
    }
    catch {
        Set-StatusText -Text "$ActionName failed." -State "Error"
        [System.Windows.Forms.MessageBox]::Show(
            "An error occurred while running '$ActionName':`r`n$($_.Exception.Message)",
            "GOS",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    finally {
        $form.UseWaitCursor = $false
    }
}

function Enable-PerformanceMode {

    $stopServices = @(
        "AJRouter","AppReadiness","BDESVC","bthserv","BTAGService","BthAvctpSvc",
        "CertPropSvc","CscService","DiagTrack","MapsBroker","lfsvc","Fax",
        "PhoneSvc","RemoteRegistry","RetailDemo","SCardSvr","ScDeviceEnum",
        "SSDPSRV","upnphost","WbioSrvc","WerSvc","wisvc","WMPNetworkSvc",
        "XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc","PcaSvc",
        "TrkWks","DoSvc","QWAVE","SEMgrSvc","icssvc","PeerDistSvc",
        "FrameServer","stisvc","TabletInputService",
        "SharedAccess","PimIndexMaintenanceSvc","ContactData","MessagingService",
        "OneSyncSvc","WalletService","lfsvc","FDResPub","WSearch",
        "CDPSvc","Spooler","WpnService","TimeBrokerSvc",
        "InventorySvc","whesvc","CloudBackupRestoreSvc",
        "WinHttpAutoProxySvc","NgcSvc","NgcCtnrSvc","NPSMSvc",
        "logi_lamparray_service","ShellHWDetection"
    )

    foreach ($svc in $stopServices) {
        try {
            Stop-Service $svc -ErrorAction Stop
            Write-Output "Stopped service: $svc"
        } catch {
            Write-Output "Could not stop service: $svc"
        }
    }

    $disableServices = @(
        "SSDPSRV","WbioSrvc","RemoteRegistry","wercplsupport","DPS","TermService",
        "WpcMonSvc","DiagTrack","MapsBroker","wisvc","icssvc","CertPropSvc",
        "PhoneSvc","BthAvctpSvc","lmhosts","WerSvc","RmSvc","DusmSvc",
        "TabletInputService","RetailDemo","CDPSvc","whesvc"
    )

    foreach ($svc in $disableServices) {
        try {
            Set-Service $svc -StartupType Disabled -ErrorAction Stop
        } catch {
            Write-Output "Failed to disable service: $svc"
        }
    }

    Clear-Host
    Write-Host "Performance Mode enabled!" -ForegroundColor Green
}

function Optimize-Win {
[CmdletBinding()]
param()

process {

    $sysInfo  = try { Get-CimInstance Win32_ComputerSystem -ErrorAction Stop } catch { $null }
    $isLaptop = $sysInfo -and ($sysInfo.PCSystemType -eq 2)
    $stepIndex = 0

    function Write-StepProgress($name, $total) {
        $script:stepIndex++
        Write-Progress -Activity 'Optimizing Windows' `
            -Status $name `
            -PercentComplete (($script:stepIndex / $total) * 100)
    }

    function Set-RegistryValueSafe {
        param(
            [string]$Path,
            [string]$Name,
            $Value,
            [string]$Type
        )
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
    }

    function Enable-HAGS {
        $gpuKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
        $existing = Get-ItemProperty -Path $gpuKey -Name 'HwSchMode' -ErrorAction SilentlyContinue
        if ($null -eq $existing) {
            throw 'HAGS not supported on this GPU/driver combination.'
        }
        Set-RegistryValueSafe -Path $gpuKey -Name 'HwSchMode' -Value 2 -Type DWord
    }

    function Enable-PerformanceMode {
        $base = 'HKCU:\SOFTWARE\Microsoft\GameBar'
        Set-RegistryValueSafe -Path $base -Name 'AllowAutoPerformanceMode' -Value 1 -Type DWord
        Set-RegistryValueSafe -Path $base -Name 'AutoPerformanceModeEnabled' -Value 1 -Type DWord
    }

    function Set-PowerProfile {
        if ($isLaptop) {
            powercfg -setactive SCHEME_BALANCED
            return
        }

        $ultimate = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null

        $guid = if ($ultimate) {
            ([regex]'([0-9a-fA-F-]{36})').Match($ultimate).Value
        } else {
            $list = powercfg -list
            $match = $list | Select-String -Pattern 'Ultimate Performance'

            if ($match) {
                ([regex]'([0-9a-fA-F-]{36})').Match($match.Line).Value
            }
        }

        if (-not $guid) {
            Write-Host "  [FAILED] Power Plan: could not determine GUID" -ForegroundColor Red
            return
        }

        powercfg -setactive $guid
    }

    function Enable-TRIM {
        $ssds = Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object MediaType -eq 'SSD'
        if (-not $ssds) {
            throw 'No SSD detected; TRIM not applicable.'
        }
        fsutil behavior set DisableDeleteNotify 0 | Out-Null
    }

    function Enable-StorageSense {
        Set-RegistryValueSafe `
            -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' `
            -Name '01' -Value 1 -Type DWord
    }

    function Optimize-WindowedGames {
        $base = 'HKCU:\System\GameConfigStore'
        Set-RegistryValueSafe -Path $base -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord
        Set-RegistryValueSafe -Path $base -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord
    }

    function Test-VRR {
        $gpu = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $gpu -or $gpu.Name -match 'Basic Display|Microsoft Basic') {
            throw 'No modern GPU detected; VRR likely unavailable.'
        }
        Write-Host "VRR-capable hardware detected. Enable it in Windows Display settings if supported." -ForegroundColor DarkGray
    }

    function Set-FastStartup {
        Set-RegistryValueSafe `
            -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' `
            -Name 'HiberbootEnabled' -Value 0 -Type DWord
    }

    $tasks = @(
        @{ Name = 'HAGS'; Action = { Enable-HAGS } },
        @{ Name = 'Performance Mode'; Action = { Enable-PerformanceMode } },
        @{ Name = 'Power Plan'; Action = { Set-PowerProfile } },
        @{ Name = 'TRIM'; Action = { Enable-TRIM } },
        @{ Name = 'Storage Sense'; Action = { Enable-StorageSense } },
        @{ Name = 'Windowed Games'; Action = { Optimize-WindowedGames } },
        @{ Name = 'VRR Check'; Action = { Test-VRR } },
        @{ Name = 'Fast Startup'; Action = { Set-FastStartup } }
    )

    $total = $tasks.Count

    foreach ($task in $tasks) {
        Write-StepProgress $task.Name $total
        try {
            & $task.Action
        }
        catch {
            Write-Host "  [FAILED] $($task.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Progress -Activity 'Optimizing Windows' -Completed
}

end {
    Write-Host "Windows optimization complete. A restart is recommended." -ForegroundColor Green
}
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

    Write-Host "Cleanup complete!" -ForegroundColor Green
    Write-Host "Note: Some caches will rebuild automatically." -ForegroundColor Yellow
}

function Optimize-Network {
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    netsh int ip reset
    netsh winsock reset

    cls
    Write-Host "Network optimization applied!" -ForegroundColor Green
}

function Repair-Windows {

    Write-Host "Starting system repair..." -ForegroundColor Cyan

    Start-Process cmd.exe -ArgumentList "/c chkdsk /scan" -Wait
    Start-Process cmd.exe -ArgumentList "/c DISM /Online /Cleanup-Image /RestoreHealth" -Wait
    Start-Process cmd.exe -ArgumentList "/c sfc /scannow" -Wait

    Write-Host "Repair complete. Restarting." -ForegroundColor Green

    shutdown.exe /r /t 7
}

function Restore-Defaults {

    $services = @(
		"AJRouter","AppReadiness","BDESVC","bthserv","BTAGService","BthAvctpSvc",
		"CertPropSvc","CscService","DiagTrack","MapsBroker","lfsvc","Fax","PhoneSvc",
		"RemoteRegistry","RetailDemo","SCardSvr","ScDeviceEnum","SSDPSRV","upnphost",
		"WbioSrvc","WerSvc","wisvc","WMPNetworkSvc","XblAuthManager","XblGameSave",
		"XboxNetApiSvc","XboxGipSvc","PcaSvc","TrkWks","DoSvc","QWAVE","SEMgrSvc",
		"icssvc","PeerDistSvc","FrameServer","stisvc","TabletInputService","SharedAccess",
		"PimIndexMaintenanceSvc","ContactData","MessagingService","OneSyncSvc",
		"WalletService","lfsvc","FDResPub","WSearch","CDPSvc","Spooler","WpnService",
		"TimeBrokerSvc","InventorySvc","whesvc","CloudBackupRestoreSvc",
		"WinHttpAutoProxySvc","NgcSvc","NgcCtnrSvc","NPSMSvc","logi_lamparray_service",
		"ShellHWDetection","SSDPSRV","WbioSrvc","RemoteRegistry","wercplsupport",
		"DPS","TermService","WpcMonSvc","DiagTrack","MapsBroker","wisvc","icssvc",
		"CertPropSvc","PhoneSvc","BthAvctpSvc","lmhosts","WerSvc","RmSvc","DusmSvc",
		"TabletInputService","RetailDemo","CDPSvc","whesvc"

    ) | Sort-Object -Unique

    foreach ($service in $services) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue

        if (-not $svc) {
            Write-Host "Service not installed: $service" -ForegroundColor Yellow
            continue
        }

        try {
            if ($svc.StartType -eq "Disabled") {
                Set-Service -Name $service -StartupType Automatic
            }

            if ($svc.Status -ne "Running") {
                Start-Service $service
            }

            Write-Host "OK  $service" -ForegroundColor Green
        }
        catch {
            Write-Warning "Could not start $service"
        }
    }

    Write-Host ""
    Write-Host "Core Windows services restored." -ForegroundColor Green
}

function Debloat {
    cls

    $protectedApps = @(
        "*WindowsStore*",
        "*Microsoft.WindowsStore*",
        "*SecHealthUI*",
        "*Microsoft.Windows.SecHealthUI*",
        "*Microsoft.SecHealthUI*",
        "*Microsoft.WindowsTerminal*",
        "*Microsoft.WindowsCalculator*",
        "*Microsoft.WindowsNotepad*",
        "*Microsoft.Paint*",
        "*Microsoft.MSPaint*",
        "*Microsoft.Windows.Photos*",
        "*Microsoft.ScreenSketch*",
        "*Microsoft.VCLibs*",
        "*Microsoft.NET.Native*",
        "*Microsoft.UI.Xaml*",
        "*Microsoft.StorePurchaseApp*",
        "*Microsoft.DesktopAppInstaller*"
    )

    $appsToRemove = @(
        "Microsoft.XboxApp",
        "Microsoft.GamingApp",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxGameOverlay",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.MinecraftUWP",
        "king.com.CandyCrushSaga",
        "king.com.CandyCrushSodaSaga",
        "king.com.BubbleWitch3Saga",
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.BingFinance",
        "Microsoft.BingSports",
        "Microsoft.BingTranslator",
        "Microsoft.BingFoodAndDrink",
        "Microsoft.BingHealthAndFitness",
        "Microsoft.BingTravel",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.People",
        "Microsoft.WindowsMaps",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.YourPhone",
        "Microsoft.Whiteboard",
        "Microsoft.MixedReality.Portal",
        "Microsoft.3DBuilder",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.Print3D",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.WindowsFeedbackHub",
        "Disney.37853FC22B2CE",
        "SpotifyAB.SpotifyMusic",
        "*Netflix*",
        "*TikTok*",
        "*Instagram*",
        "microsoft.windowscommunicationsapps",
        "Microsoft.SkypeApp",
        "MicrosoftTeams",
        "*WhatsApp*",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.Office.OneNote",
        "Microsoft.Office.Sway",
        "Microsoft.Office.Lens",
        "Microsoft.OneConnect",
        "Microsoft.Todos",
        "Microsoft.MicrosoftJournal",
        "Microsoft.OutlookForWindows",
        "*McAfee*",
        "*Norton*",
        "*CyberLink*",
        "*Dell*Customer*Connect*",
        "*Dell*SupportAssist*",
        "*HP*Support*Assistant*",
        "*Lenovo*Vantage*",
        "*Wildtangent*",
        "Microsoft.PowerAutomateDesktop",
        "Microsoft.DevHome"
    )

    $appsToRemove = $appsToRemove | Where-Object {
        $app = $_
        -not ($protectedApps | Where-Object { $app -like $_ })
    }

    foreach ($app in $appsToRemove) {
        $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
            $_.ProcessName -like "*$app*"
        }

        if ($processes) {
            Write-Host "Stopping process: $app"
            $processes | Stop-Process -Force -ErrorAction SilentlyContinue
        }
    }

    foreach ($app in $appsToRemove) {
        Write-Host "Removing AppxPackage: $app"

        Get-AppxPackage -AllUsers |
            Where-Object { $_.Name -like $app } |
            Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }

    foreach ($app in $appsToRemove) {
        Write-Host "Removing provisioned package: $app"

        Get-AppxProvisionedPackage -Online |
            Where-Object { $_.DisplayName -like $app } |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }

    cls
    Write-Host "Bloatware removal complete." -ForegroundColor Green
}

function New-ModernButton {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width = 210,
        [int]$Height = 52,
        [scriptblock]$OnClick,
        [string]$Tooltip = "",
        [bool]$IsPrimary = $false
    )

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $Text
    $btn.Size = New-Object System.Drawing.Size($Width, $Height)
    $btn.Location = New-Object System.Drawing.Point($X, $Y)
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = $ColorBorder
    $btn.BackColor = if ($IsPrimary) { $ColorAccent } else { $ColorSurface }
    $btn.ForeColor = $ColorText
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.UseVisualStyleBackColor = $false

    $btn.Add_MouseEnter({
        if ($this.BackColor -eq $ColorAccent) {
            $this.BackColor = $ColorAccentHover
        }
        else {
            $this.BackColor = [System.Drawing.Color]::FromArgb(40, 55, 80)
        }
    })

    $btn.Add_MouseLeave({
        if ($IsPrimary) {
            $this.BackColor = $ColorAccent
        }
        else {
            $this.BackColor = $ColorSurface
        }
    })

    if ($OnClick) {
        $btn.Add_Click($OnClick)
    }

    if ($Tooltip -ne "") {
        $tt = New-Object System.Windows.Forms.ToolTip
        $tt.BackColor = $ColorSurface
        $tt.ForeColor = $ColorText
        $tt.SetToolTip($btn, $Tooltip)
    }

    return $btn
}

$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(860, 110)
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = $ColorHeader

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "GOS"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 26)
$titleLabel.ForeColor = $ColorText
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(25, 20)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Windows Optimization Toolkit"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$subtitleLabel.ForeColor = $ColorSubText
$subtitleLabel.AutoSize = $true
$subtitleLabel.Location = New-Object System.Drawing.Point(27, 75)

$separator = New-Object System.Windows.Forms.Panel
$separator.Size = New-Object System.Drawing.Size(860, 1)
$separator.Location = New-Object System.Drawing.Point(0, 109)
$separator.BackColor = $ColorBorder

$headerPanel.Controls.Add($titleLabel)
$headerPanel.Controls.Add($subtitleLabel)
$headerPanel.Controls.Add($separator)

$actionsLabel = New-Object System.Windows.Forms.Label
$actionsLabel.Text = "Actions"
$actionsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$actionsLabel.ForeColor = $ColorText
$actionsLabel.AutoSize = $true
$actionsLabel.Location = New-Object System.Drawing.Point(20, 120)

$btnPerformanceMode = New-ModernButton -Text "Enable Performance Mode" -X 20 -Y 155 -Width 340 -Height 56 -Tooltip "Click to enable Performance Mode for better performance." -OnClick {
    Invoke-ActionSafely -Action { Enable-PerformanceMode } -ActionName "Enable Performance Mode"
}

$btnWinOpt = New-ModernButton -Text "Windows Optimize" -X 20 -Y 225 -Width 340 -Height 56 -Tooltip "Click to apply the latest Windows performance optimizations." -OnClick {
    Invoke-ActionSafely -Action { Optimize-Win } -ActionName "Windows Optimize"
}

$btnNetwork = New-ModernButton -Text "Optimize Network" -X 20 -Y 295 -Width 340 -Height 56 -Tooltip "Click to optimize network settings." -OnClick {
    Invoke-ActionSafely -Action { Optimize-Network } -ActionName "Optimize Network"
}

$btnDebloat = New-ModernButton -Text "Debloat" -X 20 -Y 365 -Width 340 -Height 56 -Tooltip "Click to remove any Microsoft pre-installed Bloatware." -OnClick {
    Invoke-ActionSafely -Action { Debloat } -ActionName "Debloat"
}

$btnClean = New-ModernButton -Text "Clean Windows" -X 20 -Y 435 -Width 340 -Height 56 -Tooltip "Click to clean Windows." -OnClick {
    Invoke-ActionSafely -Action { Clean-Windows } -ActionName "Clean Windows"
}

$btnRepair = New-ModernButton -Text "Repair Windows" -X 20 -Y 505 -Width 340 -Height 56 -Tooltip "Click to repair Windows system files." -OnClick {
    Invoke-ActionSafely -Action { Repair-Windows } -ActionName "Repair Windows"
}

$btnRestore = New-ModernButton -Text "Restore Defaults" -X 20 -Y 575 -Width 340 -Height 56 -Tooltip "Click to restore default settings." -OnClick {
    Invoke-ActionSafely -Action { Restore-Defaults } -ActionName "Restore Defaults"
}

$footerPanel = New-Object System.Windows.Forms.Panel
$footerPanel.Size = New-Object System.Drawing.Size(860, 30)
$footerPanel.Location = New-Object System.Drawing.Point(0, 690)
$footerPanel.BackColor = $ColorHeader

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status: Ready"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.ForeColor = $ColorSuccess
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(20, 5)

$proc = New-Object System.Windows.Forms.Label
$proc.Text = "Processes Running: "
$proc.AutoSize = $true
$proc.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$proc.ForeColor = $ColorText
$proc.Location = New-Object System.Drawing.Point(455, 5)

$Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 500
$Timer.Add_Tick({
    $ProcessCount = (Get-Process | Measure-Object | Select-Object -ExpandProperty Count)
    $proc.Text = "Processes Running: $ProcessCount"
})
$Timer.Start()

$footerPanel.Controls.Add($statusLabel)
$footerPanel.Controls.Add($proc)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ReadOnly = $true
$textBox.BackColor = $ColorBg
$textBox.ForeColor = $ColorText
$textBox.BorderStyle = "None"
$textBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$textBox.Location = New-Object System.Drawing.Point(450, 155)
$textBox.Size = New-Object System.Drawing.Size(330, 490)

$output = @()

$output += "Computer Name: $ComputerName"
$output += ""
$output += "Operating System: $($OS.Caption) ($($OS.Version))"
$output += ""

$output += "CPU Model: $($CPU.Name)"
$output += "CPU Total Cores: = $($CPU.NumberOfCores)"
$output += "CPU Total Threads: = $($CPU.NumberOfLogicalProcessors)"
$output += ""

$output += "Graphics processing unit: $($GPU.Name)"
$output += ""

$output += "Total RAM: $([math]::Round($RAM.TotalPhysicalMemory / 1GB, 2)) GB"
foreach ($mem in $MemoryDevices) {
    $output += "Memory Stick: $([math]::Round($mem.Capacity / 1GB, 2)) GB - Speed: $($mem.Speed) MHz"
}
$output += ""

$output += "Disk Space: $([math]::Round($Disk.Size / 1GB, 2)) GB (Free: $([math]::Round($Disk.FreeSpace / 1GB, 2)) GB)"
$output += ""

$output += "Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)"
$output += "BIOS Version: $($BIOS.SMBIOSBIOSVersion)"
$output += ""

$output += "Sound Devices:"
foreach ($sound in $SoundDevices) {
    $output += "$($sound.Name)"
}
$output += ""

$output += "Network Adapters:"
foreach ($adapter in $IP) {
    $output += "$($adapter.InterfaceAlias): $($adapter.IPAddress)"
}

$textBox.Text = ($output -join "`r`n")

$form.Controls.Add($textBox)
$form.Add_Shown({
    $form.Activate()
    $form.ActiveControl = $null
})

$form.Controls.Add($headerPanel)
$form.Controls.Add($actionsLabel)
$form.Controls.Add($btnPerformanceMode)
$form.Controls.Add($btnRestore)
$form.Controls.Add($btnClean)
$form.Controls.Add($btnNetwork)
$form.Controls.Add($btnRepair)
$form.Controls.Add($btnDebloat)
$form.Controls.Add($btnWinOpt)
$form.Controls.Add($footerPanel)

[void]$form.ShowDialog()
