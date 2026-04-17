param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'sync-core.sh' -NoPause:$NoPause
