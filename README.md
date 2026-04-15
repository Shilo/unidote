# Unidote

> Cure for cross-engine headaches. A minimal C# scaffold with an engine-agnostic core plus Unity and Godot wrappers.

Unidote is a **Git template** for building engine-agnostic C# game libraries. Fork it, rename the namespaces, add your logic to `/Core`, and ship from day one to Unity, Godot, and plain .NET.

## Anatomy

| Path                     | Role                                                                                  |
| ------------------------ | ------------------------------------------------------------------------------------- |
| `/Core`                  | **Patient Zero.** A .NET Standard 2.1 class library with zero engine dependencies.    |
| `/Unity`                 | UPM-compliant package (`package.json`, `Runtime/*.asmdef`, `Samples~/`).              |
| `/Godot`                 | Godot 4.6 C# addon (`addons/Unidote/` with `plugin.cfg` and adapter scripts).         |
| `/Samples`               | Minimal Hello-World projects for each engine, referencing `/Core` with zero drift.    |
| `/scripts`               | `sync-core.sh` + `sync-core.ps1`. Mirrors `/Core` into the engine distribution dirs.  |

## Fork → Use

1. Use this repository as a GitHub template and clone the fork.
2. Rename the `Unidote` namespace, package id (`com.shilo.unidote`), and addon folder (`Godot/addons/Unidote/`) to match your library.
3. Add your logic to `/Core/*.cs`.
4. Run the sync once so the engine distribution folders mirror your Core:

   ```sh
   # macOS / Linux / Git Bash
   scripts/sync-core.sh
   ```

   ```powershell
   # Windows PowerShell
   scripts/sync-core.ps1
   ```

5. Open either demo in `/Samples/` to verify the library runs end-to-end.

## Distribution

### Unity

Install via Unity Package Manager → Add package from git URL:

```
https://github.com/<owner>/<fork>.git?path=/Unity
```

Or reference a local clone from `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.shilo.unidote": "file:/absolute/path/to/unidote/Unity"
  }
}
```

### Godot

Copy `/Godot/addons/Unidote/` into your Godot 4.6 C# project's `addons/` folder and enable the plugin under **Project → Project Settings → Plugins**.

### Plain .NET

Reference `/Core/Core.csproj` directly from any `net6+` or `netstandard2.1+` project.

## Philosophy

- **Single source of truth.** `/Core` is the only place to edit shared logic. Engine folders mirror it.
- **Zero bloat on fork.** No sample content, no feature code — just the scaffold. Delete nothing, add everything.
- **No runtime reflection.** The Core ships pure C# with nullable references and deterministic behavior.
- **Surgical `.gitignore`.** Tracks `.meta` and `.uid` so a fresh fork is usable in Unity and Godot without regenerating GUIDs.

## License

MIT. See [LICENSE](LICENSE).
