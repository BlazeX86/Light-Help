<#
Author: Modified for ZeroTier One Auto-Deployment
#>

# ==========================================
# 1. Visual & Environment Setup
# ==========================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "ZeroTier Auto-Deploy Engine | V1.0"

$MenuColor = "Cyan"
$Level1Color = "Cyan"
$Level2Color = "DarkCyan"
$Level3Color = "Magenta"
$Level4Color = "Red"
$Level5Color = "Green"

# ==========================================
# 2. Visual Components
# ==========================================

# Render Top ASCII Banner
function Show-Banner {
    Clear-Host
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |      /_\                                                 |" -ForegroundColor Cyan
    Write-Host " |     ( o )    >>> ZEROTIER DEPLOYER <<<                   |" -ForegroundColor Cyan
    Write-Host " |    /_____\                                               |" -ForegroundColor Cyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |  Task     : ZeroTier One Silent Installation             |" -ForegroundColor DarkCyan
    Write-Host " |  Platform : Windows 10 / 11 Setup                        |" -ForegroundColor DarkCyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

# Render Dynamic Progress Bar (Kept for UI compatibility/future scaling)
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

    # Use Hex character codes to draw blocks for better compatibility
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

# ==========================================
# 3. End Screen & Support Panel
# ==========================================
function Show-EndScreen {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "[SUCCESS] Task completed successfully." -ForegroundColor Green
    
    Write-Host "`n[ACTION] Press ANY KEY to Exit." -ForegroundColor Yellow
    Write-Host ("=" * 60) -ForegroundColor Cyan

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ==============================================================================
# ZeroTier One All-in-One Deployment Script (MSI)
# with Auto-Elevation Engine
# ==============================================================================

# ==========================================
# [Phase 1: Process Mutex & Execution Guard]
# ==========================================
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
        Write-Host "`n[!] Elevation Cancelled or Failed. Administrator rights are required for installations." -ForegroundColor Red
    }
    
    Write-Host "`n[INFO] Relaunching as Administrator..." -ForegroundColor Cyan
    Read-Host "Press Enter to close this window..."
    exit # Exit the non-elevated script immediately
} else {
    Write-ElevLog "Running with Administrator privileges."
}

# ==============================================================================
# [Phase 3: Core Runtime Deployment Logic]
# ==============================================================================

Show-Banner  

# --------------------------------------------------
# 3.1 Global Settings & Preparation
# --------------------------------------------------
# Force TLS 1.2 protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set the unified download location to the system's default "Downloads" folder
$downloadFolder = Join-Path -Path $env:USERPROFILE -ChildPath "Downloads"

Write-Host "`n==================================================" -ForegroundColor Gray
Write-Host "Starting automated deployment tasks..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Gray

# --------------------------------------------------
# 3.2 Deploy ZeroTier One 
# --------------------------------------------------
Write-Host "`n[*] Preparing to deploy ZeroTier One" -ForegroundColor White

$ztUrl = "https://download.zerotier.com/dist/ZeroTier%20One.msi"
$ztInstallerPath = Join-Path -Path $downloadFolder -ChildPath "ZeroTierOne.msi"

# Speedup tweak: Disabling progress bar display significantly improves download speed
$OriginalProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

Write-Host "Downloading ZeroTier One MSI installer..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $ztUrl -OutFile $ztInstallerPath -UseBasicParsing

# Restore progress bar settings
$ProgressPreference = $OriginalProgressPreference

Write-Host "Download complete! Silently installing in the background..." -ForegroundColor Cyan

# Install the MSI silently with standard switches: /i (install), /qn (quiet/no UI), /norestart
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$ztInstallerPath`" /qn /norestart" -Wait -PassThru

# Check installation status (3010 means restart required, considered a success)
if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
    Write-Host "ZeroTier One installed successfully!" -ForegroundColor Green
    
    Write-Host "Verifying and Starting ZeroTier One Service..." -ForegroundColor Cyan
    # Let the system register the service for a brief second before checking
    Start-Sleep -Seconds 2 
    Start-Service -Name "ZeroTier One" -ErrorAction SilentlyContinue
    
    Write-Host "Launching ZeroTier One GUI..." -ForegroundColor Cyan
    # Standard ZeroTier GUI install paths for x64 and x86 architectures
    $ztExe64 = "C:\Program Files (x86)\ZeroTier\One\ZeroTier One.exe"
    $ztExe32 = "C:\Program Files\ZeroTier\One\ZeroTier One.exe"
    
    if (Test-Path $ztExe64) {
        Start-Process -FilePath $ztExe64 -ErrorAction SilentlyContinue
        Write-Host "ZeroTier One GUI launched from x86 directory." -ForegroundColor Green
    } elseif (Test-Path $ztExe32) {
        Start-Process -FilePath $ztExe32 -ErrorAction SilentlyContinue
        Write-Host "ZeroTier One GUI launched from standard directory." -ForegroundColor Green
    } else {
        Write-Host "Could not locate the ZeroTier GUI shortcut, but the background service is running." -ForegroundColor Yellow
    }

} else {
    Write-Host "ZeroTier One installation process ended (Exit Code: $($process.ExitCode))." -ForegroundColor Red
}

# Auto-cleanup
Write-Host "Automatically deleting ZeroTier One installer..." -ForegroundColor Cyan
if (Test-Path $ztInstallerPath) {
    Remove-Item -Path $ztInstallerPath -Force
    Write-Host "ZeroTier One installer cleaned up!" -ForegroundColor Green
}
Write-Host "--------------------------------------------------" -ForegroundColor Gray

Show-EndScreen