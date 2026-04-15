# Godot 4.6+

Detailed reference for the Godot C# addon.

## Overview

The `/Godot/addons/Unidote/` folder is a **drop-in Godot plugin** that compiles alongside any Godot 4.6+ .NET project.

```
Godot/
└── addons/
    └── Unidote/
        ├── plugin.cfg         # Godot plugin manifest
        ├── UnidotePlugin.cs   # EditorPlugin (runs inside the editor)
        ├── UnidotePlugin.cs.uid
        ├── UnidoteNode.cs     # Runtime Node adapter
        ├── UnidoteNode.cs.uid
        ├── README.md
        └── Core/              # CI-synced mirror of /Core (git-ignored)
```

## Install

See [Install → Drop in the Godot addon](../install.md#3-drop-in-the-godot-addon).

!!! warning "C#-only"
    The addon requires a Godot **.NET build** project. GDScript-only projects will not compile the `.cs` files inside the addon.

## `plugin.cfg`

```ini title="addons/Unidote/plugin.cfg"
[plugin]

name="Unidote"
description="Engine-agnostic C# core with a Godot adapter. Cure for cross-engine headaches."
author="Shilo"
version="0.1.0"
script="UnidotePlugin.cs"
```

Enable it under **Project → Project Settings → Plugins → Unidote**.

## Using `UnidoteCore`

```csharp
using Godot;
using Unidote;

public partial class Main : Node
{
    public override void _Ready()
    {
        GD.Print(UnidoteCore.Greet("Godot"));
    }
}
```

## Using `UnidoteNode`

The addon ships a ready-to-use Node adapter.

1. Open a scene.
2. Right-click → **Add Child Node → UnidoteNode**.
3. Set the **Subject** property in the Inspector.
4. Run the scene — the greeting appears in the Output pane.

```csharp
namespace Unidote.Godot
{
    public partial class UnidoteNode : Node
    {
        [Export] public string Subject { get; set; } = "Godot";

        public override void _Ready()
        {
            GD.Print(UnidoteCore.Greet(Subject));
        }
    }
}
```

## `EditorPlugin`

`UnidotePlugin.cs` runs inside the editor and prints the Core version to the Output panel when the plugin is enabled. It is a minimal stub — extend it to register custom docks, importers, or tools:

```csharp
#if TOOLS
using Godot;

namespace Unidote.Godot
{
    [Tool]
    public partial class UnidotePlugin : EditorPlugin
    {
        public override void _EnterTree()
        {
            GD.Print($"[Unidote] plugin enabled — Core v{UnidoteCore.Version}");
        }

        public override void _ExitTree()
        {
            // Clean up any editor-registered resources here.
        }
    }
}
#endif
```

## UID stability

Godot 4+ resolves script and scene references via **UIDs** stored in sidecar `.uid` files. Unidote ships stable UIDs so a fresh clone imports cleanly without regeneration:

| File                       | UID                 |
| -------------------------- | ------------------- |
| `UnidotePlugin.cs.uid`     | `uid://cunidoteplg01a` |
| `UnidoteNode.cs.uid`       | `uid://cunidotenod01a` |

## Compiling the Core

The Godot host project compiles `addons/Unidote/Core/*.cs` alongside its own code. That folder is populated by `scripts/sync-core.(sh|ps1)`.

For sample / demo projects that do **not** copy the addon, reference `/Core` directly with `<Compile Include>`:

```xml title="YourGodotProject.csproj"
<Project Sdk="Godot.NET.Sdk/4.6.0">
    <PropertyGroup>
        <TargetFramework>net8.0</TargetFramework>
        <EnableDynamicLoading>true</EnableDynamicLoading>
    </PropertyGroup>
    <ItemGroup>
        <Compile Include="..\unidote\Core\*.cs" LinkBase="Core" />
    </ItemGroup>
</Project>
```

This is exactly what [`Samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj`](https://github.com/Shilocity/unidote/blob/main/Samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj) does.

## Distribution Channels

| Channel                        | Supported |
| ------------------------------ | --------- |
| Manual folder drop (`addons/`) | ✅ |
| Git submodule                  | ✅ |
| Godot Asset Library            | ⏳ (not submitted yet) |

## Troubleshooting

!!! question "The addon does not appear under Project Settings → Plugins"
    Make sure you copied the folder **as `addons/Unidote/`**, not `addons/unidote/` or `addons/Unidote-main/`. Godot looks for `plugin.cfg` at that exact path.

!!! question "Compile errors about `UnidoteCore` not found"
    The `Core/` folder inside the addon is populated by the sync script. Run `scripts/sync-core.sh` (or `.ps1`) from the Unidote repository root before opening Godot.

!!! question "`[Tool]` does not seem to activate `UnidotePlugin`"
    Rebuild the C# project (**Build → Build** in the Godot toolbar) after enabling the plugin.
