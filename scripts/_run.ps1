<#
.SYNOPSIS
    Shared helper invoked by every *.ps1 proxy in this folder.

.DESCRIPTION
    Resolves the named Bash script next to itself, verifies bash is on PATH,
    executes it from the scripts directory, and pauses so users running via
    Explorer double-click can read the output. All proxy scripts delegate
    here to avoid duplicating this logic.

.PARAMETER Script
    Filename of the Bash script to execute (e.g. 'sync-core.sh'). Must live
    alongside this helper under scripts/.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Script,
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashScript = Join-Path $scriptDir $Script

if (-not (Test-Path -LiteralPath $bashScript -PathType Leaf)) {
    Write-Error "Bash script not found: $bashScript"
    exit 1
}

try {
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-Error "Bash is required. Please run via Git Bash, WSL, or ensure bash is in your PATH."
        exit 1
    }

    Push-Location $scriptDir
    try {
        & bash "./$Script"
    } finally {
        Pop-Location
    }
} finally {
    if (-not $NoPause) {
        Write-Host "`nExecution finished. Press Enter to exit..." -ForegroundColor Gray
        Read-Host
    }
}
