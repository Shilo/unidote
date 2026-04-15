# Install

Three ways to consume Unidote. Pick the one that matches the project you are dropping it into.

## 1. Fork the template (recommended for library authors)

Use this when you want to build **your own** cross-engine library on top of the Unidote scaffold.

1. On GitHub, click **Use this template → Create a new repository** at [Shilocity/unidote](https://github.com/Shilocity/unidote).
2. Clone your fork:

    ```sh
    git clone https://github.com/<owner>/<your-fork>.git
    cd <your-fork>
    ```

3. Rename the namespace and package id to match your library. See the [Architecture](architecture.md#renaming-the-template) guide for the exact list of touch-points.
4. Add your engine-agnostic logic to `/Core/*.cs`.
5. Run the sync once:

    === "macOS · Linux · Git Bash"

        ```sh
        scripts/sync-core.sh
        ```

    === "Windows PowerShell"

        ```powershell
        scripts/sync-core.ps1
        ```

!!! tip "One-time setup"
    The sync script is only required after editing `/Core`. Samples under `/Samples` reference `/Core` **directly**, so they work without the sync step.

## 2. Install the Unity package

Use this when you want to pull Unidote into an existing Unity **6.4+** project.

### Git URL (recommended)

```jsonc title="Packages/manifest.json"
{
  "dependencies": {
    "com.shilo.unidote": "https://github.com/Shilocity/unidote.git?path=/Unity"
  }
}
```

The `?path=/Unity` suffix tells Unity Package Manager to resolve the package from the `/Unity` subfolder of the repository.

### Local path

```jsonc title="Packages/manifest.json"
{
  "dependencies": {
    "com.shilo.unidote": "file:/absolute/path/to/unidote/Unity"
  }
}
```

Relative `file:` paths resolve from the project root, which is useful in monorepos:

```jsonc
{ "com.shilo.unidote": "file:../../unidote/Unity" }
```

### Package Manager UI

**Window → Package Manager → + → Add package from git URL…** and paste `https://github.com/Shilocity/unidote.git?path=/Unity`.

## 3. Drop in the Godot addon

Use this when you want to pull Unidote into an existing Godot **4.6+** C# project.

1. Copy the folder `/Godot/addons/Unidote/` from the repository into your Godot project's `addons/` directory.
2. Open the Godot editor.
3. Go to **Project → Project Settings → Plugins** and enable **Unidote**.

!!! warning "C#-only"
    The addon is a C# plugin. Your Godot project must be a **.NET build** with a `.csproj` at the project root. GDScript-only projects will not compile the addon.

### Git submodule

For teams that want the addon to stay in sync with upstream:

```sh
git submodule add https://github.com/Shilocity/unidote.git vendor/unidote
ln -s ../../vendor/unidote/Godot/addons/Unidote addons/Unidote  # macOS / Linux
# On Windows, use `mklink /D` or just copy the folder.
```

## 4. Reference from plain .NET

Unidote's Core is a vanilla `netstandard2.1` class library. Any .NET 6+ project can reference it directly.

```xml title="YourProject.csproj"
<ItemGroup>
  <ProjectReference Include="../unidote/Core/Core.csproj" />
</ItemGroup>
```

Or compile the Core sources directly into your project (useful for Godot `.csproj` files that already include `.cs` via glob):

```xml title="YourProject.csproj"
<ItemGroup>
  <Compile Include="../unidote/Core/*.cs" LinkBase="Unidote" />
</ItemGroup>
```

This is the exact pattern used by [`Samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj`](https://github.com/Shilocity/unidote/blob/main/Samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj) — zero drift, zero sync step.

## Verify the install

Regardless of which path you chose, confirm it works by running the [Quick Start](quick-start.md).
