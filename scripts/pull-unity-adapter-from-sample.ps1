param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'pull-unity-adapter-from-sample.sh' -NoPause:$NoPause
