# Unity 6.4+

Detailed reference for the Unity adapter.

## Overview

The `/Unity` folder is a **UPM-compliant package** with the id `com.shilo.unidote`. Its layout follows the [official Unity package layout](https://docs.unity3d.com/Manual/cus-layout.html):

```
Unity/
├── package.json          # UPM manifest
├── CHANGELOG.md          # Semantic-versioned history
├── README.md             # Shown on the Package Manager details pane
├── LICENSE.md            # MIT
├── Runtime/
│   ├── Unidote.asmdef    # Assembly definition → Shilo.Unidote.dll
│   ├── UnidoteBehaviour.cs
│   └── Core/             # CI-synced mirror of /Core (git-ignored, .meta tracked)
└── Samples~/
    └── HelloUnidote/     # UPM sample, importable from Package Manager
```

The `Samples~` tilde suffix tells Unity to **ignore** the folder by default — it is only imported when the user clicks **Import** from the Package Manager UI.

## Install

See [Install → Unity package](../install.md#2-install-the-unity-package).

## Assembly

The package compiles into a single assembly:

```
Shilo.Unidote.dll
```

...defined by `Runtime/Unidote.asmdef`. It has **no engine references beyond default** and exposes two namespaces:

| Namespace         | Purpose                                     |
| ----------------- | ------------------------------------------- |
| `Unidote`         | Engine-agnostic Core (mirrored from `/Core`) |
| `Unidote.Unity`   | Unity-specific adapters (MonoBehaviour…)    |

## Using `UnidoteCore`

```csharp
using UnityEngine;
using Unidote;

public sealed class Example : MonoBehaviour
{
    private void Start()
    {
        Debug.Log(UnidoteCore.Greet("Unity"));
    }
}
```

## Using `UnidoteBehaviour`

The package ships a ready-to-use adapter component.

1. Select a GameObject.
2. **Add Component → Unidote → Unidote Behaviour**.
3. Set the **Subject** field in the Inspector.
4. Press Play — the greeting appears in the Console.

```csharp
namespace Unidote.Unity
{
    [AddComponentMenu("Unidote/Unidote Behaviour")]
    [DisallowMultipleComponent]
    public sealed class UnidoteBehaviour : MonoBehaviour
    {
        [SerializeField] private string subject = "Unity";
        private void Start() => Debug.Log(UnidoteCore.Greet(subject), this);
    }
}
```

## Importing the Hello Unidote sample

1. **Window → Package Manager**.
2. Select **Unidote**.
3. Expand **Samples**.
4. Click **Import** next to **Hello Unidote**.
5. The sample is copied to `Assets/Samples/Unidote/<version>/Hello Unidote/`.

## GUID stability

Unity identifies assets by the **GUIDs stored in `.meta` files**. Unidote hard-codes stable GUIDs so that:

- References survive a fresh clone.
- The sync script can rewrite the `.cs` files under `Runtime/Core/` without invalidating existing scene/prefab references.

The tracked `.meta` files are:

| File                                    | GUID              |
| --------------------------------------- | ----------------- |
| `Runtime.meta`                          | `1a2b...a7b`      |
| `Runtime/Core.meta`                     | `2b3c...a7b8`     |
| `Runtime/Unidote.asmdef.meta`           | `3c4d...a7b8`     |
| `Runtime/UnidoteBehaviour.cs.meta`      | `4d5e...b7c8`     |
| `Runtime/Core/Unidote.cs.meta`          | `5e6f...c7d8`     |
| `Samples~/HelloUnidote/HelloUnidote.cs.meta` | `708192...657a` |

!!! warning "Do not edit GUIDs"
    If you rename the namespace or package id, keep the `.meta` GUIDs unchanged so existing scenes don't lose references after the rename.

## Distribution Channels

| Channel                | Supported |
| ---------------------- | --------- |
| Git URL (with `?path=/Unity`) | ✅ |
| Local `file:` path           | ✅ |
| Tarball (`.tgz`)             | ✅ (use `npm pack` on the `/Unity` folder) |
| Unity Asset Store            | ✅ (export the folder as a `.unitypackage`) |
| OpenUPM                       | ⏳ (not submitted yet) |

## Troubleshooting

!!! question "Unity complains about `Unidote.Core` missing from Runtime/Core"
    Run the sync script: `scripts/sync-core.sh` or `scripts/sync-core.ps1`.

!!! question "Package Manager error: `com.shilo.unidote` is not found"
    Check the Git URL includes `?path=/Unity` — the manifest is inside the `/Unity` subfolder, not at the repo root.

!!! question "Sample scripts have a purple compile error after import"
    Unity reassigns GUIDs on import. The errors clear on the next domain reload — or right-click **Reimport** on the sample folder.
