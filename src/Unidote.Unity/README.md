# Unidote — Unity

Unity Package Manager distribution of the Unidote engine-agnostic core. Target: Unity **6.4+**.

## Install

Add to `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.shilo.unidote": "https://github.com/<owner>/unidote.git?path=/src/Unidote.Unity"
  }
}
```

## Use

Attach `UnidoteBehaviour` to any GameObject, or import the **Hello Unidote** sample from the Package Manager window.

```csharp
using UnityEngine;
using Unidote;
using Unidote.Simulation;

public sealed class Example : MonoBehaviour
{
    private readonly SimulationTicker ticker = new();

    private void Start() => Debug.Log(UnidoteCore.Greet("Unity"));
    private void Update() => ticker.Tick(Time.deltaTime);
}
```

The `Runtime/Core/` folder is populated from `src/Unidote.Core` via `scripts/sync-core.(ps1|sh)`.

## Development

If you are developing this template:
- **Core logic:** Edit files in `src/Unidote.Core` and run `scripts/sync-core.ps1` or `.sh`. Do not edit files in `Runtime/Core/` directly — they are overwritten and carry an auto-generated header.
- **Unity adapter:** Open `Samples/UnidoteUnityDemo` in Unity. The package is linked locally (`file:../../../src/Unidote.Unity`), so edits made to `UnidoteBehaviour.cs` or other adapter scripts in the IDE modify this folder directly.
