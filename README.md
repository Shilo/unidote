# Unidote

> Cure for cross-engine headaches. A minimal engine-agnostic C# scaffold for building cross-engine libraries for Unity and Godot.

**Supported engines:** Unity **6.4+** (`6000.4`) · Godot **4.6+** (.NET build).

## Requirements

- Unity 6.4+ if you want to use the Unity package
- Godot 4.6+ (.NET build) if you want to use the Godot addon
- .NET SDK 8.x if you want to develop the shared C# core locally, run the sync scripts, or build from source

## Install

### Unity

Install with either method:

#### Git URL

```text
https://github.com/shilo/unidote.git?path=/src/Unidote.Unity
```

Add it in `Window > Package Manager > + > Add package from git URL`, or put the same URL in `Packages/manifest.json`.

#### Release zip

1. Download the Unity package zip from the repository's [Releases](../../releases) page.
2. Extract it into `Packages/com.shilo.unidote/`.

If you fork and rebrand the scaffold, replace the repo URL and package ID with your own values.

### Godot

Install with either method:

#### Source copy

1. Copy `src/Unidote.Godot/addons/Unidote/` into your Godot project's `addons/` folder so the final path is `addons/Unidote/`.
2. Build the C# solution once.
3. Enable `Unidote` in `Project > Project Settings > Plugins`.

#### Release zip

1. Download the Godot addon zip from the repository's [Releases](../../releases) page.
2. Extract it into the project root so the addon is created under `addons/`.
3. Build the C# solution once.
4. Enable `Unidote` in `Project > Project Settings > Plugins`.

## Layout

| Path                       | Role                                                                      |
| -------------------------- | ------------------------------------------------------------------------- |
| `src/Unidote.Core/`        | `netstandard2.1` class library — zero engine dependencies.                |
| `src/Unidote.Unity/`       | UPM-compliant package (`package.json`, `.asmdef`, `Runtime/`, `Editor/`). |
| `src/Unidote.Godot/`       | Godot 4.6+ C# addon (`plugin.cfg`, `.csproj`, `addons/Unidote/`).         |
| `samples/`                 | Minimal sample projects for each engine.                                  |
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

Full walkthrough: <https://shilo.github.io/unidote/quick-start/>. Engine-specific install details: <https://shilo.github.io/unidote/unity-setup/> and <https://shilo.github.io/unidote/godot-setup/>. Sync flow details: <https://shilo.github.io/unidote/development-workflow/>.

## Philosophy

- **`System.Numerics`** for Core math — adapters pay the conversion tax at the engine boundary.
- **Zero bloat.** No demo gameplay, no utility classes, no runtime helpers. Just the scaffold.
- **Warnings are errors.** `Directory.Build.props` enables `TreatWarningsAsErrors` and the latest analyzer set.
