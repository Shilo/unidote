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

Add the node to any scene and run the project.

The `Core/` folder is populated from `src/Unidote.Core` via `scripts/sync-core.(ps1|sh)`.
