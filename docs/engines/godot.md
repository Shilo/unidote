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

## UID isolation

Godot 4+ resolves script and scene references via **UIDs** stored in sidecar `.uid` files. However, sharing `.uid` files in generic community plugins often leads to registry hash collisions if multiple downstream developers import the same assets. 

Unidote deliberately **strips `uid://` strings** and excludes `.uid` metadata from its `/Godot/addons` distribution. This forces the Godot host engine to fallback to stable path-based resolution for plugin resources upon import, ensuring your repository functions as a collision-free template.

When developing the engine-specific wrappers in the `Samples/UnidoteGodotDemo`, executing `scripts/sync-godot-adapter-from-sample.ps1` will automatically harvest the addon scripts back to the repository root while aggressively stripping any generated UID properties.

## Compiling the Core

The Godot host project compiles `addons/Unidote/Core/*.cs` alongside its own code. That folder is populated from the central `/Core` via `scripts/sync-core.(sh|ps1)`.

The `Samples/UnidoteGodotDemo` sample project inherently contains a physical copy of the addon locally to simulate true engine-level iteration. Changes to Godot-specific files within the Sample project must be synced back using `scripts/sync-godot-adapter-from-sample.ps1`.

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
