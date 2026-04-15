# Unidote — Unity

Unity Package Manager distribution of the Unidote engine-agnostic core.

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
