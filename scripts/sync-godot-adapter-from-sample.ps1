<#
.SYNOPSIS
    Harvests the Godot adapter from the sample project back to the root Godot/ distribution directory.

.DESCRIPTION
    Strips Godot uid:// strings so the scaffold plugin stays isolated and collision-free.
#>
#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir   = Split-Path -Parent $scriptDir

$sourceDir = Join-Path $rootDir "Samples\UnidoteGodotDemo\addons\Unidote"
$destDir   = Join-Path $rootDir "Godot\addons\Unidote"
$stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("unidote-godot-sync-" + [System.Guid]::NewGuid().ToString("N"))

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source Godot folder not found at $sourceDir"
}

function Strip-GodotUidFields {
    param([string]$Root)

    $extensions = @(".cfg", ".import", ".res", ".theme", ".tscn", ".tres")
    $files = Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object { $_.Extension -in $extensions }

    foreach ($file in $files) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        $updated = $content -replace '[ \t]+uid[ \t]*=[ \t]*"uid:\/\/[^"]*"', '' -replace '(?m)^[ \t]*uid[ \t]*=[ \t]*"uid:\/\/[^"]*"\r?\n?', ''
        if ($updated -cne $content) {
            [System.IO.File]::WriteAllText($file.FullName, $updated)
        }
    }
}

try {
    $destParent = Split-Path -Parent $destDir
    New-Item -ItemType Directory -Path $stagingRoot | Out-Null
    
    $stagedAddon = Join-Path $stagingRoot "Unidote"
    Copy-Item -LiteralPath $sourceDir -Destination $stagedAddon -Recurse -Force
    Strip-GodotUidFields -Root $stagedAddon
    
    New-Item -ItemType Directory -Path $destParent -Force | Out-Null
    if (Test-Path -LiteralPath $destDir) {
        Remove-Item -LiteralPath $destDir -Recurse -Force
    }
    
    Move-Item -LiteralPath $stagedAddon -Destination $destDir
    Write-Host "synced Unidote godot addon from sample to root distribution, UIDs stripped."
}
finally {
    if (Test-Path -LiteralPath $stagingRoot) {
        Remove-Item -LiteralPath $stagingRoot -Recurse -Force
    }
}
