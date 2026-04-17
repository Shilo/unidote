# Quick Start

Clone → rebrand → add logic → mirror. Under two minutes to a working scaffold.

## Prerequisites

- [.NET SDK 8+](https://dotnet.microsoft.com/download)
- Either **Unity 6.4+** or **Godot 4.6+** (.NET build) — only required to run the sample hosts

## 1. Use the template

Click **Use this template → Create a new repository** on the [GitHub page](https://github.com/Shilocity/unidote), then clone your fork:

```sh
git clone https://github.com/<owner>/<your-fork>.git
cd <your-fork>
```

## 2. Rebrand

Run the rename script from the repo root. It reads the current project name from the `.sln`, prompts for a new one, and rewrites every PascalCase / snake_case / kebab-case occurrence across `src/`, `tests/`, `samples/`, and the solution file.

=== "macOS · Linux · Git Bash"

    ```sh
    bash scripts/init.sh
    ```

=== "Windows PowerShell"

    ```powershell
    .\scripts\init.ps1
    ```

Enter your project name (e.g. `My Library`). The script produces `MyLibrary` (PascalCase), `my_library` (snake_case), and `my-library` (kebab-case).

!!! note "Unidote is a reserved placeholder"
    Do **not** rename `Unidote` by hand — that string is the anchor the rename script keys off. Run `init.sh` / `init.ps1` instead.

## 3. Add Core logic

Open `src/Unidote.Core/Unidote.cs` (or rename-equivalent) and start adding types. The class is intentionally empty — this is where your engine-agnostic business logic lives.

```csharp title="src/Unidote.Core/Unidote.cs"
namespace Unidote;

public static class Unidote
{
    // Your code here.
}
```

Rules for Core:

- Target `netstandard2.1`. Works on Unity IL2CPP and Godot net8.0.
- Zero references to `UnityEngine`, `UnityEditor`, `Godot`, or `GodotSharp`.
- Use `System.Numerics.Vector3` for math — adapters convert at the engine boundary.

## 4. Build the Core

```sh
dotnet build Unidote.sln -c Release
```

This compiles `src/Unidote.Core/Unidote.Core.csproj` into `bin/Release/netstandard2.1/Unidote.Core.dll`.

## 5. Mirror Core into engine distributions

The Unity and Godot adapter folders pick up Core sources via the sync script.

=== "macOS · Linux · Git Bash"

    ```sh
    scripts/sync-core.sh
    ```

=== "Windows PowerShell"

    ```powershell
    scripts/sync-core.ps1
    ```

Output:

```
synced N file(s) from src/Unidote.Core -> Unity, Godot, Godot Sample
```

Re-run any time you add or edit a file in `src/Unidote.Core`.

## 6. Smoke-test an engine sample

- Unity → open `samples/UnidoteUnityDemo/` in Unity 6.4+. The manifest resolves `com.shilo.unidote` via a local `file:` path into `src/Unidote.Unity`.
- Godot → open `samples/UnidoteGodotDemo/project.godot` in Godot 4.6+ (.NET). The csproj references `src/Unidote.Core` directly.

## Where to go next

- [Unity Setup](unity-setup.md) — asmdef, UPM layout, distribution.
- [Godot Setup](godot-setup.md) — plugin.cfg, addon layout, editor registration.
