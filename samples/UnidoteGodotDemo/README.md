# Unidote — Godot Demo

Minimal Godot 4.6 C# project that verifies the engine-agnostic Unidote core is linked.

## Run

1. Open `project.godot` in Godot 4.6 (.NET build).
2. Let Godot build the C# project (automatic on first open).
3. Press **Play**.

The Output pane should print:

```
Hello, Godot Demo! — Unidote v0.1.0
```

## How It Works

`UnidoteGodotDemo.csproj` compiles `/Core/*.cs` directly via a `<Compile Include>` link — no sync step required.
