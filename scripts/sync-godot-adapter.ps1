param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'sync-godot-adapter.sh' -NoPause:$NoPause
