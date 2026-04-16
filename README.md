# Unidote

> Cure for cross-engine headaches. A minimal C# scaffold with an engine-agnostic core plus Unity and Godot adapters.

Unidote is a **GitHub template** for building engine-agnostic C# game libraries. Fork it, run `init-project.ps1`, add your logic to `src/Unidote.Core`, and ship from day one to Unity, Godot, and plain .NET.

**Supported engines:** Unity **6.4+** (`6000.4`) · Godot **4.6+** (.NET build). The scaffold technically runs on older versions, but those two are the tested floor.

## Anatomy

| Path                               | Role                                                                                     |
| ---------------------------------- | ---------------------------------------------------------------------------------------- |
| `src/Unidote.Core/`                | **Patient Zero.** .NET Standard 2.1 + .NET 8 class library with zero engine dependencies. |
| `src/Unidote.Unity/`               | UPM-compliant package (`package.json`, `Runtime/*.asmdef`, `Editor/*.asmdef`, `Samples~/`). |
| `src/Unidote.Godot/`               | Godot 4.6 C# addon (`addons/Unidote/` with `plugin.cfg` and adapter scripts).            |
| `Samples/`                         | Minimal hello-world hosts for each engine — reference `src/Unidote.*` with zero drift.   |
| `scripts/`                         | `sync-core.sh` + `sync-core.ps1`. Mirror `src/Unidote.Core` into the engine adapter dirs. |
| `docs/`                            | Source for the published site: <https://shilocity.github.io/unidote/>.                   |
| `Directory.Build.props`            | Shared compiler settings (LangVersion, nullable, warnings-as-errors).                    |
| `Directory.Packages.props`         | Central Package Management (CPM).                                                        |
| `global.json`                      | .NET SDK pin.                                                                            |
| `init-project.ps1`                 | One-step rebrand: Pascal/snake/kebab placeholder rewrite + file rename.                  |

## Prescription (fork → use)

1. Use this repository as a GitHub template and clone the fork.
2. Run the rebrand script: `./init-project.ps1`. Enter your project name; the script rewrites every `Unidote` / `unidote` / `unidote-id` token and renames files accordingly.
3. Add your logic to `src/Unidote.Core/*.cs`.
4. Run the Core sync so the engine distribution folders mirror your Core:

   ```sh
   # macOS / Linux / Git Bash
   scripts/sync-core.sh
   ```

   ```powershell
   # Windows PowerShell
   scripts/sync-core.ps1
   ```

5. Open either demo in `/Samples/` to verify the library runs end-to-end.

## Dosage (distribution)

### Unity 6.4+

Install via Unity Package Manager → Add package from git URL:

```
https://github.com/<owner>/<fork>.git?path=/src/Unidote.Unity
```

Or reference a local clone from `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.shilo.unidote": "file:/absolute/path/to/unidote/src/Unidote.Unity"
  }
}
```

### Godot 4.6+

Copy `src/Unidote.Godot/addons/Unidote/` into your Godot 4.6+ C# project's `addons/` folder and enable the plugin under **Project → Project Settings → Plugins**.

### Plain .NET

Reference `src/Unidote.Core/Unidote.Core.csproj` directly from any `netstandard2.1`- or `net8.0`-compatible project.

## Architecture at a glance

- **Ports-and-Adapters.** `src/Unidote.Core/Ports/ITickService.cs` is the bridge; `UnidoteBehaviour` (Unity) and `UnidoteNode` (Godot) are the adapters that forward their native update loop into the Core.
- **`System.Numerics.Vector3`** handles Core math so adapters are the only place that pay the "Vector3 drift" tax.
- **Partial-class hot path.** `SimulationTicker` declares a `partial void OnPlatformTick(...)`. Each engine's adapter assembly supplies a body, so per-tick engine hooks avoid virtual-call overhead.
- **Single source of truth.** `src/Unidote.Core` is mirrored into `src/Unidote.Unity/Runtime/Core`, `src/Unidote.Godot/addons/Unidote/Core`, and the Godot sample's addon by `scripts/sync-core.*`. The sync script is UTF-8-safe and rejects cp1252 mojibake before it can land in a mirror.

## Prognosis (philosophy)

- **Single source of truth.** `src/Unidote.Core` is the only place to edit shared logic.
- **Zero bloat on fork.** No sample content, no feature code — just the scaffold. Delete nothing, add everything.
- **No runtime reflection.** The Core ships pure C# with nullable references and deterministic behavior.
- **Surgical `.gitignore`.** Tracks `.meta` and `.uid` so a fresh fork is usable in Unity and Godot without regenerating GUIDs.
- **Warnings are errors.** `Directory.Build.props` enables `TreatWarningsAsErrors` and the latest recommended analyzer set for every .NET project in the repo.

## Side Effects (licence)

MIT. See [LICENSE](LICENSE).
