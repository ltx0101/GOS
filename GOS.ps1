if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

$Host.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.BackgroundColor = "Black"
cls
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

Write-Host "System Information for: $ComputerName" -ForegroundColor Green
Write-Host "----------------------------------------"
Write-Host "Operating System: $($OS.Caption) ($($OS.Version))"
Write-Host " "
Write-Host "CPU:" -ForegroundColor Yellow
Write-Host "$($CPU.Name)"
Write-Host " "
Write-Host "Total RAM: $([math]::Round($RAM.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor Yellow
foreach ($mem in $MemoryDevices) {
    Write-Host "Memory Stick: $([math]::Round($mem.Capacity / 1GB, 2)) GB - Speed: $($mem.Speed) MHz"
}
Write-Host " "
Write-Host "Graphics processing unit:" -ForegroundColor Yellow
Write-Host "$($GPU.Name)"
Write-Host " "
Write-Host "Disk Space:" -ForegroundColor Yellow
Write-Host "$([math]::Round($Disk.Size / 1GB, 2)) GB (Free: $([math]::Round($Disk.FreeSpace / 1GB, 2)) GB)"
Write-Host " "
Write-Host "Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)" -ForegroundColor Yellow
Write-Host "BIOS Version: $($BIOS.SMBIOSBIOSVersion)"
Write-Host " "
Write-Host "Battery Information:" -ForegroundColor Yellow
if ($Battery) {
    Write-Host "Battery Status: $($Battery.BatteryStatus) - Estimated Charge Remaining: $($Battery.EstimatedChargeRemaining)%"
} else {
    Write-Host "No battery detected."
}
Write-Host " "
Write-Host "Sound Devices:" -ForegroundColor Yellow
foreach ($sound in $SoundDevices) {
    Write-Host "$($sound.Name)"
}
Write-Host " "
Write-Host "Network Adapters:" -ForegroundColor Cyan
foreach ($adapter in $IP) {
    Write-Host "$($adapter.InterfaceAlias): $($adapter.IPAddress)"
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "GOS"
$form.ForeColor = [System.Drawing.Color]::White
$form.Size = New-Object System.Drawing.Size(370, 340)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(46, 52, 64)
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$iconUrl = "https://github.com/ltx0101/GOS/raw/main/GOS.ico"
$iconPath = "$env:Temp\GOS.ico"
Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath
$form.Icon = New-Object System.Drawing.Icon($iconPath)

function Show-Message($message) {
    [System.Windows.Forms.MessageBox]::Show($message, "GOS", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Enable-GameMode {

    $stopServices = @(
        "AJRouter","AppReadiness","BDESVC","bthserv","BTAGService","BthAvctpSvc",
        "CertPropSvc","CscService","DiagTrack","MapsBroker","lfsvc","Fax",
        "PhoneSvc","RemoteRegistry","RetailDemo","SCardSvr","ScDeviceEnum",
        "SSDPSRV","upnphost","WbioSrvc","WerSvc","wisvc","WMPNetworkSvc",
        "XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc","PcaSvc",
        "TrkWks","DoSvc","QWAVE","SEMgrSvc","icssvc","PeerDistSvc",
		"FrameServer","stisvc","TabletInputService","UsoSvc","Browser" ,
		"SharedAccess","PimIndexMaintenanceSvc","ContactData","MessagingService" ,
		"OneSyncSvc" ,"WalletService" ,"lfsvc","FDResPub","WerFaultSvc","CEIPService"
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
        "TabletInputService","RetailDemo"
    )

    foreach ($svc in $disableServices) {
        try {
            Set-Service $svc -StartupType Disabled -ErrorAction Stop
        } catch {
            Write-Output "Failed to disable service: $svc"
        }
    }

    Clear-Host
    Write-Host "Game Mode enabled!" -ForegroundColor Green
}


function Optimize-Win {
[CmdletBinding()]
param()

process {

    # Identify hardware profile
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

    function Enable-GameMode {
        $base = 'HKCU:\SOFTWARE\Microsoft\GameBar'
        Set-RegistryValueSafe -Path $base -Name 'AllowAutoGameMode' -Value 1 -Type DWord
        Set-RegistryValueSafe -Path $base -Name 'AutoGameModeEnabled' -Value 1 -Type DWord
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
        @{ Name = 'Game Mode'; Action = { Enable-GameMode } },
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
	"AJRouter", "AppReadiness", "AppXSvc", "BDESVC", "BITS", "BTAGService", 
    "BthAvctpSvc", "bthserv", "CertPropSvc", "CscService", "DiagTrack", 
    "DoSvc", "DPS", "EventLog", "Fax", "FDResPub", "FontCache", "FrameServer", 
    "icssvc", "InstallService", "LanmanServer", "lfsvc", "LicenseManager", 
    "lmhosts", "MapsBroker", "PcaSvc", "PeerDistSvc", "PhoneSvc", "QWAVE", 
    "RemoteRegistry", "RetailDemo", "SCardSvr", "ScDeviceEnum", "seclogon", 
    "SEMgrSvc", "SENS", "Spooler", "SSDPSRV", "stisvc", "SysMain", 
    "TabletInputService", "TermService", "Themes", "TrkWks", "upnphost", 
    "UsoSvc", "WaaSMedicSvc", "WbioSrvc", "WerSvc", "wisvc", "WMPNetworkSvc", 
    "WpnService", "WSearch", "wuauserv", "XblAuthManager", "XblGameSave", 
    "XboxGipSvc", "XboxNetApiSvc"
    ) | Sort-Object -Unique

    foreach ($service in $services) {

        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue

        if (-not $svc) {
            Write-Host "Service not installed: $service" -ForegroundColor Yellow
            continue
        }

        try {

            if ($svc.StartType -eq "Disabled") {
                Set-Service -Name $service -StartupType Manual
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
        "Microsoft.XboxGameCallableUI",
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

$btnGameMode = New-Object System.Windows.Forms.Button
$btnGameMode.Text = "Enable Game Mode" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xE2,0x9A,0xA1))
$btnGameMode.Size = New-Object System.Drawing.Size(230, 40)
$btnGameMode.Location = New-Object System.Drawing.Point(65, 20)
$btnGameMode.Add_Click({ Enable-GameMode })
$btnGameMode.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnGameMode.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnGameMode.FlatAppearance.BorderSize = 0
$tooltipGameMode = New-Object System.Windows.Forms.ToolTip
$tooltipGameMode.SetToolTip($btnGameMode, "Click to enable Game Mode for better performance.")
$btnGameMode.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 15, [System.Drawing.FontStyle]::Regular)

$btnClean = New-Object System.Windows.Forms.Button
$btnClean.Text = "Clean Windows" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x97,0x91))
$btnClean.Size = New-Object System.Drawing.Size(150, 40)
$btnClean.Location = New-Object System.Drawing.Point(10, 80)
$btnClean.Add_Click({ Clean-Windows })
$btnClean.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClean.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnClean.FlatAppearance.BorderSize = 0
$tooltipClean = New-Object System.Windows.Forms.ToolTip
$tooltipClean.SetToolTip($btnClean, "Click to clean Windows.")
$btnClean.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

$btnNetwork = New-Object System.Windows.Forms.Button
$btnNetwork.Text = "Optimize Network" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x8C,0x90))
$btnNetwork.Size = New-Object System.Drawing.Size(150, 40)
$btnNetwork.Location = New-Object System.Drawing.Point(10, 130)
$btnNetwork.Add_Click({ Optimize-Network })
$btnNetwork.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnNetwork.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnNetwork.FlatAppearance.BorderSize = 0
$tooltipNetwork = New-Object System.Windows.Forms.ToolTip
$tooltipNetwork.SetToolTip($btnNetwork, "Click to optimize network settings.")
$btnNetwork.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

$btnRepair = New-Object System.Windows.Forms.Button
$btnRepair.Text = "Repair Windows" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x94,0xA7))
$btnRepair.Size = New-Object System.Drawing.Size(150, 40)
$btnRepair.Location = New-Object System.Drawing.Point(195, 130)
$btnRepair.Add_Click({ Repair-Windows })
$btnRepair.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRepair.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnRepair.FlatAppearance.BorderSize = 0
$tooltipRepair = New-Object System.Windows.Forms.ToolTip
$tooltipRepair.SetToolTip($btnRepair, "Click to repair Windows system files.")
$btnRepair.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

$btnRestore = New-Object System.Windows.Forms.Button
$btnRestore.Text = "Restore Defaults" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xE2,0x9A,0x99, 0xEF,0xB8,0x8F))
$btnRestore.Size = New-Object System.Drawing.Size(150, 40)
$btnRestore.Location = New-Object System.Drawing.Point(195, 80)
$btnRestore.Add_Click({ Restore-Defaults })
$btnRestore.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestore.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnRestore.FlatAppearance.BorderSize = 0
$tooltipRestore = New-Object System.Windows.Forms.ToolTip
$tooltipRestore.SetToolTip($btnRestore, "Click to restore default settings.")
$btnRestore.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

$btnDebloat = New-Object System.Windows.Forms.Button
$btnDebloat.Text = "Debloat" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0xA7,0xB9))
$btnDebloat.Size = New-Object System.Drawing.Size(150, 40)
$btnDebloat.Location = New-Object System.Drawing.Point(10, 180)
$btnDebloat.Add_Click({ Debloat })
$btnDebloat.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnDebloat.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnDebloat.FlatAppearance.BorderSize = 0
$tooltipDebloat = New-Object System.Windows.Forms.ToolTip
$tooltipDebloat.SetToolTip($btnDebloat, "Click to remove any Microsoft pre-installed Bloatware.")
$btnDebloat.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

$btnWinOpt = New-Object System.Windows.Forms.Button
$btnWinOpt.Text = "Windows Optimize" + [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xF0,0x9F,0x9A,0x80))
$btnWinOpt.Size = New-Object System.Drawing.Size(150, 40)
$btnWinOpt.Location = New-Object System.Drawing.Point(195, 180)
$btnWinOpt.Add_Click({ Optimize-Win })
$btnWinOpt.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnWinOpt.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$btnWinOpt.FlatAppearance.BorderSize = 0
$tooltipWinOpt = New-Object System.Windows.Forms.ToolTip
$tooltipWinOpt.SetToolTip($btnWinOpt, "Click to apply the latest Windows performance optimizations.")
$btnWinOpt.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)

$proc = New-Object System.Windows.Forms.Label
$proc.Text = "Processes Running:"
$proc.AutoSize = $true
$proc.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 8,[System.Drawing.FontStyle]::Regular)
$proc.Location = New-Object System.Drawing.Point(120, 280)
$Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 500
$Timer.Add_Tick({
    $ProcessCount = (Get-Process | Measure-Object | Select-Object -ExpandProperty Count)
    $proc.Text = "Processes Running: $ProcessCount"
})
$Timer.Start()

$form.Controls.Add($btnGameMode)
$form.Controls.Add($btnClean)
$form.Controls.Add($btnNetwork)
$form.Controls.Add($btnRepair)
$form.Controls.Add($btnRestore)
$form.Controls.Add($btnDebloat)
$form.Controls.Add($btnWinOpt)
$form.Controls.Add($proc)

[void]$form.ShowDialog()
