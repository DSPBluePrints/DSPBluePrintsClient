chcp 65001
@echo off

cd %~dp0

::set path
set LOG_PATH=%~dp0update.log

::debug info
dir>"%LOG_PATH%"

::test dir
if not exist "..\Blueprint" (
echo 错误：无法找到Blueprint/，请检查此包是否安装到了正确路径
echo Error: %date% %time% not exist "..\Blueprint">>"%LOG_PATH%"
goto error
)
if not exist ".\DSPBluePrintsClient" (
echo 错误：无法找到DSPBluePrintsClient/，可能此更新程序已损坏
echo Error: %date% %time% not exist ".\DSPBluePrintsClient">>"%LOG_PATH%"
goto error
)
if exist "..\Blueprint\FactoryBluePrints\MinGit" (
echo 错误：已存在FactoryBluePrints/，命名冲突。如果您正在使用旧版蓝图仓库，请先删除旧版
echo Error: %date% %time% exist "..\Blueprint\FactoryBluePrints\MinGit">>"%LOG_PATH%"
goto error
)

::find git
if exist "%~dp0MinGit\cmd\git.exe" (
set GIT=%~dp0MinGit\cmd\git.exe
echo Infomation: %date% %time% GIT=%~dp0MinGit\cmd\git.exe>>"%LOG_PATH%"
) else if exist "C:\Program Files\Git" (
set GIT=git
echo Infomation: %date% %time% GIT=git>>"%LOG_PATH%"
) else (
set GIT=git
echo 警告：无法找到git.exe，如果更新能正常进行请忽略
echo Warning: %date% %time% Git no found>>"%LOG_PATH%"
)

::git config
"%GIT%" config core.longpaths true
set GIT_SSL_NO_VERIFY=true

::init client
if not exist "DSPBluePrintsClient" (
"%GIT%" clone https://github.com/DSPBluePrints/DSPBluePrintsClient.git
if %errorlevel% NEQ 0 (
echo 错误：更新获取失败，这通常是因为网络问题（GFW）。请重试，或者开加速器再更新。
echo Error: %date% %time% git pull error>>"%LOG_PATH%"
goto error
)
)

::update client
cd DSPBluePrintsClient
if not exist ".git" (
echo 错误：无法找到.git/，请检查此储存库是否损坏
echo Error: %date% %time% Could not find .git/>>"%LOG_PATH%"
goto error
)
"%GIT%" pull origin main
if %errorlevel% NEQ 0 (
echo 错误：更新获取失败，这通常是因为网络问题（GFW）。请重试，或者开加速器再更新。
echo Error: %date% %time% git pull error>>"%LOG_PATH%"
goto error
)
cd %~dp0
Xcopy "DSPBluePrintsClient" "%~dp0" /y

::init blueprint
if not exist "git_repositories" (
mkdir git_repositories
)
for %%f in ("%~dp0git_bundle\*.bundle") do (
cd "%~dp0git_repositories"
"%GIT%" clone "%%f"
cd %%~nf
"%GIT%" remote remove origin
"%GIT%" remote add origin https://github.com/DSPBluePrints/%%~nf.git
cd "%~dp0"
cd "..\Blueprint"
mklink /d %%~nf "%~dp0git_repositories\%%~nf"
if not exist "%%~nf" (
echo 警告：软链接失败，但安装将会继续。请在安装结束后，右键update.cmd，以管理员身份执行
echo Warning: %date% %time% mklink error>>"%LOG_PATH%"
) else (
ren "%%f" "%%~nf.bundle1"
)
cd "%~dp0"
)

::update blueprint
for /d %%r in ("%~dp0git_repositories\*") do (
cd "%%r"
if exist ".gitignore" (
if not exist ".git" (
echo 错误：无法找到.git/，请检查此储存库是否损坏
echo Error: %date% %time% Could not find .git/>>"%LOG_PATH%"
goto error
)
"%GIT%" pull origin main
if %errorlevel% NEQ 0 (
echo 错误：更新获取失败，这通常是因为网络问题（GFW）。请重试，或者开加速器再更新。
echo Error: %date% %time% git pull error>>"%LOG_PATH%"
goto error
)
)
cd %~dp0
)

::succeed
echo 更新完成，现在可以直接关闭此窗口
pause
exit

:error
echo 更新因为出现错误而终止。如果存疑可以加qq群反馈：162065696
pause
exit