cd %~dp0

rmdir ".\DSPBluePrintsClient" /S /Q 1
rmdir ".\git_repositories" /S /Q 1
for %%f in (.\git_bundle\*.bundle1) do (
ren %%f %%~nf.bundle
)
for %%f in (.\git_bundle\*.bundle) do (
rmdir "..\Blueprint\%%~nf"
)