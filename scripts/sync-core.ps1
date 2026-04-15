<#
.SYNOPSIS
    Mirror /Core/*.cs into the Unity and Godot distribution folders.

.DESCRIPTION
    Idempotent sync script. Run after editing anything under /Core so the
    Unity UPM package and Godot addon ship with matching source.
#>
#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$scriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir       = Split-Path -Parent $scriptDir
$coreDir       = Join-Path $rootDir 'Core'
$unityCoreDir  = Join-Path $rootDir 'Unity\Runtime\Core'
$godotCoreDir  = Join-Path $rootDir 'Godot\addons\Unidote\Core'

if (-not (Test-Path -LiteralPath $coreDir -PathType Container)) {
    throw "Core directory not found at $coreDir"
}

$sources = @(Get-ChildItem -LiteralPath $coreDir -Filter '*.cs' -File)
if ($sources.Count -eq 0) {
    throw "No .cs files found under $coreDir"
}

New-Item -ItemType Directory -Force -Path $unityCoreDir, $godotCoreDir | Out-Null

# Purge previously synced files. Preserve Unity .meta so GUIDs stay stable.
Get-ChildItem -LiteralPath $unityCoreDir -Filter '*.cs' -File -ErrorAction SilentlyContinue |
    Remove-Item -Force

Get-ChildItem -LiteralPath $godotCoreDir -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like '*.cs' -or $_.Name -like '*.cs.uid' } |
    Remove-Item -Force

foreach ($src in $sources) {
    Copy-Item -LiteralPath $src.FullName -Destination $unityCoreDir -Force
    Copy-Item -LiteralPath $src.FullName -Destination $godotCoreDir -Force
}

Write-Host ("synced {0} file(s) from Core/ -> Unity/Runtime/Core and Godot/addons/Unidote/Core" -f $sources.Count)
