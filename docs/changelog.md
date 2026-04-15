# Changelog

All notable changes to Unidote are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-04-15

### Added

- **Core** — `netstandard2.1` class library exposing `UnidoteCore.Greet` and `UnidoteCore.Version`.
- **Unity package** (`com.shilo.unidote`) with `Runtime/Unidote.asmdef`, `UnidoteBehaviour` MonoBehaviour adapter, stable `.meta` GUIDs, and a `Hello Unidote` UPM sample.
- **Godot 4.6+ addon** (`addons/Unidote/`) with `plugin.cfg`, `UnidotePlugin` EditorPlugin, `UnidoteNode` Node adapter, and stable `.uid` files.
- **Samples** — `Samples/UnidoteGodotDemo` (standalone Godot 4.6+ project) and `Samples/UnidoteUnityDemo` (standalone Unity 6.4+ project) both referencing `/Core` directly to avoid drift.
- **Sync scripts** — idempotent `scripts/sync-core.sh` and `scripts/sync-core.ps1` mirror `/Core/*.cs` into both engine distribution folders.
- **Repo tooling** — `.editorconfig`, `.gitattributes`, `Directory.Build.props` (`TreatWarningsAsErrors`, `AnalysisLevel=latest-recommended`).
- **Documentation** — this site (`docs/`, `mkdocs.yml`) deployed to GitHub Pages.
