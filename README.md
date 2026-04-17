# Unidote

> Cure for cross-engine headaches. A minimal engine-agnostic C# scaffold for building cross-engine libraries for Unity and Godot.

**Supported engines:** Unity **6.4+** (`6000.4`) · Godot **4.6+** (.NET build).

## Layout

| Path                       | Role                                                                      |
| -------------------------- | ------------------------------------------------------------------------- |
| `src/Unidote.Core/`        | `netstandard2.1` class library — zero engine dependencies.                |
| `src/Unidote.Unity/`       | UPM-compliant package (`package.json`, `.asmdef`, `Runtime/`, `Editor/`). |
| `src/Unidote.Godot/`       | Godot 4.6+ C# addon (`plugin.cfg`, `.csproj`, `addons/Unidote/`).         |
| `samples/`                 | Minimal host projects for each engine.                                    |
| `scripts/`                 | `init.*` rebrand script · `sync-core.*` Core mirror script.               |
| `docs/`                    | Source for <https://shilo.github.io/unidote/> (MkDocs Material).          |
| `Directory.Build.props`    | Shared compiler settings.                                                 |
| `Directory.Packages.props` | Central Package Management.                                               |
| `global.json`              | .NET SDK pin.                                                             |

## Use

1. **Use this template** on GitHub, then clone your fork.
2. **Rebrand** the scaffold:

   ```sh
    bash scripts/init.sh            # macOS / Linux / Git Bash
    .\scripts\init.ps1 -NoPause     # Windows PowerShell (requires bash on PATH)
    ```

3. **Add logic** to `src/Unidote.Core/*.cs` (now named after your project).
4. **Mirror Core** into the engine adapters:

   ```sh
    scripts/sync-core.sh            # macOS / Linux / Git Bash
    .\scripts\sync-core.ps1 -NoPause  # Windows PowerShell (requires bash on PATH)
    ```

5. Open `samples/UnidoteUnityDemo/` in Unity or `samples/UnidoteGodotDemo/` in Godot to smoke-test.
6. **Iterate.** Edit Core in Visual Studio → forward sync. Edit the adapter inside Unity or Godot → reverse sync with `scripts/pull-unity-adapter-from-sample.*` or `scripts/pull-godot-adapter-from-sample.*` before committing.

Full walkthrough: <https://shilo.github.io/unidote/quick-start/>. Sync flow details: <https://shilo.github.io/unidote/development-workflow/>.

## Philosophy

- **`System.Numerics`** for Core math — adapters pay the conversion tax at the engine boundary.
- **Zero bloat.** No demo gameplay, no utility classes, no runtime helpers. Just the scaffold.
- **Warnings are errors.** `Directory.Build.props` enables `TreatWarningsAsErrors` and the latest analyzer set.
