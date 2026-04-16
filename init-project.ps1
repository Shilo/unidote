<#
.SYNOPSIS
    Rebrand the Unidote scaffold for a fresh fork.

.DESCRIPTION
    Prompts for a human-readable project name, derives PascalCase, snake_case,
    and kebab-case identifiers, then rewrites every text occurrence of
    "Unidote", "unidote", and "unidote-id" and renames every matching file
    or folder.

    Case-sensitive replacements (-creplace) ensure the PascalCase sweep does
    not eat lowercase tokens before the snake/kebab sweeps run.

    Run once at the repository root immediately after cloning the template,
    then delete this script.

.NOTES
    Cross-platform. Works in PowerShell 5.1+ on Windows and PowerShell Core
    on Linux/macOS. Skips the .git folder and this script itself.
#>
#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$rawInput = Read-Host "Enter Project Name (e.g., My Super Project)"
$trimmed = $rawInput.Trim()

if ([string]::IsNullOrWhiteSpace($trimmed)) {
    Write-Error "Project name cannot be empty."; exit 1
}

# --- 1. GENERATE NAMING CONVENTIONS ---
# PascalCase: "MySuperProject" (C# namespaces / classes / "Unidote" replacement)
$PascalName = ($trimmed -split '\s+' | ForEach-Object {
    if ($_.Length -gt 0) { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }
}) -join ''

# snake_case: "my_super_project" (Godot plugin id / UPM / "unidote" replacement)
$SnakeName = $trimmed.ToLower() -replace '\s+', '_'

# kebab-case: "my-super-project" (PWA manifest / web pkg / "unidote-id" replacement)
$KebabID = $trimmed.ToLower() -replace '\s+', '-'

Write-Host "`nInitializing Unidote Scaffold..." -ForegroundColor Cyan
Write-Host "-------------------------------------------"
Write-Host "Project Name (Pascal): $PascalName"
Write-Host "Project ID (Kebab):    $KebabID"
Write-Host "Internal Name (Snake): $SnakeName"
Write-Host "-------------------------------------------`n"

$sep = [IO.Path]::DirectorySeparatorChar
$gitSegment = "$sep.git$sep"

# --- 2. REPLACE CONTENT IN ALL FILES ---
# Exclude the .git folder and this script itself.
$files = Get-ChildItem -Recurse -File | Where-Object {
    $_.FullName -notlike "*$gitSegment*" -and
    $_.Name -ne "init-project.ps1"
}

foreach ($file in $files) {
    try {
        $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content) { continue }
        if (-not ($content -cmatch 'Unidote|unidote')) { continue }

        # Order matters: kebab token first (contains hyphen, most specific),
        # then PascalCase, then snake_case — all case-sensitive.
        $content = $content -creplace 'unidote-id', $KebabID
        $content = $content -creplace 'Unidote',    $PascalName
        $content = $content -creplace 'unidote',    $SnakeName

        Set-Content -LiteralPath $file.FullName -Value $content -NoNewline
    } catch {
        Write-Warning "Could not process file content: $($file.Name)"
    }
}

# --- 3. RENAME FILES AND FOLDERS ---
# Deepest-first so child paths rename before their parents move.
$items = Get-ChildItem -Recurse | Where-Object {
    $_.FullName -notlike "*$gitSegment*" -and
    $_.Name -ne "init-project.ps1"
} | Sort-Object { $_.FullName.Length } -Descending

foreach ($item in $items) {
    $newName = $item.Name
    if ($newName -cmatch 'unidote-id') { $newName = $newName -creplace 'unidote-id', $KebabID }
    if ($newName -cmatch 'Unidote')    { $newName = $newName -creplace 'Unidote',    $PascalName }
    if ($newName -cmatch 'unidote')    { $newName = $newName -creplace 'unidote',    $SnakeName }

    if ($newName -cne $item.Name) {
        try {
            Rename-Item -LiteralPath $item.FullName -NewName $newName -Force -ErrorAction Stop
        } catch {
            Write-Warning "Failed to rename: $($item.FullName)"
        }
    }
}

Write-Host "`nSuccess! Project rebranded as $PascalName." -ForegroundColor Green
Write-Host "Note: You can now safely delete 'init-project.ps1'."
