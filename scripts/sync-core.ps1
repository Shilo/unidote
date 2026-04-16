<#
.SYNOPSIS
    Mirror src/Unidote.Core/**/*.cs into the Unity and Godot distribution
    folders. Idempotent and UTF-8-safe.

.DESCRIPTION
    Reads and writes every mirrored file with an explicit UTF-8 (no BOM)
    encoding so Windows PowerShell 5.1 (default cp1252) cannot silently
    round-trip em-dashes into mojibake.

    Includes a post-write regression gate that rejects the classic
    "â€" double-encoding byte sequence in any mirror output.
#>
#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$scriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir        = Split-Path -Parent $scriptDir
$coreDir        = Join-Path $rootDir 'src\Unidote.Core'
$unityCoreDir   = Join-Path $rootDir 'src\Unidote.Unity\Runtime\Core'
$godotCoreDir   = Join-Path $rootDir 'src\Unidote.Godot\addons\Unidote\Core'
$godotSampleDir = Join-Path $rootDir 'Samples\UnidoteGodotDemo\addons\Unidote\Core'

if (-not (Test-Path -LiteralPath $coreDir -PathType Container)) {
    throw "Core directory not found at $coreDir"
}

$sources = @(Get-ChildItem -LiteralPath $coreDir -Filter '*.cs' -File -Recurse | Where-Object {
    $_.FullName -notmatch '[\\/]bin[\\/]' -and $_.FullName -notmatch '[\\/]obj[\\/]'
})
if ($sources.Count -eq 0) {
    throw "No .cs files found under $coreDir"
}

New-Item -ItemType Directory -Force -Path $unityCoreDir, $godotCoreDir, $godotSampleDir | Out-Null

# Purge previously synced files. Preserve Unity .meta / Godot .uid sidecars.
foreach ($dir in @($unityCoreDir, $godotCoreDir, $godotSampleDir)) {
    Get-ChildItem -LiteralPath $dir -Filter '*.cs' -File -Recurse -ErrorAction SilentlyContinue |
        Remove-Item -Force
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$header    = "// AUTO-GENERATED. DO NOT EDIT. Edit source in src/Unidote.Core instead.`n"

foreach ($src in $sources) {
    $relPath = $src.FullName.Substring($coreDir.Length + 1)
    $destU   = Join-Path $unityCoreDir $relPath
    $destG   = Join-Path $godotCoreDir $relPath
    $destGS  = Join-Path $godotSampleDir $relPath

    foreach ($dest in @($destU, $destG, $destGS)) {
        $parent = Split-Path $dest -Parent
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
    }

    # Explicit UTF-8 read + UTF-8 no-BOM write — immune to cp1252 drift on PS 5.1.
    $content = [System.IO.File]::ReadAllText($src.FullName, [System.Text.Encoding]::UTF8)
    $payload = $header + $content

    [System.IO.File]::WriteAllText($destU, $payload, $utf8NoBom)
    [System.IO.File]::WriteAllText($destG, $payload, $utf8NoBom)
    [System.IO.File]::WriteAllText($destGS, $payload, $utf8NoBom)
}

# --- UTF-8 regression gate -------------------------------------------------
# Fail fast if any mirror contains the cp1252→UTF-8 double-encoded "â€" prefix.
$mojibake = [byte[]]@(0xC3, 0xA2, 0xE2, 0x82, 0xAC)
$mojibakeHit = $false
foreach ($dir in @($unityCoreDir, $godotCoreDir, $godotSampleDir)) {
    Get-ChildItem -LiteralPath $dir -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        for ($i = 0; $i -le $bytes.Length - $mojibake.Length; $i++) {
            $match = $true
            for ($j = 0; $j -lt $mojibake.Length; $j++) {
                if ($bytes[$i + $j] -ne $mojibake[$j]) { $match = $false; break }
            }
            if ($match) {
                Write-Error "Mojibake detected in $($_.FullName). Re-save the source as UTF-8 (no BOM)."
                $mojibakeHit = $true
                break
            }
        }
    }
}
if ($mojibakeHit) { exit 2 }

Write-Host ("synced {0} file(s) from src/Unidote.Core -> Unity, Godot, Godot Sample" -f $sources.Count)
