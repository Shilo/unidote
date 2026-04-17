<#
.SYNOPSIS
    Proxy script that executes init.sh.

.DESCRIPTION
    This script forwards execution to the canonical Bash script (init.sh)
    to avoid maintaining duplicate parallel logic. Requires Git Bash or WSL.
#>
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashScript = Join-Path $scriptDir 'init.sh'

try {
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-Error "Bash is required to run the init script. Please run via Git Bash, WSL, or ensure bash is in your PATH."
        exit 1
    }

    $bashPath = $bashScript -replace '\\', '/'
    & bash $bashPath
} finally {
    Write-Host "`nExecution finished. Press Enter to exit..." -ForegroundColor Gray
    Read-Host
}
