# Unidote — Godot Addon

Drop-in Godot **4.6+** C# addon scaffold for the engine-agnostic Unidote core.

## Install

Copy this folder to your Godot project's `addons/Unidote/` directory, then enable the plugin from **Project → Project Settings → Plugins**.

Your project must be a C# Godot project (`.csproj` present). The addon compiles alongside your game code.

## Use

Create a `Node` in your Godot project that logs a hello from the `Unidote` type:

```csharp
using Godot;
using Unidote;

public partial class UnidoteNode : Node
{
	public override void _Ready() => GD.Print($"{nameof(Unidote)}: Hello World");
}
```

Or attach a GDScript `Node` and log the same message:

```gdscript
extends Node

func _ready() -> void:
	print("%s: Hello World" % load("res://addons/Unidote/Core/Unidote.cs").resource_path.get_file().get_basename())
```

In the installed addon, the mirrored core file lives at `res://addons/Unidote/Core/Unidote.cs`, so the GDScript example loads that script resource and derives `Unidote` from its filename.

Add the node to any scene and run the project.

The `Core/` folder is populated from `src/Unidote.Core` via `scripts/sync-core.(ps1|sh)`.
