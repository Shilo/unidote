# Godot Addon Setup

Wire `src/Unidote.Godot` into a Godot **4.6+** (.NET build) project as an addon.

## Install

### Manual copy

1. Copy `src/Unidote.Godot/addons/Unidote/` into the target project's `addons/` folder so the final path is `<project>/addons/Unidote/`.
2. Open the Godot editor.
3. Build the C# project once from the editor toolbar.
4. Enable `Unidote` in `Project -> Project Settings -> Plugins`.

### Release zip

1. Download the Godot addon zip from the repository's <a href="../../../releases">Releases</a> page.
2. Extract it into the project root so your addon folder is created under `addons/`.
3. Open the editor.
4. Build the C# project once.
5. Enable `Unidote` in `Project -> Project Settings -> Plugins`.

### Vendored repo

If you want to track the addon from source control, vendor the repository and point your project's `addons/Unidote/` at `src/Unidote.Godot/addons/Unidote/`.

## Anatomy

```
src/Unidote.Godot/
├── Unidote.Godot.csproj         # Addon library csproj (Godot.NET.Sdk)
└── addons/
    └── Unidote/                 # Consumer-facing addon folder
        ├── plugin.cfg           # Godot plugin manifest
        ├── UnidotePlugin.cs     # [Tool] EditorPlugin entry point
        ├── README.md
        └── Core/                # CI-synced mirror of the canonical Core source tree
```

Two anchors matter:

- `addons/Unidote/plugin.cfg` — Godot scans `res://addons/*/plugin.cfg` to populate the **Project Settings → Plugins** list. Required.
- `Unidote.Godot.csproj` — declares the addon as a .NET library targeting `net8.0` via `Godot.NET.Sdk/4.6.0` and references the Core csproj. Lets IDEs navigate and lets CI `dotnet build` the addon in isolation.

## Linking Core into the addon

Godot projects compile every `.cs` under the project root. The addon ships Core sources inside `addons/Unidote/Core/` for zero-configuration consumption. The sync script writes to this folder:

```sh
scripts/sync-core.sh          # macOS / Linux / Git Bash
scripts/sync-core.ps1         # Windows PowerShell
```

!!! warning "Do not edit addons/Unidote/Core/ by hand"
Files there are overwritten on every sync. Edit `src/Unidote.Core/` and re-run the script.

!!! tip "Iterating inside the Godot editor"
    When developing the addon through the Godot editor (scene edits, `[Tool]` plugin scripts, import settings), edits land in `samples/UnidoteGodotDemo/addons/Unidote/`. Run `scripts/pull-godot-adapter-from-sample.sh` (or `.ps1`) to pull them back into `src/Unidote.Godot/addons/Unidote/` before committing. See [Development Workflow](development-workflow.md).

## Git submodule example

Teams that want the addon to stay in sync with upstream can vendor the repo:

```sh
git submodule add https://github.com/<owner>/<fork>.git vendor/unidote
# Windows:
# macOS / Linux:
ln -s ../vendor/unidote/src/Unidote.Godot/addons/Unidote addons/Unidote
```

## plugin.cfg reference

```ini title="addons/Unidote/plugin.cfg"
[plugin]

name="Unidote"
author="Shilo"
version="0.1.0"
script=""
```

Bump `version` in lockstep with `package.json` and `Directory.Build.props` when releasing.
Each GitHub release includes a Godot addon zip on the <a href="../../../releases">Releases</a> page.

## C# project requirement

The addon is C# only. Your Godot project **must** be a .NET build — a `.csproj` at the project root, not a GDScript-only project. Our sample at `samples/UnidoteGodotDemo/` demonstrates the minimum viable setup:

```xml title="samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj"
<Project Sdk="Godot.NET.Sdk/4.6.0">
    <PropertyGroup>
        <TargetFramework>net8.0</TargetFramework>
        <EnableDynamicLoading>true</EnableDynamicLoading>
        <RootNamespace>UnidoteGodotDemo</RootNamespace>
    </PropertyGroup>

    <ItemGroup>
        <ProjectReference Include="..\..\src\Unidote.Core\Unidote.Core.csproj" />
    </ItemGroup>
</Project>
```

That project `.csproj` compiles the addon's `.cs` files (including the synced `addons/Unidote/Core/*.cs`) alongside your game code — no extra build step required.
