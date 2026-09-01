if ($PSCommandPath -or $MyInvocation.MyCommand.Path) {
    Write-Host "Error 103386: Unknown error. Please visit the official website to run online." -ForegroundColor Red
    Start-Process "https://github.com/Cotton059/Light-Help"
    exit
}

$EnableVerification = $false

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

param (
    [switch]$Silent
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "SilentlyContinue"

if($PSCommandPath){exit}

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |                                                          |" -ForegroundColor Cyan
    Write-Host " |     >>> WINDOWS DEEP CLEANING ENGINE PRO(DUAL-CORE) <<<  |" -ForegroundColor Green
    Write-Host " |                                                          |" -ForegroundColor Cyan
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host " |            Author: Lightspeed Sharing (YT)               |" -ForegroundColor Yellow
    Write-Host " |            Project: Cotton059/Light-Help                 |" -ForegroundColor Yellow
    Write-Host " +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[*] Scanning local system for available storage nodes..." -ForegroundColor Cyan
    $validDrives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 }

    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    foreach ($drive in $validDrives) {
        $freeGB = [math]::Round($drive.Free / 1GB, 2)
        $totalGB = [math]::Round($drive.Used / 1GB, 2) + $freeGB
        Write-Host "  [+] Node: $($drive.Name):\  (Free: $freeGB GB / Total: $totalGB GB)" -ForegroundColor DarkGray
    }
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    if (-not $Silent) {
        $driveInput = Read-Host "`n>>> Specify ONE Target Node (e.g., C, D) [Default: C]"
    } else {
        $driveInput = "C"
    }

    if ([string]::IsNullOrWhiteSpace($driveInput)) {
        $targetDrive = "C"
    } else {
        $match = [regex]::Match($driveInput.ToUpper(), "[A-Z]")
        if ($match.Success -and ($validDrives.Name -contains $match.Value)) {
            $targetDrive = $match.Value
        } else {
            Write-Host "[!] Invalid input. Reverting to fallback (C)..." -ForegroundColor Yellow
            $targetDrive = "C"
        }
    }

    if ($targetDrive -eq "C") {
        $baseScanPath = $env:USERPROFILE
        Write-Host " -> Mode: Targeted Profile Sweep ($baseScanPath)" -ForegroundColor DarkGray
    } else {
        $baseScanPath = "$targetDrive`:\"
        Write-Host " -> Mode: Full Physical Drive Sweep ($baseScanPath)" -ForegroundColor DarkGray
    }

    Write-Host "`n[*] Select Cleaning Engine Mode:" -ForegroundColor Cyan
    Write-Host "  [1] SAFE MODE    (Protects Browsers, Office, Creative Tools)" -ForegroundColor Green
    Write-Host "  [2] EXTREME MODE (Unrestricted Matrix Scan, Clears Everything)" -ForegroundColor Red

    if (-not $Silent) {
        $modeInput = Read-Host "`n>>> Enter Mode [1 or 2] (Default: 1)"
    } else {
        $modeInput = "1"
    }

    $isSafeMode = $true
    if ($modeInput -eq "2") {
        $isSafeMode = $false
        Write-Host "`n[+] EXTREME MODE ENGAGED. NO SHIELDS ACTIVE." -ForegroundColor Red
    } else {
        Write-Host "`n[+] SAFE MODE ENGAGED. WHITE-LIST ACTIVE." -ForegroundColor Green
    }

    if (-not $Silent) {
        $scanConsent = Read-Host ">>> Ready to start scan protocol? [Y/n] (Default: Y)"
        if ($scanConsent -ne "" -and $scanConsent -notmatch "^[Yy]$") {
            Write-Host "`n[-] Operation aborted by user." -ForegroundColor Red
            Read-Host "`nPress Enter to return to Main Menu..."
            continue 
        }
    } else {
        Write-Host ">>> Running in SILENT mode. Prompts bypassed." -ForegroundColor DarkGray
    }

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "`n[!] NOTICE: Not running as Administrator." -ForegroundColor Red
        Write-Host "    System-level logs and Temp folders will be skipped.`n" -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
    }

    Write-Host "`n[*] Initializing UNLIMITED scan protocol..." -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    $global:foundTargets = New-Object System.Collections.Generic.List[object]
    $global:totalScanned = 0

    $protectedSuites = "Chrome|Edge|Firefox|Brave|Notion|Obsidian|Evernote|OneNote|Microsoft|Adobe|Office|Code|Discord"
    $targetKeywords = "Temp|Cache|CrashDumps|LogFiles"

    function Invoke-MatrixScan {
        param([string]$CurrentPath, [bool]$SafeMode)
        try {
            $dirs = Get-ChildItem -Path $CurrentPath -Directory -Force -ErrorAction SilentlyContinue
            foreach ($dir in $dirs) {
                $dirPath = $dir.FullName
                
                if ($SafeMode -and ($dirPath -match $protectedSuites)) {
                    continue 
                }

                $global:totalScanned++
                Write-Host " [Scan] $dirPath" -ForegroundColor DarkGray
                
                if ($dir.Name -match $targetKeywords) {
                    Write-Host " [>>>] TARGET LOCKED: $dirPath" -ForegroundColor Yellow
                    $global:foundTargets.Add($dir)
                } else {
                    Invoke-MatrixScan -CurrentPath $dirPath -SafeMode $SafeMode
                }
            }
        } catch {}
    }

    Write-Host " [!] Engaging Matrix Sweep on: $baseScanPath" -ForegroundColor Magenta
    Invoke-MatrixScan -CurrentPath $baseScanPath -SafeMode $isSafeMode

    if ($targetDrive -eq "C" -and $isAdmin) {
        $systemJunkPaths = @(
            "$env:TEMP",
            "$env:WINDIR\Temp",
            "$env:WINDIR\Prefetch",
            "$env:WINDIR\SoftwareDistribution\Download"
        )

        foreach ($sysPath in $systemJunkPaths) {
            $global:totalScanned++
            if (Test-Path $sysPath) {
                $dirItem = Get-Item $sysPath
                Write-Host " [>>>] SYSTEM TARGET: $($dirItem.FullName)" -ForegroundColor Red
                $global:foundTargets.Add($dirItem)
            }
        }
    }

    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    if ($global:foundTargets.Count -eq 0) {
        Write-Host "`n[V] Congratulations! No junk directories found or all within protected zones." -ForegroundColor Green
        if (-not $Silent) { Read-Host "`nPress Enter to return to Main Menu..." }
        continue 
    }

    $formattedTotal = "{0:N0}" -f $global:totalScanned
    Write-Host "`n[*] Analysis Complete! Scanned $formattedTotal paths, locked $($global:foundTargets.Count) junk zones." -ForegroundColor Green

    if ($isSafeMode) {
        Write-Host " -> Protected: Web Browsers, Cloud Notes, Office & Creative Suites skipped." -ForegroundColor Cyan
    } else {
        Write-Host " -> Extreme Mode: ALL matched zones are queued for termination." -ForegroundColor Red
    }

    if (-not $Silent) {
        $confirm = Read-Host ">>> Authorize deep cleaning now? [Y/n] (Default: Y)"
        if ($confirm -ne "" -and $confirm -notmatch "^[Yy]$") {
            Write-Host "`n[-] Cleaning cancelled. No files were deleted." -ForegroundColor DarkGray
            Read-Host "`nPress Enter to return to Main Menu..."
            continue 
        }
    }

    Write-Host "`n[*] Shredding files..." -ForegroundColor Cyan
    $totalFreedBytes = 0

    foreach ($folder in $global:foundTargets) {
        $folderPath = $folder.FullName
        Write-Host "  -> Clearing: $folderPath" -ForegroundColor DarkGray

        $size = (Get-ChildItem -Path $folderPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($null -ne $size) { $totalFreedBytes += $size }

        Remove-Item -Path "$folderPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    $freedMB = [math]::Round($totalFreedBytes / 1MB, 2)
    $freedGB = [math]::Round($totalFreedBytes / 1GB, 2)

    Write-Host "`n=======================================================" -ForegroundColor Cyan
    Write-Host " [OK] TASK COMPLETED!" -ForegroundColor Green

    if ($totalFreedBytes -gt 1GB) {
        Write-Host " [!] Released: $freedGB GB of disk space." -ForegroundColor Yellow
    } elseif ($freedMB -gt 0) {
        Write-Host " [!] Released: $freedMB MB of disk space." -ForegroundColor Yellow
    } else {
        Write-Host " [V] System is already optimized." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host " Support: Lightspeed Sharing (YT)" -ForegroundColor Magenta
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host ""

    if (-not $Silent) { Read-Host "Press Enter to return to Main Menu..." }
}
