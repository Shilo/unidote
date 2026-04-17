# Unidote — Unity Demo

Minimal Unity 6.4 project that verifies the engine-agnostic Unidote core via the local UPM package.

## Run

1. Open this folder (`Samples/UnidoteUnityDemo/`) in Unity 6.4.
2. Create an empty scene, add an empty GameObject, and attach the `HelloUnidote` component from `Assets/`.
3. Press **Play**.

The Console should print:

```
Hello, Unity Demo! — Unidote v0.1.0
```

## How It Works

`Packages/manifest.json` resolves `com.shilo.unidote` via the relative path `file:../../Unity`, so Unity pulls the adapter and Core straight from the repository — no sync step required for the sample.
