param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'sync-godot-adapter-from-sample.sh' -NoPause:$NoPause
