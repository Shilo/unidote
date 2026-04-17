<#
.SYNOPSIS
    Proxy script that executes sync-core.sh.

.DESCRIPTION
    This script forwards execution to the canonical Bash script (sync-core.sh)
    to avoid maintaining duplicate parallel logic. Requires Git Bash or WSL.
#>
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashScript = Join-Path $scriptDir 'sync-core.sh'

try {
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-Error "Bash is required to run the sync script. Please run via Git Bash, WSL, or ensure bash is in your PATH."
        exit 1
    }

    Push-Location $scriptDir
    try {
        & bash ./sync-core.sh
    } finally {
        Pop-Location
    }
} finally {
    Write-Host "`nExecution finished. Press Enter to exit..." -ForegroundColor Gray
    Read-Host
}
