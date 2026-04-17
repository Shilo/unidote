# Unity Package Setup

Wire `src/Unidote.Unity` into a Unity **6.4+** project as a UPM package.

## Anatomy

```
src/Unidote.Unity/
├── package.json                 # UPM manifest (id, version, Unity min version)
├── README.md                    # Shown in the Package Manager pane
├── Runtime/
│   ├── Unidote.Unity.asmdef     # Runtime adapter assembly definition
│   └── Core/                    # CI-synced mirror of the canonical Core source tree
├── Editor/
│   └── Unidote.Editor.asmdef    # Editor-only assembly
└── Samples~/                    # Tilde suffix = hidden from default import
```

## Assembly Definitions

The two `.asmdef` files are mandatory:

- `Runtime/Unidote.Unity.asmdef` — compiles runtime adapter code into a separate DLL. Required for IL2CPP performance and clean dependency isolation.
- `Editor/Unidote.Editor.asmdef` — editor-only tooling. Scoped to the `Editor` platform so it never ships in a build.

Rename both (name + rootNamespace) when you fork — the `init.sh` script handles that automatically.

## Linking Core into Runtime

The Unity package ships Core sources inside `Runtime/Core/` so UPM consumers get everything in one install. The sync script writes to this folder:

```sh
scripts/sync-core.sh          # macOS / Linux / Git Bash
.\scripts\sync-core.ps1 -NoPause   # Windows PowerShell
```

The sync overwrites `Runtime/Core/*.cs` and preserves any `.meta` sidecars you commit.

!!! warning "Do not edit Runtime/Core/ by hand"
    Files there are overwritten on every sync. Edit `src/Unidote.Core/` and re-run the script.

!!! tip "Iterating inside Unity"
    When developing the adapter through the Unity Editor (Inspector tweaks, new asmdef refs, editor tooling), edits land in `samples/UnidoteUnityDemo/Packages/com.shilo.unidote/`. Run `scripts/pull-unity-adapter-from-sample.sh` (or `.ps1`) to pull them back into `src/Unidote.Unity/` before committing. See [Development Workflow](development-workflow.md).

## Consuming the package

### Git URL (recommended)

```jsonc title="Packages/manifest.json"
{
  "dependencies": {
    "com.shilo.unidote": "https://github.com/<owner>/<fork>.git?path=/src/Unidote.Unity"
  }
}
```

The `?path=/src/Unidote.Unity` suffix tells UPM to resolve the package from that subfolder.

### Embedded sample package

The scaffold sample project keeps an embedded copy of the package at `samples/UnidoteUnityDemo/Packages/com.shilo.unidote/`.

When you change `src/Unidote.Unity/`, push those changes into the sample with:

```sh
scripts/sync-unity-adapter.sh
```

Or on Windows PowerShell:

```powershell
.\scripts\sync-unity-adapter.ps1 -NoPause
```

Core changes still flow through `scripts/sync-core.*`.

### Package Manager UI

**Window → Package Manager → + → Add package from git URL…** and paste the URL above.

## Preparing for distribution

Before cutting a release:

1. Bump `version` in `src/Unidote.Unity/package.json`.
2. Commit and tag (`vX.Y.Z`).

Downstream consumers pin the tag:

```jsonc
{ "com.shilo.unidote": "https://github.com/<owner>/<fork>.git?path=/src/Unidote.Unity#v1.0.0" }
```

## GUID stability

Unity identifies assets by the GUIDs in `.meta` files. Commit every `.meta` — regenerating GUIDs breaks scene, prefab, and asmdef references across every consumer project.
