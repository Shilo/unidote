# Unidote — Godot Addon

Drop-in Godot **4.6+** C# addon for the Unidote engine-agnostic core.

## Install

Copy this folder to your Godot project's `addons/Unidote/` directory, then enable the plugin from **Project → Project Settings → Plugins**.

Your project must be a C# Godot project (`.csproj` present). The addon compiles alongside your game code — no extra configuration required.

## Use

```csharp
using Godot;
using Unidote;

public partial class Main : Node
{
    public override void _Ready() => GD.Print(UnidoteCore.Greet("Godot"));
}
```

Or add a `UnidoteNode` to a scene and set its `Subject` property in the Inspector.

The `Core/` folder is populated from the repository's `/Core` source of truth via `scripts/sync-core.(ps1|sh)`.
