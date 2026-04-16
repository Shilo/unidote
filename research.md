# Architectural Specification: Unidote Engine-Agnostic C# Scaffold

## 1. Executive Summary
The goal of this scaffold is to decouple business logic from engine-specific runtimes to achieve technical longevity and cross-platform portability. This architecture prioritizes a **Ports-and-Adapters** model, utilizing **.NET Standard 2.1** for the core to ensure compatibility with Unity’s IL2CPP and Godot’s modern .NET 8/9+ runtimes. It ensures a "single source of truth" for logic while providing high "install-readiness" for end-users via NuGet, UPM, and Godot Addons.

---

## 2. Standardized Skeleton Structure
The physical layout accommodates the Core library, Unity Package Manager (UPM) assets, Godot Addon files, and metadata for distribution.

| Path | Purpose | Key Metadata Files |
| :--- | :--- | :--- |
| `.github/` | CI/CD workflows and Actions. | `ci.yml`, `release.yml` |
| `assets/` | Raw source assets (PNG, FBX). | N/A |
| `docs/` | Technical API documentation and API refs. | `index.md`, `DocFX.json` |
| **`src/`** | **Main Source Directory** | `Directory.Build.props` |
| `src/Project.Core/` | Engine-agnostic logic (.csproj). | `netstandard2.1` target |
| `src/Project.Unity/` | Unity wrappers and UPM layout. | `package.json`, `.asmdef` |
| `src/Project.Godot/` | Godot wrappers and Addon files. | `plugin.cfg`, `.csproj` |
| `tests/` | Multi-engine test suites (XUnit/NUnit). | `Acme.Core.Tests.csproj` |
| `samples/` | Engine-specific example host projects. | `ProjectSettings/`, `project.godot` |
| `Directory.Packages.props` | Central Package Management (CPM). | NuGet version locking |
| `global.json` | SDK version enforcement. | .NET SDK 8.0+ |

---

## 3. Core Architectural Principles

### Multi-Layered Abstraction
To prevent "dependency leakage," the library is partitioned into three distinct layers:
1.  **Core Logic Layer (.NET Standard 2.1):** Zero dependencies on `UnityEngine` or `GodotSharp`. Contains business logic, state machines, and algorithms.
2.  **Adapter Layer:** Maps core interfaces to engine-specific calls via the **Bridge Pattern**.
3.  **Visual Layer:** Engine-specific components (`MonoBehaviour` or `Node`) that act as composition roots.

### The "Vector3 Drift" Problem
Math compatibility is the primary friction point in engine-agnostic logic as `UnityEngine.Vector3` and `Godot.Vector3` are incompatible.
* **Solution**: Use **`System.Numerics.Vector3`** in the Core for SIMD acceleration.
* **Adapter Tax**: Mapping is required at the engine boundary to convert to engine-native types.

### Strategic Use of Partial Classes
For performance-critical hot loops (custom physics or ticking), partial classes allow engine-specific implementations without virtual call overhead.
* **Core:** Defines `public partial void OnTick();`.
* **Adapter:** Implemented in `Project.Unity` or `Project.Godot` files.

---

## 4. Structural Design Patterns

| Pattern | Agnostic Implementation | Engine Translation |
| :--- | :--- | :--- |
| **Adapter/Bridge** | `ILogger`, `IInputActions` | `UnityLoggerAdapter` / `GodotLoggerAdapter` |
| **Signals/Events** | `public event Action OnComplete;` | Emit Signal (Godot) / UnityEvent (Unity) |
| **Coroutines** | `IEnumerator` with custom Runner | Unity Coroutines / Godot Timer or Tween |
| **Async/Await** | Standard C# `Task` / `ValueTask` | Await in async Nodes or MonoBehaviours |

---

## 5. Distribution & Sync Patterns

### A. The "Sync-Script" Mirroring (Release Fallback)
Scripts physically mirror `/Core` files into engine distribution folders.
* **Pros**: Native UPM support and "Zero-Dependency" Godot addons.
* **Cons**: Storage redundancy and risk of "Sync Drift".

### B. The "Shared Project" / Project Reference
Unity and Godot projects reference a shared `.csproj`.
* **Pros**: Standard .NET handling in IDEs; single source.
* **Cons**: Unity lacks native support for external `.csproj` references.

### C. The "DLL/NuGet" Approach
Logic is compiled into a `.dll` and distributed via NuGet.
* **Pros**: Versioned stability and IP protection.
* **Cons**: Harder debugging and Unity requires `NuGetForUnity`.

---

## 6. High-Profile Case Studies

| Library | Engine Support | Implementation Strategy |
| :--- | :--- | :--- |
| **R3 (Cysharp)** | Unity, Godot, .NET | **Core + Extension Libs**: Pure C# core with engine-specific schedulers. |
| **MemoryPack** | Unity, Godot | **Source Generators**: Generates code in-project to bypass reflection for IL2CPP. |
| **LiteNetLib** | Unity, Godot | **Pure C# Source**: Distributed as source to resolve engine-specific defines. |
| **Arch (ECS)** | Unity, Godot | **Standard .NET DLL**: Distributed as a library with manual state syncing. |

---

## 7. Engine-Specific Implementation Details

### Unity (UPM Strategy)
* **Assembly Definitions (.asmdef)**: Mandatory for `Project.Unity` to ensure independent compilation into a DLL.
* **Hidden Folders**: Uses `Samples~` and `Documentation~` suffixes to remain invisible during standard imports but available via the Package Manager UI.

### Godot (Addon Strategy)
* **plugin.cfg**: Placed in `src/Project.Godot/addon/` for editor recognition.
* **Namespace Matching**: Assembly names must match the solution name to avoid loading errors.

---

## 8. Distribution Strategies & Release Lanes

| Channel | Best For | Strategy |
| :--- | :--- | :--- |
| **NuGet** | Core Library | Primary channel for agnostic Core; native for Godot 4.x. |
| **UPM** | Unity Adapter | Git URL install: `repo.git?path=/src/Project.Unity#v1.0.0`. |
| **Asset Lib** | Godot Adapter | Zipped addon of the `addons/` directory. |

---

## 9. Advanced Architecture: Lifecycle & Ticking
A pure C# library has no inherent concept of a frame. The Core must expose a mechanism called by engine-specific wrappers.
1.  **The "Ticking" Mechanism**: Expose `Update(float deltaTime)` or `Tick()`. This ensures determinism and allows headless testing.
2.  **Unity Implementation**: A `MonoBehaviour` calls Core logic in `Update()` or `FixedUpdate()`.
3.  **Godot Implementation**: A `Node` calls Core logic in `_Process()` or `_PhysicsProcess()`.

---

## 10. Step-by-Step Scaffolding Process
1.  **Initialize Core**: `dotnet new classlib -n Project.Core -f netstandard2.1`.
2.  **Establish Wrappers**: Create sub-directories for each engine with `package.json` (Unity) or `plugin.cfg` (Godot).
3.  **Configure .asmdef**: Vital for Unity performance and dependency isolation.
4.  **DI Patterns**: Implement reflection-free dependency injection (e.g., Chickensoft’s AutoInject).
5.  **Versioning**: Use `Directory.Build.props` to synchronize version numbers across all manifest files.

---

## 11. Naming Conventions & Style

| Entity Type | Convention | Example |
| :--- | :--- | :--- |
| Folder Name | PascalCase / CamelCase | `ProjectCore`, `UnityWrapper` |
| Namespace | `Root.Module.SubModule` | `MyLib.Networking.Adapters` |
| Unity Scripts | `PascalCase + MonoBehaviour` | `InputHandlerMono` |
| Godot Scripts | `PascalCase + Node` | `InputHandlerNode` |

---

## 12. Performance & Memory Management
* **Structs for Data**: Use for data containers to reduce heap pressure on Unity's older Mono GC.
* **Object Pooling**: Core manages pool logic; engine wrappers handle visual instantiation.
* **SIMD Acceleration**: Utilize `System.Numerics` for math types matrixed across engines.

---

## 13. Quality Assurance (CI/CD)
The workflow validates four distinct artifacts: Core .NET, Unity Package, Godot Addon, and Release integrity.

```yaml
# GitHub Actions Unified Workflow
jobs:
  build-and-test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
    steps:
      - uses: actions/checkout@v4
      - name: Core .NET Tests
        run: dotnet test tests/Project.Core.Tests
      - name: Unity Integration (GameCI)
        uses: game-ci/unity-test-runner@v4
        with:
          projectPath: samples/unity-host
      - name: Godot Headless Smoke Test
        run: ./godot --headless --path samples/godot-host --build-solutions
```

---

## 14. Licensing & Documentation
* **License**: MIT or Apache-2.0 are standard for cross-engine middleware.
* **Metadata**: NuGet packages must include `PackageReadmeFile` and Source Link for debuggability.
* **Release Hygiene**: SemVer, SPDX license metadata, and demo hosts are mandatory for industry-standard scaffolds.

## 15. Cross-Platform Initialization & Global Rename

To initialize a new project from the Unidote scaffold, use the following PowerShell script. This script renames all folder, file, and text content references of "Unidote" and "unidote" based on your chosen project name, following the same slug-generation logic as Godot 4.

### Setup Instructions
1. Save the code block below as `init-project.ps1` in your repository root.
2. Open your terminal (PowerShell, CMD, or VS Code Terminal).
3. Execute the script: `.\init-project.ps1`
4. Enter your desired project name when prompted (e.g., `My Super Project`).

```powershell
# init-project.ps1 - Cross-platform (Windows/Linux/macOS)
$rawInput = Read-Host "Enter Project Name (e.g., My Super Project)"
$trimmed = $rawInput.Trim()

if ([string]::IsNullOrWhiteSpace($trimmed)) { 
    Write-Error "Project name cannot be empty."; exit 
}

# --- 1. GENERATE NAMING CONVENTIONS ---
# PascalCase: "MySuperProject" (Used for C# Namespaces/Classes)
$PascalName = ($trimmed -split '\s+' | ForEach-Object { 
    if ($_.Length -gt 0) { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() } 
}) -join ''

# snake_case: "my_super_project" (Used for internal folders/Godot)
$SnakeName = $trimmed.ToLower().Replace(" ", "_")

# kebab-case: "my-super-project" (The "hello-world" ID for PWA/Web)
$KebabID = $trimmed.ToLower().Replace(" ", "-")

Write-Host "`n🚀 Initializing Unidote Scaffold..." -ForegroundColor Cyan
Write-Host "-------------------------------------------"
Write-Host "Project Name (Pascal): $PascalName"
Write-Host "Project ID (Kebab):    $KebabID"
Write-Host "Internal Name (Snake): $SnakeName"
Write-Host "-------------------------------------------`n"

# --- 2. REPLACE CONTENT IN ALL FILES ---
# Exclude the .git folder and this script itself
$files = Get-ChildItem -Recurse -File | Where-Object { 
    $_.FullName -notlike "*.git*" -and $_.Name -ne "init-project.ps1" 
}

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -ne $content -and ($content -match "Unidote" -or $content -match "unidote")) {
            $content = $content -replace "Unidote", $PascalName
            $content = $content -replace "unidote", $SnakeName
            # Explicitly ensure we handle any specific "ID" strings if they exist
            # $content = $content -replace "unidote-id", $KebabID 
            Set-Content $file.FullName $content -NoNewline
        }
    } catch {
        Write-Warning "Could not process file content: $($file.Name)"
    }
}

# --- 3. RENAME FILES AND FOLDERS ---
# Rename deepest children first to keep parent paths valid during the loop
$items = Get-ChildItem -Recurse | Where-Object { 
    $_.FullName -notlike "*.git*" -and $_.Name -ne "init-project.ps1" 
} | Sort-Object { $_.FullName.Length } -Descending

foreach ($item in $items) {
    $newName = $item.Name
    if ($newName -like "*Unidote*") {
        $newName = $newName -replace "Unidote", $PascalName
    }
    if ($newName -like "*unidote*") {
        $newName = $newName -replace "unidote", $SnakeName
    }
    
    if ($newName -ne $item.Name) {
        try {
            Rename-Item -Path $item.FullName -NewName $newName -Force -ErrorAction Stop
        } catch {
            Write-Warning "Failed to rename: $($item.FullName)"
        }
    }
}

Write-Host "`n✅ Success! Project successfully re-branded as $PascalName." -ForegroundColor Green
Write-Host "Note: You can now safely delete 'init-project.ps1'."

### **Why this works for Unidote:**
1.  **PascalCase Conversion**: It splits the input by spaces, capitalizes the first letter of every word, and joins them back together—ensuring `my super project` becomes `MySuperProject`.
2.  **Case Mapping**: It explicitly maps uppercase "Unidote" to your new **PascalCase** name and lowercase "unidote" to your **snake_case** name as requested.
3.  **Kebab-Case ID**: It generates the "hello-world" style ID (`my-super-project`) which is essential for your **Svelte 5** PWA manifest and package names.
4.  **Deep-First Renaming**: The `Sort-Object` by `Length -Descending` is a critical technical step for Windows; it ensures files inside a folder are renamed before the folder itself is moved, preventing "Path Not Found" errors.

---

## ⚠️ AI Agent Execution Policy: GitHub Template Preservation
This document defines a **GitHub Template Scaffold**. All agents interacting with this repository must adhere to the following constraints:

1. **Cloning Workflow**: This repository is a container designed to be cloned to new, empty projects. Its primary value is its **File Structure**, not its code volume.
2. **Preserve Anchors**: Structural files (`package.json`, `.asmdef`, `plugin.cfg`, `.csproj`) are mandatory technical anchors. Their removal is a critical failure.
3. **Placeholder Integrity**: The name `Unidote` is a reserved keyword for the `init-project.ps1` transformation script. Do not refactor or "correct" this string to match the repository name.
4. **Boilerplate Minimalism**: Keep implementation code to the absolute minimum (Interfaces/Adapters only) to serve as a usage example for the end-user.