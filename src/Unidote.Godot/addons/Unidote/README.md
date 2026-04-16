# Unidote — Godot Addon

Drop-in Godot **4.6+** C# addon for the Unidote engine-agnostic core.

## Install

Copy this folder to your Godot project's `addons/Unidote/` directory, then enable the plugin from **Project → Project Settings → Plugins**.

Your project must be a C# Godot project (`.csproj` present). The addon compiles alongside your game code — no extra configuration required.

## Use

```csharp
using Godot;
using Unidote;
using Unidote.Simulation;

public partial class Main : Node
{
    private readonly SimulationTicker ticker = new();

    public override void _Ready() => GD.Print(UnidoteCore.Greet("Godot"));
    public override void _Process(double delta) => ticker.Tick((float)delta);
}
```

Or add a `UnidoteNode` to a scene and set its `Subject` property in the Inspector — it drives the Core ticker from `_Process` for you.

The `Core/` folder is populated from `src/Unidote.Core` via `scripts/sync-core.(ps1|sh)`.
