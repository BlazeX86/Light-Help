if ($env:__LIGHTHELP_RUNNING -eq "1" -or $env:__ELEVATED -eq "1") {
} else {
    $env:__LIGHTHELP_RUNNING = "1"
}

if ($Host.Name -ne "ConsoleHost") {
    Write-Host "[!] WARNING: Non-standard Host Environment ($($Host.Name)). Continuing..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
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
        Write-Host "[!] FATAL: Memory execution (iex) detected or path unknown." -ForegroundColor Red
        Write-Host "[!] ACTION REQUIRED: Please save as .ps1 and run, or start PowerShell as Admin first." -ForegroundColor Red
        Read-Host "`nPress Enter to exit..."
        exit
    }

    $shell = Get-CurrentShell
    $exe = if ($shell -eq "pwsh") { "pwsh.exe" } else { "powershell.exe" }

    if ($exe -eq "pwsh.exe" -and -not (Get-Command pwsh.exe -ErrorAction SilentlyContinue)) {
        $exe = "powershell.exe"
        Write-ElevLog "Fallback to powershell.exe triggered."
    }

    Write-Host "[*] Requesting Administrator privileges for system-wide installation..." -ForegroundColor Yellow
    
    $argList = @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`"")
    $env:__ELEVATED = "1"
    $env:__LIGHTHELP_RUNNING = "0"

    try {
        Start-Process -FilePath $exe -ArgumentList $argList -Verb RunAs -WorkingDirectory (Get-Location)
        Write-ElevLog "Elevation process launched successfully."
        Stop-Process -Id $PID
    } catch {
        Write-ElevLog "Elevation failed or cancelled by user: $_"
        Write-Host "`n[!] Elevation Cancelled or Failed. Administrator rights are required for HKLM registry modifications." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
} else {
    Write-ElevLog "Running with Administrator privileges."
}

$Name = "MultiInstance"
$Url = "https://raw.githubusercontent.com/Cotton059/Light-Help/main/light/MultiInstance/MultiInstance_Tool.ps1"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$Path = "$DesktopPath\$Name.lnk"

Write-Host "[*] Generating desktop shortcut..." -ForegroundColor Cyan

$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($Path)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -Command `"[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; irm $Url | iex`""
$Shortcut.Save()

Start-Sleep -Milliseconds 200

try {
    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    $Bytes[0x15] = $Bytes[0x15] -bor 0x20
    [System.IO.File]::WriteAllBytes($Path, $Bytes)
    Write-Host "[+] Desktop shortcut created successfully with Admin trigger at: $Path" -ForegroundColor Green
} catch {
    Write-Host "[!] Error applying Admin bytes to LNK file: $_" -ForegroundColor Red
}

Write-Host "`n[INFO] All tasks completed." -ForegroundColor DarkCyan
Read-Host "Press Enter to exit"
