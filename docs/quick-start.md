# Quick Start

Confirm Unidote is wired up end-to-end in under two minutes.

## Prerequisites

- [.NET SDK 8+](https://dotnet.microsoft.com/download)
- Either **Unity 6.4+** or **Godot 4.6+** (.NET build) — or both

## 1. Clone

```sh
git clone https://github.com/Shilocity/unidote.git
cd unidote
```

## 2. Build the Core

```sh
dotnet build Unidote.sln -c Release
```

Expected output:

```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

This compiles `/Core/Core.csproj` into `Core/bin/Release/netstandard2.1/Unidote.Core.dll` and, as a bonus, builds the Godot sample into `.godot/mono/temp/bin/Release/UnidoteGodotDemo.dll`.

## 3. Run a sample

=== "Unity 6.4+"

    1. Open `Samples/UnidoteUnityDemo/` as a Unity project.
    2. Unity will resolve the local package via the relative `file:` path in `Packages/manifest.json`.
    3. Create an empty scene, drop an empty GameObject, and add the **Hello Unidote** component (from `Assets/`).
    4. Press **Play**.

    Console output:

    ```
    Hello, Unity Demo! — Unidote v0.1.0
    ```

=== "Godot 4.6+"

    1. Open `Samples/UnidoteGodotDemo/project.godot` in the Godot 4.6+ editor (.NET build).
    2. Let Godot build the C# project (happens automatically on first open).
    3. Press **Play**.

    Output pane:

    ```
    Hello, Godot Demo! — Unidote v0.1.0
    ```

=== ".NET CLI"

    ```sh
    dotnet run --project Samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj
    ```

    This only verifies that the Godot sample **compiles** — you need the Godot editor to see it run.

## 4. Mirror the Core into the engine adapters

The Unity and Godot distribution folders (`Unity/Runtime/Core/` and `Godot/addons/Unidote/Core/`) are populated by the sync script.

=== "macOS · Linux · Git Bash"

    ```sh
    scripts/sync-core.sh
    ```

=== "Windows PowerShell"

    ```powershell
    scripts/sync-core.ps1
    ```

Expected output:

```
synced 1 file(s) from Core/ -> Unity/Runtime/Core and Godot/addons/Unidote/Core
```

## 5. Edit the Core

1. Open `Core/Unidote.cs`.
2. Change the `Version` constant or the `Greet` message.
3. Re-run the sync script.
4. Re-run the sample. The new output confirms your edit propagated.

That is the full Unidote workflow: edit Core → sync → run sample.

## Next

- Detailed engine guides: [Unity](engines/unity.md) · [Godot](engines/godot.md) · [.NET](engines/dotnet.md)
- Template rename checklist: [Architecture → Renaming the template](architecture.md#renaming-the-template)
