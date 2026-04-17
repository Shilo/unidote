param(
    [switch]$NoPause
)

& "$PSScriptRoot\_run.ps1" -Script 'pull-godot-adapter-from-sample.sh' -NoPause:$NoPause
