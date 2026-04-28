<#
.SYNOPSIS
    Generates a desktop shortcut for PowerShell with forced Administrator privileges.
.AUTHOR
    Author: Lightspeed Sharing (YT) | Project: Cotton059/Light-Help | Developer: Lightspeed Sharing (YT) | Project : Light-Help (GitHub)
.VERSION
    2.2 (Improved Stability)
#>

# Clear console for a clean UI
Clear-Host

# 1. Display UI Banner (Neon Tech / Minimalist Style)
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "             PowerShell Admin Shortcut Generator             " -ForegroundColor White
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host " Author: Lightspeed Sharing (YT) " -ForegroundColor Gray
Write-Host " Repository: Cotton059/Light-Help " -ForegroundColor Gray
Write-Host "=============================================================`n" -ForegroundColor Cyan

# 2. Pause and wait for user execution using RawUI for reliability
Write-Host " Press any key to execute the script..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`n[~] Initializing configuration..." -ForegroundColor Cyan

$desktopPath = [Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktopPath "PowerShell (Admin).lnk"

# ✅ 修复1：使用更稳定的 PowerShell 路径获取方式
$psPath = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
if (-not $psPath) {
    $psPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
}

# 3. Create shortcut
Write-Host "[~] Building target shortcut..." -ForegroundColor Cyan

# ✅ 修复2：检测是否已存在快捷方式
if (Test-Path $shortcutPath) {
    Write-Host "[!] Shortcut already exists. Overwriting..." -ForegroundColor Yellow
}

$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $psPath

# ✅ 修复3：避免使用未解析的环境变量
$shortcut.WorkingDirectory = $env:USERPROFILE

$shortcut.Description = "Windows PowerShell (Run as Administrator)"
$shortcut.Save()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($wshShell) | Out-Null

# 4. Inject Administrator flag
Write-Host "[~] Injecting binary privileges..." -ForegroundColor Cyan

try {
    $fileStream = New-Object System.IO.FileStream($shortcutPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
    $fileStream.Seek(21, [System.IO.SeekOrigin]::Begin) | Out-Null
    $currentByte = $fileStream.ReadByte()
    
    $newByte = $currentByte -bor 0x20
    
    $fileStream.Seek(21, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fileStream.WriteByte($newByte)

    # ✅ 修复4：更规范释放资源
    $fileStream.Dispose()
    
    Write-Host "[+] SUCCESS: Administrator shortcut created on Desktop." -ForegroundColor Green
}
catch {
    Write-Error "[-] FATAL ERROR: $_"
}

# 5. Outro
Write-Host "`n=============================================================" -ForegroundColor Cyan
Write-Host "         Thanks for supporting Lightspeed Sharing!           " -ForegroundColor Green
Write-Host "=============================================================`n" -ForegroundColor Cyan

# 6. Robust prevent auto-close (supports all environments)
Write-Host " Press any key to exit the window..." -ForegroundColor Yellow

try {
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Read-Host
}