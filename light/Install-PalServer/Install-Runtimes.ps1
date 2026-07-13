<#
Author: Lightspeed Sharing (YT) | Project: Cotton059/Light-Help
Developer: Lightspeed Sharing (YT) | Project : Light-Help (GitHub)
#>

# ==========================================
# 1. Visual & Environment Setup
# ==========================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Runtime Auto-Deploy Engine | V1.0"

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
    Write-Host " |     ( o )    >>> RUNTIME DEPLOYER <<<                    |" -ForegroundColor Cyan
    Write-Host " |    /_____\                                               |" -ForegroundColor Cyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |  Developer: Lightspeed Sharing (YT)                      |" -ForegroundColor DarkCyan
    Write-Host " |  Project  : Cotton059/Light-Help                         |" -ForegroundColor DarkCyan
    Write-Host " |  Platform : Windows 10 / 11 Runtime Setup                |" -ForegroundColor DarkCyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

# Render Dynamic Progress Bar
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
    
    # Footer message and key press wait
    Write-Host "`n[ACTION] Press ANY KEY to return to the Main Menu or Exit." -ForegroundColor Yellow
    Write-Host "Support: Lightspeed Sharing (YT)" -ForegroundColor Magenta
    Write-Host ("=" * 60) -ForegroundColor Cyan

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ==============================================================================
# Runtime All-in-One Deployment Script (Microsoft Visual C++ & DirectX)
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

Show-Banner  # <-- Visual Integration: Call UI Banner here

# --------------------------------------------------
# 3.1 Global Settings & Preparation
# --------------------------------------------------
# Force TLS 1.2 protocol (prevents connection issues with Microsoft servers)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set the unified download location to the system's default "Downloads" folder
$downloadFolder = Join-Path -Path $env:USERPROFILE -ChildPath "Downloads"

Write-Host "`n==================================================" -ForegroundColor Gray
Write-Host "Starting automated runtime deployment tasks..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Gray

# --------------------------------------------------
# 3.2 Deploy Microsoft Visual C++ Redistributable
# --------------------------------------------------
Write-Host "`n[1/2] Preparing to deploy Microsoft Visual C++ Redistributable" -ForegroundColor White

$vcUrls = @{
    "vc_redist.x64.exe" = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    "vc_redist.x86.exe" = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
}

foreach ($fileName in $vcUrls.Keys) {
    $url = $vcUrls[$fileName]
    $installerPath = Join-Path -Path $downloadFolder -ChildPath $fileName

    Write-Host "Spoofing Chrome browser and downloading $fileName via curl.exe..." -ForegroundColor Cyan
    
    # Call Windows built-in curl.exe to bypass CDN limits
    curl.exe -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -# -o $installerPath $url

    Write-Host "Download complete! Silently installing $fileName in the background..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait -PassThru

    # Check installation status (3010 means restart required, considered a success)
    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
        Write-Host "$fileName installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "$fileName installation process ended (Exit Code: $($process.ExitCode))." -ForegroundColor Yellow
    }

    # Auto-cleanup
    Write-Host "Automatically deleting $fileName installer..." -ForegroundColor Cyan
    if (Test-Path $installerPath) {
        Remove-Item -Path $installerPath -Force
        Write-Host "$fileName installer cleaned up!" -ForegroundColor Green
    }
    Write-Host "--------------------------------------------------" -ForegroundColor Gray
}

# --------------------------------------------------
# 3.3 Deploy DirectX End-User Runtime Web Installer
# --------------------------------------------------
Write-Host "`n[2/2] Preparing to deploy DirectX End-User Runtime" -ForegroundColor White

$dxUrl = "https://download.microsoft.com/download/1/7/1/1718ccc4-6315-4d8e-9543-8e28a4e18c4c/dxwebsetup.exe"
$dxInstallerPath = Join-Path -Path $downloadFolder -ChildPath "dxwebsetup.exe"

# Speedup tweak: Disabling progress bar display significantly improves Invoke-WebRequest download speed
$OriginalProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

Write-Host "Downloading DirectX Web Installer..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $dxUrl -OutFile $dxInstallerPath -UseBasicParsing

# Restore progress bar settings
$ProgressPreference = $OriginalProgressPreference

Write-Host "Download complete! Silently installing in the background (requires network access)..." -ForegroundColor Cyan
$process = Start-Process -FilePath $dxInstallerPath -ArgumentList "/Q" -Wait -PassThru

# Check installation status
if ($process.ExitCode -eq 0) {
    Write-Host "DirectX installed successfully!" -ForegroundColor Green
} else {
    Write-Host "DirectX installation process ended (Exit Code: $($process.ExitCode))." -ForegroundColor Yellow
}

# Auto-cleanup
Write-Host "Automatically deleting DirectX installer..." -ForegroundColor Cyan
if (Test-Path $dxInstallerPath) {
    Remove-Item -Path $dxInstallerPath -Force
    Write-Host "DirectX installer cleaned up!" -ForegroundColor Green
}
Write-Host "--------------------------------------------------" -ForegroundColor Gray

Show-EndScreen  # <-- Visual Integration: Call End Screen here