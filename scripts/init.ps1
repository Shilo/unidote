param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'init.sh' -NoPause:$NoPause
