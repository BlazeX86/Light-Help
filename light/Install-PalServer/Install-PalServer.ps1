<#
Author: Lightspeed Sharing (YT) | Project: Cotton059/Light-Help
Developer: Lightspeed Sharing (YT) | Project : Light-Help (GitHub)
#>

# ==========================================
# 1. Visual & Environment Setup
# ==========================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "PalServer Auto-Deploy Engine | V1.0"

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
    Write-Host " |     ( o )    >>> PALSERVER DEPLOYER <<<                  |" -ForegroundColor Cyan
    Write-Host " |    /_____\                                               |" -ForegroundColor Cyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |  Developer: Lightspeed Sharing (YT)                      |" -ForegroundColor DarkCyan
    Write-Host " |  Project  : Cotton059/Light-Help                         |" -ForegroundColor DarkCyan
    Write-Host " |  Platform : Windows 10 / 11 Server Setup                 |" -ForegroundColor DarkCyan
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
        Write-Host "`n[!] Elevation Cancelled or Failed. Administrator rights are required for HKLM registry modifications." -ForegroundColor Red
    }
    
    Write-Host "`n[INFO] Relaunching as Administrator..." -ForegroundColor Cyan
    Read-Host "Press Enter to close this window..."
    exit # Exit the non-elevated script immediately
} else {
    Write-ElevLog "Running with Administrator privileges."
}

# ==========================================
# [Phase 3: Palworld Server Setup]
# ==========================================
Show-Banner  # <-- Visual Integration: Call UI Banner here

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "      Palworld Server 1-Click Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Select target drive and create steamcmd folder
$drives = Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB, 2)}}
Write-Host "`nAvailable drives:" -ForegroundColor Yellow
$drives | Format-Table -AutoSize

$validDrives = $drives.Name
$targetDrive = ""

# Prompt user for input and validate
while ($targetDrive -notin $validDrives) {
    $targetDrive = Read-Host "Please enter the drive letter for installation (e.g., C, D, E)"
    $targetDrive = $targetDrive.ToUpper()
}

$installPath = "$targetDrive`:\steamcmd"
Write-Host "`nPreparing to create folder at $installPath..." -ForegroundColor Cyan

if (-not (Test-Path -Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
    Write-Host "Folder created successfully!" -ForegroundColor Green
} else {
    Write-Host "Folder already exists, continuing in this directory." -ForegroundColor Yellow
}

# 2. Change directory to the newly created folder
Set-Location -Path $installPath
Write-Host "Directory changed to: $(Get-Location)" -ForegroundColor Cyan

# 3. Download, extract, and clean up SteamCMD zip file
Write-Host "`nDownloading and extracting SteamCMD..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile "steamcmd.zip"
Expand-Archive -Path "steamcmd.zip" -DestinationPath "." -Force
Remove-Item "steamcmd.zip"
Write-Host "SteamCMD downloaded and extracted successfully!" -ForegroundColor Green

# 4. First run of SteamCMD to install the server
Write-Host "`nInstalling Palworld Server (First run, this may take a while)..." -ForegroundColor Cyan
.\steamcmd.exe +login anonymous +app_update 2394010 validate +quit

# 5. Second run of SteamCMD to validate files
Write-Host "`nValidating server files (Second run)..." -ForegroundColor Cyan
.\steamcmd.exe +login anonymous +app_update 2394010 validate +quit

# 6. Change to PalServer directory and run the executable
$palServerPath = ".\steamapps\common\PalServer"

Write-Host "`nPreparing to start Palworld Server..." -ForegroundColor Cyan
if (Test-Path -Path $palServerPath) {
    Set-Location -Path $palServerPath
    Write-Host "Changed to server directory: $(Get-Location)" -ForegroundColor Cyan
    Write-Host "Starting PalServer.exe! A new console window will appear." -ForegroundColor Green
    
    # Start the server as an independent process
    Start-Process -FilePath ".\PalServer.exe"
} else {
    Write-Host "PalServer directory not found! Download might have failed, please rerun the script." -ForegroundColor Red
}

Show-EndScreen  # <-- Visual Integration: Use visual component for end screen