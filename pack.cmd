cd %~dp0

set GIT=%~dp0MinGit\cmd\git.exe
set RAR=C:\Program Files\WinRAR\Rar.exe

"%GIT%" gc --aggressive --prune=now

for %%f in ("%~dp0git_bundle\*.bundle1") do (
ren "%%f" "%%~nf.bundle"
)
for /d %%r in ("%~dp0git_repositories\*") do (
cd "%%r"
"%GIT%" bundle create %%~nr.bundle HEAD main
move "%%~nr.bundle" "%~dp0git_bundle"
)

cd %~dp0

"%RAR%" a -ma5 -md1024 -m5 -mt32 -htb -rr5p -QO+ DSPBluePrints.rar .git git_bundle MinGit README.md update.cmd reset.cmd

pause
