$UserInfo = [PSCustomObject]@{
    "Username"   = $env:USERNAME
    "IP_Address" = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress -join " / "
}

Write-Host "--- System User Information ---" -ForegroundColor Cyan
$UserInfo | Format-List

Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = [Console]::ReadKey()