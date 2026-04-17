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

Create a `MonoBehaviour` in your Unity project that logs a hello from the `Unidote` type:

```csharp
using UnityEngine;
using Unidote;

public sealed class UnidoteBehaviour : MonoBehaviour
{
	private void Awake() => Debug.Log($"{nameof(Unidote)}: Hello World");
}
```

Attach the component to any GameObject and enter Play mode.

The `Runtime/Core/` folder is populated from `src/Unidote.Core` via `scripts/sync-core.(ps1|sh)`.

## Development

If you are developing this template:
- **Core logic:** Edit files in `src/Unidote.Core` and run `scripts/sync-core.ps1` or `.sh`. Do not edit files in `Runtime/Core/` directly — they are overwritten and carry an auto-generated header.
- **Unity adapter:** Open `samples/UnidoteUnityDemo` in Unity. The sample uses an embedded package copy under `Packages/com.shilo.unidote/`, so re-run `scripts/sync-unity-adapter.ps1 -NoPause` or `.sh` after adapter changes in `src/Unidote.Unity`.
