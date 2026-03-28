@echo off
:: 强制启用 UTF-8，确保远程下载不乱码
chcp 65001 >nul
SETLOCAL ENABLEDELAYEDEXPANSION

:: 自动请求管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

:: --- 变量定义区（修改这里，双引号不要动） ---
set "MY_NAME=光速分享"
set "MY_YT=https://www.youtube.com/@光速分享"
set "MY_GH=https://github.com/Cotton059/Light-Help"

title SMB 1.0 Share Tool
mode con cols=90 lines=32
color 0F

:MainMenu
cls
echo.
echo    =====================================================================================
echo    #                 S M B   1 . 0   一 键 共 享 配 置 工 具 (CMD版)                   #
echo    =====================================================================================
echo    [ 功能 ] : 开启 SMB 1.0 协议、创建文件夹并配置 Everyone 匿名共享权限
echo    [ 作者 ] : %MY_NAME%
echo    [ 主页 ] : %MY_YT%
echo    [ 项目 ] : %MY_GH%
echo    -------------------------------------------------------------------------------------
echo.

:: --- 权限检测 ---
echo    [ 状态检查 ] 正在验证管理员权限...
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo    [ 错误 ] 请右键点击此文件，选择 "以管理员身份运行"！
    echo.
    pause
    exit /b
)
echo    [ 状态检查 ] 权限验证通过。
echo.

:: --- 磁盘扫描 ---
echo    [ 磁盘列表 ] 正在获取可用驱动器...
echo    -------------------------------------------------------------------------------------
set counter=1
for /f "skip=1 tokens=1" %%a in ('wmic logicaldisk get name') do (
    set "item=%%a"
    if not "!item!"=="" (
        set "drive[!counter!]=!item!"
        echo       [!counter!]  驱动器 !item!
        set /a counter+=1
    )
)
echo    -------------------------------------------------------------------------------------
echo.

:: --- 用户输入 ---
set /p driveChoice="    [?] 请输入数字编号 (1, 2, 3...): "
set "driveLetter=!drive[%driveChoice%]!"

if "!driveLetter!"=="" (
    color 0C
    echo    [ 错误 ] 输入无效，程序即将退出。
    timeout /t 3 >nul
    exit /b
)

echo.
set /p shareName="    [?] 请设置共享文件夹的名称 (例如 ShareData): "
set "fullPath=!driveLetter!\!shareName!"

:: --- 执行逻辑 ---
cls
echo.
echo    =====================================================================================
echo    正在执行部署，请稍后... (步骤 1/4 开启协议通常需要 1-3 分钟)
echo    =====================================================================================
echo.

echo    [1/4] 正在启用 SMB 1.0 协议组件...
dism /online /enable-feature /featurename:SMB1Protocol /all /norestart >nul

echo    [2/4] 正在重启网络共享服务...
net stop "lanmanserver" /y >nul 2>&1
net start "lanmanserver" >nul 2>&1

if not exist "!fullPath!" (
    echo    [3/4] 正在创建本地文件夹: !fullPath!
    mkdir "!fullPath!"
)
echo          正在配置磁盘 NTFS 权限 (Everyone)...
icacls "!fullPath!" /grant Everyone:(OI)(CI)F /t /q >nul

echo    [4/4] 正在激活局域网共享广播...
net share "!shareName!"="!fullPath!" /GRANT:everyone,FULL /REMARK:"Auto-shared" >nul

:: --- 结果汇报 ---
echo.
echo    =====================================================================================
if %errorlevel% equ 0 (
    color 0A
    echo    [ 成功 ] 共享部署已完成！
    echo    -------------------------------------------------------------------------------------
    echo      - 访问路径: \\%COMPUTERNAME%\!shareName!
    echo      - 物理路径: !fullPath!
    echo    -------------------------------------------------------------------------------------
    echo    [ 提示 ] 如果这是您第一次开启 SMB 1.0，请务必【重启电脑】使协议生效。
) else (
    color 0C
    echo    [ 失败 ] 创建共享时遇到错误。可能是共享名已存在或被系统策略拦截。
)
echo    =====================================================================================
echo.
echo    按任意键结束...
pause >nul