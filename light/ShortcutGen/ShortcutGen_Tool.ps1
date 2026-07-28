if($PSCommandPath){Write-Host "Unknown error [103386]. Please visit the official homepage to run it online." -f Red; Start-Process "https://github.com/Cotton059/Light-Help"; exit}

$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

if($PSCommandPath){exit}

$DownloadURL = 'https://raw.githubusercontent.com/Cotton059/Light-Help/main/light/ShortcutGen/ShortcutGen.ps1'

$rand = Get-Random -Maximum 99999999

Write-Host "[*] Launching ShortcutGen Engine..." -ForegroundColor Cyan

try {
    Write-Host "[+] Downloading from GitHub..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing
    
    $content = "# ID: $rand `r`n" + $response.Content
    
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($content)
    $encodedText = [Convert]::ToBase64String($bytes)
    
    Write-Host "[+] Running Clean Task..." -ForegroundColor Green
    Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedText" -Wait
}
catch {
    Write-Host "`n[!] ERROR: " -ForegroundColor Red -NoNewline
    Write-Host $_.Exception.Message -ForegroundColor White
    Write-Host "[!] The script will stop to prevent crash." -ForegroundColor Yellow
}
finally {
	Write-Host "`n[*] Done! Press 'Y' for YT: Lightspeed Sharing, or any other key to exit..." -ForegroundColor Magenta -NoNewline
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    if ($key -match 'y|Y') {
    Start-Process "https://www.youtube.com/channel/UCz1AlF-BnyirJqrmN78mk5Q"
}
}
