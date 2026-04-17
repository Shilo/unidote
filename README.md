# Unidote

> Cure for cross-engine headaches. A minimal C# scaffold with an engine-agnostic core plus Unity and Godot adapters.

Unidote is a **GitHub template** for building engine-agnostic C# game libraries. Fork it, run `scripts/init-project.ps1`, add your logic to `src/Unidote.Core`, and ship from day one to Unity, Godot, and plain .NET.

**Supported engines:** Unity **6.4+** (`6000.4`) · Godot **4.6+** (.NET build).

## Anatomy

| Path                               | Role                                                                                     |
| ---------------------------------- | ---------------------------------------------------------------------------------------- |
| `src/Unidote.Core/`                | **Patient Zero.** .NET Standard 2.1 class library — zero engine dependencies.           |
| `src/Unidote.Unity/`               | UPM-compliant package (`package.json`, `Runtime/*.asmdef`, `Editor/*.asmdef`, `Samples~/`). |
| `src/Unidote.Godot/`               | Godot 4.6 C# addon (`addons/Unidote/` with `plugin.cfg`).                               |
| `Samples/`                         | Minimal host projects for each engine — reference `src/Unidote.*`.                      |
| `scripts/`                         | `sync-core.*` — mirror Core into engine adapter dirs. `init-project.ps1` — one-step rebrand. |
| `docs/`                            | Source for the published site: <https://shilocity.github.io/unidote/>.                   |
| `Directory.Build.props`            | Shared compiler settings (LangVersion, nullable, warnings-as-errors, version).           |
| `Directory.Packages.props`         | Central Package Management (CPM).                                                        |
| `global.json`                      | .NET SDK pin.                                                                            |

## Prescription (fork → use)

1. Use this repository as a GitHub template and clone the fork.
2. Run the rebrand script: `./scripts/init-project.ps1`. Enter your project name; the script rewrites every `Unidote` / `unidote` token and renames files accordingly.
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

Reference `src/Unidote.Core/Unidote.Core.csproj` directly from any `netstandard2.1`-compatible project.

## Architecture at a glance

- **Ports-and-Adapters.** Define interfaces in `src/Unidote.Core/Ports/`; implement engine adapters in `src/Unidote.Unity/` and `src/Unidote.Godot/`.
- **`System.Numerics.Vector3`** for Core math — adapters are the only place that pay the "Vector3 drift" tax.
- **Partial-class hot path.** Declare `partial void` hooks in Core; supply implementations in engine adapter files to avoid virtual-call overhead.
- **Single source of truth.** `src/Unidote.Core` is mirrored into engine distribution folders by `scripts/sync-core.*`.

## Prognosis (philosophy)

- **Zero bloat on fork.** No sample content, no feature code — just the scaffold. Delete nothing, add everything.
- **No runtime reflection.** The Core ships pure C# with nullable references and deterministic behavior.
- **Surgical `.gitignore`.** Tracks `.meta` and `.uid` anchors so a fresh fork is usable in Unity and Godot without regenerating GUIDs.
- **Warnings are errors.** `Directory.Build.props` enables `TreatWarningsAsErrors` and the latest recommended analyzer set.

## Side Effects (licence)

MIT. See [LICENSE](LICENSE).
