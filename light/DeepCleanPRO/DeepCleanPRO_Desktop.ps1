$Name = "DeepCleanPRO"
$Url = "https://raw.githubusercontent.com/Cotton059/Light-Help/main/light/DeepCleanPRO/DeepCleanPRO_Tool.ps1"
$Path = "$env:USERPROFILE\Desktop\$Name.lnk"
$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($Path)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -Command `"[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; irm $Url | iex`""
$Shortcut.Save()
$Bytes = [System.IO.File]::ReadAllBytes($Path)
$Bytes[0x15] = $Bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes($Path, $Bytes)
Write-Host "Desktop shortcut created successfully!" -ForegroundColor Green