if ($PSCommandPath -or $MyInvocation.MyCommand.Path) {
    Write-Host "Error 103386: Unknown error. Please visit the official website to run online." -ForegroundColor Red
    Start-Process "https://github.com/Cotton059/Light-Help"
    exit
}
$EnableVerification = $true

Clear-Host
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Cyan"
Clear-Host

Write-Host "=====================================================" -ForegroundColor DarkCyan
Write-Host " [ Lightspeed Sharing ] - Automation Terminal" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor DarkCyan
Write-Host ""

[Net.ServicePointManager]::Expect100Continue = $false

if ($EnableVerification) {
    $CacheFile = "$env:PUBLIC\InviteCode.txt"
    $InviteCode = $null
    $IsVerified = $false

    if (Test-Path $CacheFile) {
        $InviteCode = Get-Content -Path $CacheFile -TotalCount 1
        if (-not [string]::IsNullOrWhiteSpace($InviteCode)) {
            $InviteCode = $InviteCode.Trim()
            
            $LastModTime = (Get-Item $CacheFile).LastWriteTime
            if (((Get-Date) - $LastModTime).TotalSeconds -lt 5) {
                Write-Host "[*] Fast-reload detected. Reusing active session to prevent double billing." -ForegroundColor DarkGray
                $IsVerified = $true
            } else {
                Write-Host "[*] Discovered cached authorization code." -ForegroundColor DarkGray
            }
        }
    }

    while ($IsVerified -eq $false) {
        if ([string]::IsNullOrWhiteSpace($InviteCode)) {
            $InviteCode = Read-Host "[?] Enter Terminal Authorization Code (Invite Code)"
        }

        if ([string]::IsNullOrWhiteSpace($InviteCode)) {
            Write-Host "`n[-] Authorization code cannot be empty. Process terminated." -ForegroundColor Red
            Start-Sleep -Seconds 2
            exit
        }

        Write-Host "`n[*] Sending verification request to Lightspeed Relay Server..." -ForegroundColor DarkGray

        $ApiUrl = "https://invite-code-api.q103495201.workers.dev/"
        $Body = @{ code = [string]$InviteCode } | ConvertTo-Json

        try {
            $Response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $Body -ContentType "application/json" -ErrorAction Stop
            
            if ($Response.success -eq $true) {
                Set-Content -Path $CacheFile -Value $InviteCode -Force
                $IsVerified = $true

                Write-Host "[+] Authorization granted! (Node: Group $($Response.group))" -ForegroundColor Green
                Write-Host "[!] Remaining uses for this code: $($Response.codeRemaining) / $($Response.codeMax)" -ForegroundColor Yellow
                Write-Host "[!] Total calls for current channel: $($Response.groupTotalUses)`n" -ForegroundColor DarkCyan
            } else {
                Write-Host "[-] Access denied: $($Response.message)" -ForegroundColor Red
                Write-Host "[-] Please enter a valid authorization code.`n" -ForegroundColor DarkGray
                
                $InviteCode = $null
                if (Test-Path $CacheFile) {
                    Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {
            Write-Host "[-] Failed to connect to relay server. Check your network or proxy settings." -ForegroundColor Red
            Start-Sleep -Seconds 3
            exit
        }
    }
} else {
    Write-Host "[+] Offline open-source edition activated (Unrestricted mode)." -ForegroundColor Green
    Write-Host "[!] Thank you for supporting the Lightspeed Sharing channel." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "[*] Loading core architecture..." -ForegroundColor Cyan
Start-Sleep -Seconds 1
Write-Host "[+] Environment ready. Initializing execution.`n" -ForegroundColor Green
if ($env:__LIGHTHELP_RUNNING -eq "1" -or $env:__ELEVATED -eq "1") {
} else {
    $env:__LIGHTHELP_RUNNING = "1"
}

if ($Host.Name -ne "ConsoleHost") {
    Write-Host "[!] WARNING: Non-standard Host Environment ($($Host.Name)). Continuing..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

    $p = $MyInvocation.MyCommand.Definition
    if (Test-Path $p) {
        $c = Get-Content $p -Raw
        $k = (@(72,116,121,121,116,115,53,58,62,52,81,110,108,109,121,50,77,106,113,117) | ForEach-Object { [char]($_ - 5) }) -join ''
        if ($c -cnotmatch [regex]::Escape($k)) {
            Write-Host "Exception calling `"CreateInstance`" with `"1`" argument(s): `"Retrieving the COM class factory for component with CLSID {B196B287-BAB4-101A-B69C-00AA00341D07} failed due to the following error: 80040154 Class not registered (Exception from HRESULT: 0x80040154 (REGDB_E_CLASSNOTREG)).`"" -ForegroundColor Red
            Write-Host "At line:14 char:5" -ForegroundColor Red
            Write-Host "+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" -ForegroundColor Red
            Write-Host "    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException" -ForegroundColor Red
            Write-Host "    + FullyQualifiedErrorId : COMException" -ForegroundColor Red
            Start-Sleep -Seconds 3
            Exit
        }
    }
function Write-ElevLog {
    param ([string]$Message)
    try {
        $logPath = Join-Path $env:TEMP "github_zh_elevation.log"
        $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "[$time] $Message"
    } catch {}
}

function Get-CurrentShell {
    try { if ($PSVersionTable.PSEdition -eq "Core") { "pwsh" } else { "powershell" } } catch { "powershell" }
}

$isAdmin = try {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch { $false }

if (-not $isAdmin) {
    Write-ElevLog "User is not elevated. Initiating elevation sequence."
    
    $ScriptPath = $PSCommandPath
    if ([string]::IsNullOrWhiteSpace($ScriptPath)) { $ScriptPath = $MyInvocation.MyCommand.Path }

    if ([string]::IsNullOrWhiteSpace($ScriptPath)) {
        Write-Host "[!] FATAL: Memory execution detected or path unknown." -ForegroundColor Red
        Write-Host "[!] ACTION REQUIRED: Please save as .ps1 and run." -ForegroundColor Red
        Start-Sleep -Seconds 5
        exit
    }

    $shell = Get-CurrentShell
    $exe = if ($shell -eq "pwsh") { "pwsh.exe" } else { "powershell.exe" }

    if ($exe -eq "pwsh.exe" -and -not (Get-Command pwsh.exe -ErrorAction SilentlyContinue)) {
        $exe = "powershell.exe"
        Write-ElevLog "Fallback to powershell.exe triggered."
    }

    Write-Host "[*] Requesting Administrator privileges for environment setup..." -ForegroundColor Yellow
    
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`"")
    $env:__ELEVATED = "1"
    $env:__LIGHTHELP_RUNNING = "0"

    try {
        Start-Process -FilePath $exe -ArgumentList $argList -Verb RunAs -WorkingDirectory (Get-Location)
        Write-ElevLog "Elevation process launched successfully."
    } catch {
        Write-ElevLog "Elevation failed or cancelled by user: $_"
        Write-Host "`n[!] Elevation Cancelled or Failed." -ForegroundColor Red
    }
    
    Write-Host "`n[INFO] Relaunching as Administrator..." -ForegroundColor Cyan
    Read-Host "Press Enter to close this window..."
    exit
} else {
    Write-ElevLog "Running with Administrator privileges."
}

Clear-Host
$Host.UI.RawUI.WindowTitle = "Universal App Multi-Opener v14"

function Show-Banner {
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |      /_\                                                 |" -ForegroundColor Cyan
    Write-Host " |     ( o )    >>> MultiInstance <<<                       |" -ForegroundColor Cyan
    Write-Host " |    /_____\                                               |" -ForegroundColor Cyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |  Developer: Lightspeed Sharing (YT)                      |" -ForegroundColor DarkCyan
    Write-Host " |  Project  : Cotton059/Light-Help                         |" -ForegroundColor DarkCyan
    Write-Host " |  Platform : Windows 10 / 11 Optimization                 |" -ForegroundColor DarkCyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
}

Show-Banner
Write-Host ""
Write-Host "[!] Drag & Drop is blocked by Windows Administrator limits." -ForegroundColor DarkGray
Write-Host ""

$inputPath = Read-Host "Paste path manually, or press [Enter] to open File Browser"

if ([string]::IsNullOrWhiteSpace($inputPath)) {
    Add-Type -AssemblyName System.Windows.Forms
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Title = "Select Target Application (.exe or .lnk)"
    $fileBrowser.Filter = "Applications & Shortcuts (*.exe;*.lnk)|*.exe;*.lnk|All Files (*.*)|*.*"
    $fileBrowser.ShowHelp = $true
    
    $dialogResult = $fileBrowser.ShowDialog()
    
    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $targetPath = $fileBrowser.FileName
    } else {
        Write-Host "[-] No file selected. Exiting..." -ForegroundColor Red
        Start-Sleep -Seconds 3
        exit
    }
} else {
    $targetPath = $inputPath.Trim('"').Trim("'")
}

$targetPath = [System.Environment]::ExpandEnvironmentVariables($targetPath)

if (-not (Test-Path $targetPath)) {
    Write-Host "[-] File not found." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}

if ($targetPath.EndsWith(".lnk", [System.StringComparison]::OrdinalIgnoreCase)) {
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($targetPath)
    $targetPath = [System.Environment]::ExpandEnvironmentVariables($shortcut.TargetPath)
    Write-Host "[*] Resolved shortcut to: $targetPath" -ForegroundColor DarkGray
    
    if (-not (Test-Path $targetPath)) {
        Write-Host "[-] Target executable from shortcut not found." -ForegroundColor Red
        Start-Sleep -Seconds 3
        exit
    }
}

Write-Host "[+] Target: $targetPath" -ForegroundColor Green
$targetName = [System.IO.Path]::GetFileNameWithoutExtension($targetPath)

Write-Host ""
Write-Host "Select Operation Mode:" -ForegroundColor Yellow
Write-Host "1. Standard Concurrency (For Mutex apps, shares user data)" -ForegroundColor White
Write-Host "2. Data Isolation Sandbox (For Electron/PikPak, fresh profile)" -ForegroundColor Cyan
$modeChoice = Read-Host "> [Default: 1]"
if ([string]::IsNullOrWhiteSpace($modeChoice)) { $modeChoice = "1" }

while ($true) {
    $baselineInstances = Get-Process -Name $targetName -ErrorAction SilentlyContinue
    $baselineCount = if ($baselineInstances) { if ($baselineInstances -is [array]) { $baselineInstances.Count } else { 1 } } else { 0 }

    if ($baselineCount -gt 0) {
        Write-Host ""
        Write-Host "[!] Detected $baselineCount running instance(s) of $targetName." -ForegroundColor Yellow
        Write-Host "    Existing instances hold Mutex and local File Locks." -ForegroundColor Yellow
        Write-Host "    You MUST close the application manually and gracefully." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "    1. Please close the app normally (check system tray too)." -ForegroundColor Cyan
        Write-Host "    2. Press [Enter] to re-scan memory." -ForegroundColor Cyan
        Write-Host "    3. Type 'Q' and press [Enter] to quit script." -ForegroundColor Cyan
        
        $userChoice = Read-Host ">"
        
        if ($userChoice -eq "Q" -or $userChoice -eq "q") {
            Write-Host "[-] Operation aborted by user." -ForegroundColor Red
            Start-Sleep -Seconds 3
            exit
        }
        
        Write-Host "[*] Re-scanning memory..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
    } else {
        break
    }
}

Write-Host ""
$inputArgs = Read-Host "Enter startup arguments (Press [Enter] to skip)"

Write-Host ""
$inputCount = Read-Host "Enter instance count (2-10) [Default: 2]"

if ([string]::IsNullOrWhiteSpace($inputCount)) { 
    $instanceCount = 2 
} else {
    try {
        $instanceCount = [int]$inputCount
        if ($instanceCount -lt 2 -or $instanceCount -gt 10) { 
            $instanceCount = 2 
        }
    } catch { 
        $instanceCount = 2 
    }
}

Write-Host ""
Write-Host "[*] Launching $instanceCount instances..." -ForegroundColor Cyan

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $targetPath
if (-not [string]::IsNullOrWhiteSpace($inputArgs)) { $psi.Arguments = $inputArgs }
$psi.WorkingDirectory = (Split-Path $targetPath -Parent)

if ($modeChoice -eq "2") {
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
} else {
    $psi.UseShellExecute = $true
}

for ($i = 0; $i -lt $instanceCount; $i++) {
    try {
        if ($modeChoice -eq "2") {
            $sandboxDir = Join-Path $env:TEMP "AppSandbox_$targetName\_$i"
            $roaming = Join-Path $sandboxDir "AppData\Roaming"
            $local = Join-Path $sandboxDir "AppData\Local"
            
            $null = New-Item -ItemType Directory -Force -Path $roaming
            $null = New-Item -ItemType Directory -Force -Path $local
            
            $psi.EnvironmentVariables["APPDATA"] = $roaming
            $psi.EnvironmentVariables["LOCALAPPDATA"] = $local
            $psi.EnvironmentVariables["USERPROFILE"] = $sandboxDir
        }
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {}
}

Write-Host "[*] Waiting for processes to settle..." -ForegroundColor DarkGray
Start-Sleep -Seconds 3

$currentInstances = Get-Process -Name $targetName -ErrorAction SilentlyContinue
$currentCount = if ($currentInstances) { if ($currentInstances -is [array]) { $currentInstances.Count } else { 1 } } else { 0 }

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "[SUCCESS] Task completed." -ForegroundColor Green
if($PSCommandPath){exit}
if ($currentCount -eq $instanceCount -or $currentCount -gt 1) {
    Write-Host "[ACTION] $currentCount instances/processes successfully spawned." -ForegroundColor Yellow
} else {
    Write-Host "[ACTION] Single instance limits may apply. Check active windows." -ForegroundColor Yellow
}

Write-Host "[INFO] Released: Universal App Multi-Opener v14" -ForegroundColor White
Write-Host "Support: Lightspeed Sharing (YT)" -ForegroundColor Magenta
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")