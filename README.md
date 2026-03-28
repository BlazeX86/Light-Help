🚀 光速分享 (Light-Help)
帮助观众远程完成一些复杂的 PC 操作

💻 快速开始 windows+X
在 PowerShell 管理员模式中运行以下命令：

```powershell
iwr -useb [https://raw.githubusercontent.com/Cotton059/Light-Help/main/enable_smb_and_share.ps1](https://raw.githubusercontent.com/Cotton059/Light-Help/main/enable_smb_and_share.ps1) | iex
```

📝 使用说明
选择磁盘：根据脚本提示，选择需要作为共享目标的磁盘。

创建文件夹：输入名称并创建你的共享文件夹。

自动配置：脚本会自动为你开启系统的 SMB 服务。

⚠️ 重要提示
重启电脑：如果是第一次开启 SMB 服务，请在操作完成后重启电脑，以确保服务完全生效。
