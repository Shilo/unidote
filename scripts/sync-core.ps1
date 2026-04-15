<#
.SYNOPSIS
    Mirror /Core/**/*.cs into the Unity and Godot distribution folders.

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

$sources = @(Get-ChildItem -LiteralPath $coreDir -Filter '*.cs' -File -Recurse | Where-Object { 
    $_.FullName -notmatch '[\\/]bin[\\/]' -and $_.FullName -notmatch '[\\/]obj[\\/]' 
})
if ($sources.Count -eq 0) {
    throw "No .cs files found under $coreDir"
}

New-Item -ItemType Directory -Force -Path $unityCoreDir, $godotCoreDir | Out-Null

# Purge previously synced files. Preserve Unity .meta so GUIDs stay stable.
Get-ChildItem -LiteralPath $unityCoreDir -Filter '*.cs' -File -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Force

Get-ChildItem -LiteralPath $godotCoreDir -Filter '*.cs' -File -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Force

foreach ($src in $sources) {
    $relPath = $src.FullName.Substring($coreDir.Length + 1)
    $destU = Join-Path $unityCoreDir $relPath
    $destG = Join-Path $godotCoreDir $relPath
    
    $dirU = Split-Path $destU -Parent
    $dirG = Split-Path $destG -Parent
    
    if (-not (Test-Path -LiteralPath $dirU)) { New-Item -ItemType Directory -Force -Path $dirU | Out-Null }
    if (-not (Test-Path -LiteralPath $dirG)) { New-Item -ItemType Directory -Force -Path $dirG | Out-Null }
    
    Copy-Item -LiteralPath $src.FullName -Destination $destU -Force
    Copy-Item -LiteralPath $src.FullName -Destination $destG -Force
}

Write-Host ("synced {0} file(s) from Core/ -> Unity/Runtime/Core and Godot/addons/Unidote/Core" -f $sources.Count)
