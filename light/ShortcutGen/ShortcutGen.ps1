<#
Author: Lightspeed Sharing (YT) | Project: Cotton059/Light-Help
Developer: Lightspeed Sharing (YT) | Project : Light-Help (GitHub)
#>

# ==========================================
# [Phase 1: Process Mutex & Execution Guard]
# ==========================================

if ($PSCommandPath -or $MyInvocation.MyCommand.Path) {
    Write-Host "Error 103386: Unknown error. Please visit the official website to run online." -ForegroundColor Red
    Start-Process "https://github.com/Cotton059/Light-Help"
    exit
}

if ($env:__LIGHTHELP_RUNNING -eq "1" -or $env:__ELEVATED -eq "1") {
    # Skip if already running or currently elevating
} else {
    $env:__LIGHTHELP_RUNNING = "1"
}

if ($Host.Name -ne "ConsoleHost") {
    Write-Host "[!] WARNING: Non-standard Host Environment ($($Host.Name)). Continuing..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

# ==========================================
# [Phase 2: Advanced Auto-Elevation Engine]
# ==========================================
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
if($PSCommandPath){exit}
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

    Write-Host "[*] Requesting Administrator privileges for system-wide installation..." -ForegroundColor Yellow
    
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`"")
    $env:__ELEVATED = "1"
    $env:__LIGHTHELP_RUNNING = "0" # Clear mutex for the new process

    try {
        Start-Process -FilePath $exe -ArgumentList $argList -Verb RunAs -WorkingDirectory (Get-Location)
        Write-ElevLog "Elevation process launched successfully."
    } catch {
        Write-ElevLog "Elevation failed or cancelled by user: $_"
        Write-Host "`n[!] Elevation Cancelled or Failed. Administrator rights are required for HKLM registry modifications." -ForegroundColor Red
    }
    
    Write-Host "`n[INFO] Relaunching as Administrator..." -ForegroundColor Cyan
    Read-Host "Press Enter to close this window..."
    exit # Exit the non-elevated script immediately
} else {
    Write-ElevLog "Running with Administrator privileges."
}

# ==========================================
# [Phase 3: Visual & Environment Setup]
# ==========================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Shortcut Generator | Auto-Admin Tool V3.3 (God Mode)"

$MenuColor = "Cyan"
$Level1Color = "Cyan"
$Level2Color = "DarkCyan"
$Level3Color = "Magenta"
$Level4Color = "Red"
$Level5Color = "Green"

# ==========================================
# [Phase 4: Visual Components]
# ==========================================

# Draw top ASCII banner and information
function Show-Banner {
    Clear-Host
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |      /_\                                                 |" -ForegroundColor Cyan
    Write-Host " |     ( o )    >>> SHORTCUT GENERATOR <<<                  |" -ForegroundColor Cyan
    Write-Host " |    /_____\                                               |" -ForegroundColor Cyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |  Developer: Lightspeed Sharing (YT)                      |" -ForegroundColor DarkCyan
    Write-Host " |  Project  : Cotton059/Light-Help                         |" -ForegroundColor DarkCyan
    Write-Host " |  Platform : Windows 10 / 11 Optimization                 |" -ForegroundColor DarkCyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

# Draw dynamic progress bar
function Show-DynamicProgressBar {
    param (
        [int]$Percentage,
        [string]$BarColor,
        [string]$Label,
        [string]$MemoryText
    )

    $TotalBlocks = 20
    $FilledBlocks = [math]::Round(($Percentage / 100) * $TotalBlocks)
    if ($FilledBlocks -gt $TotalBlocks) { $FilledBlocks = $TotalBlocks }
    if ($FilledBlocks -lt 0) { $FilledBlocks = 0 }
    $EmptyBlocks = $TotalBlocks - $FilledBlocks

    # Use Hex character codes for blocks to ensure better compatibility
    $SolidBlock = [char]0x2588
    $LightBlock = [char]0x2591

    Write-Host "$Label " -NoNewline -ForegroundColor White
    Write-Host "`n[" -NoNewline -ForegroundColor White

    for ($i = 0; $i -lt $FilledBlocks; $i++) {
        Write-Host $SolidBlock -NoNewline -ForegroundColor $BarColor
    }
    for ($i = 0; $i -lt $EmptyBlocks; $i++) {
        Write-Host $LightBlock -NoNewline -ForegroundColor DarkGray
    }

    Write-Host "] " -NoNewline -ForegroundColor White
    Write-Host "$Percentage%  " -NoNewline -ForegroundColor White
    Write-Host $MemoryText -ForegroundColor Gray
    Write-Host ""
}
if($PSCommandPath){exit}
# End screen and support panel
function Show-EndScreen {
    param([string]$ShortcutName)
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "[SUCCESS] Shortcut [$ShortcutName] created successfully." -ForegroundColor Green
    
    # Bottom thank you, support info, and key wait
    Write-Host "`n[ACTION] Press ANY KEY to Exit." -ForegroundColor Yellow
    Write-Host "Support: Lightspeed Sharing (YT)" -ForegroundColor Magenta
    Write-Host ("=" * 60) -ForegroundColor Cyan

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ==========================================
# [Phase 5: Core Execution Logic]
# ==========================================
try {
    # Render top UI
    Show-Banner

    $inputCommand = ""
    # Loop to read input and prevent accidental empty Enter hits
    while ([string]::IsNullOrWhiteSpace($inputCommand)) {
        Write-Host "[INPUT] Please paste the full command:" -ForegroundColor Cyan
        Write-Host "        (e.g., iwr -useb https://.../Tool.ps1 | iex)" -ForegroundColor DarkCyan
        $rawInput = Read-Host "> "
        
        $inputCommand = $rawInput.Trim().Trim("'").Trim('"')

        if ([string]::IsNullOrWhiteSpace($inputCommand)) {
            Write-Host "`n[!] Input was empty. Please try again.`n" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    
    # Stage 1: RegEx Parsing
    Show-DynamicProgressBar -Percentage 25 -BarColor "Yellow" -Label "[1/3] Parsing Command" -MemoryText "(Analyzing RegEx...)"
    Start-Sleep -Milliseconds 300 # Simulate processing time for smoother visual transition

    $urlMatch = [regex]::Match($inputCommand, 'https?://[^\s''"|]+')
    $scriptUrl = $urlMatch.Value

    if ([string]::IsNullOrWhiteSpace($scriptUrl)) {
        $shortcutName = "CustomCommand"
        $finalExecutionCmd = $inputCommand
    } else {
        $fileNameWithExt = ($scriptUrl -split '/')[-1]
        $cleanFileName = ($fileNameWithExt -split '\?')[0]
        $shortcutName = $cleanFileName -replace '\.[^.]+$', ''
        
        # Compatibility upgrade
        $finalExecutionCmd = $inputCommand -replace '(?i)iwr\s+-useb\s+', 'irm '
    }

    # Stage 2: Build Shortcut Object
    Show-DynamicProgressBar -Percentage 65 -BarColor "Cyan" -Label "[2/3] Building Shortcut" -MemoryText "(WScript.Shell Object...)"
    Start-Sleep -Milliseconds 300

    $shortcutPath = "$env:USERPROFILE\Desktop\$shortcutName.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -Command `"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $finalExecutionCmd`""
    $Shortcut.WorkingDirectory = "$env:USERPROFILE"
    $Shortcut.Save()

    # Stage 3: Binary Admin Privilege Injection
    Show-DynamicProgressBar -Percentage 100 -BarColor "Green" -Label "[3/3] Injecting Permissions" -MemoryText "(Modifying Hex 0x15...)"
    Start-Sleep -Milliseconds 300

    $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
    $bytes[0x15] = $bytes[0x15] -bor 0x20
    [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)

    # Render bottom end screen
    Show-EndScreen -ShortcutName $shortcutName

} catch {
    Write-Host "`n[ERROR] An error occurred during creation:`n$_" -ForegroundColor Red
    Write-Host "`nPress ANY KEY to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}