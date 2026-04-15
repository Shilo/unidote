# Unidote — Unity

Unity Package Manager distribution of the Unidote engine-agnostic core. Target: Unity **6.4+**.

## Install

Add to `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.shilo.unidote": "https://github.com/<owner>/unidote.git?path=/Unity"
  }
}
```

## Use

Attach `UnidoteBehaviour` to any GameObject, or import the **Hello Unidote** sample from the Package Manager window.

```csharp
using UnityEngine;
using Unidote;

public sealed class Example : MonoBehaviour
{
    private void Start() => Debug.Log(UnidoteCore.Greet("Unity"));
}
```

The `Runtime/Core/` folder is populated from the repository's `/Core` source of truth via `scripts/sync-core.(ps1|sh)`.

## Development

If you are developing this template:
- **Core Logic:** Edit files in the repository root `/Core` and run `scripts/sync-core.ps1` or `.sh`. Do not edit files directly in `Runtime/Core/` (they are overwritten and guarded by an auto-generated header).
- **Unity Wrapper Logic:** Open the `Samples/UnidoteUnityDemo` project. The package is linked locally (`file:../../Unity`), so edits made to `UnidoteBehaviour.cs` or other Unity-specific scripts in the IDE modify this folder directly.
