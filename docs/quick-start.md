# Quick Start

Clone → rebrand → add logic → mirror. Under two minutes to a working scaffold.

## Prerequisites

- [.NET SDK 8+](https://dotnet.microsoft.com/download)
- Either **Unity 6.4+** or **Godot 4.6+** (.NET build) — only required to run the sample hosts

## 1. Use the template

Click **Use this template → Create a new repository** on the [GitHub page](https://github.com/shilo/unidote), then clone your fork:

```sh
git clone https://github.com/<owner>/<your-fork>.git
cd <your-fork>
```

## 2. Rebrand

Run the rename script from the repo root. It reads the current project name from the `.slnx` (or `.sln`) file (falling back to `Unidote` if no solution file exists) and the current author from `samples/UnidoteUnityDemo/Packages/com.shilo.unidote/package.json` (falling back to `Shilo` if that file is missing), prompts for replacements, then rewrites every matching PascalCase / kebab-case / display occurrence across `src/`, `samples/`, `scripts/`, `.github/`, `docs/`, and the solution file.

=== "macOS · Linux · Git Bash"

    ```sh
    bash scripts/init.sh
    ```

=== "Windows PowerShell"

    ```powershell
    .\scripts\init.ps1
    ```

Two prompts, each producing two case variants:

- **Project Name** — e.g. `My Library`. Produces `MyLibrary` (PascalCase, spaces removed) for namespaces, assembly names, and folders; `my-library` (kebab-case) for URL slugs, UPM package IDs, and concurrency groups.
- **Author Name** — e.g. `John Doe`. Produces `John Doe` (display, Title Case, spaces preserved) for human-readable fields like `package.json` → `author.name`, Godot `plugin.cfg` → `author`, and asmdef prefixes (`John Doe.MyLibrary.Unity`); `john-doe` (kebab-case) for lowercase identifiers like UPM IDs (`com.john-doe.my-library`), GitHub slugs, and doc URLs (`john-doe.github.io`).

!!! tip "Input forms accepted"
Both prompts accept a Title Case phrase (`My Library`, `John Doe`) **or** a single-token Pascal/camelCase value (`MyLibrary`, `JohnDoe`). Single-token input is preserved verbatim for the display variant and split on case boundaries for the kebab variant — e.g. `JohnDoe` → display `JohnDoe`, kebab `john-doe`. Single-token authors keep asmdef names space-free (`JohnDoe.MyLibrary.Unity`), which some tooling prefers.

!!! note "Unidote / Shilo are reserved placeholders"
Do **not** rename `Unidote` or `Shilo` by hand — those strings are the anchors the rename script keys off. Run `init.sh` / `init.ps1` instead.

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

- [Development Workflow](development-workflow.md) — how edits flow between `src/` and `samples/` (forward and reverse sync).
- [Unity Setup](unity-setup.md) — asmdef, UPM layout, distribution.
- [Godot Setup](godot-setup.md) — plugin.cfg, addon layout, editor registration.
