param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'verify.sh' -NoPause:$NoPause
