param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'sync-unity-adapter-from-sample.sh' -NoPause:$NoPause
