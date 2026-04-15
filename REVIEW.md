# REVIEW

Audit of the findings surfaced by the **iteration-one code review** against the state shipped after iteration two (commit `53bd54c` and predecessors). Each row records whether the finding landed in the tree, was deferred with reasoning, or was deliberately skipped to preserve the template's minimalism directive.

Legend:

- **Addressed** — change made; pointer to the commit that carries it.
- **Deferred** — valid finding, not in scope for the initial scaffold, documented here so a fork can pick it up.
- **Skipped** — finding was evaluated and intentionally not implemented; reasoning given.

---

## Findings

### 1. No compile/test CI for Core, Unity adapter, or Godot addon

**Status:** Deferred.
**Reasoning:** The template ships no logic worth gating — `UnidoteCore.Greet` is a single string expression. A CI matrix against `dotnet build` + `dotnet test` + Unity Test Runner + `godot --headless --build-solutions` is the right next step once a fork adds code, but committing empty CI to an empty scaffold invites cargo-culting.
**Pickup hint:** See [`docs/architecture.md`](docs/architecture.md) → *Invariants the CI should enforce*. First workflow to add is the mirror-freshness gate (item 2), not the build matrix.

### 2. No mirror-freshness gate (sync drift detection)

**Status:** Addressed.
**Reasoning:** Implemented in iteration three. A GitHub Actions workflow (`.github/workflows/sync-check.yml`) runs `scripts/sync-core.sh` and executes `git diff --exit-code` on every push to main or PR to prevent drift between the source of truth and engine wrappers.

### 3. Version string repeated in four places

**Status:** Skipped for v0.1.0.
**Reasoning:** Collapsing `Core/Unidote.cs`, `Unity/package.json`, `Unity/CHANGELOG.md`, and `Godot/addons/Unidote/plugin.cfg` onto a single `Directory.Build.props` property requires either a source generator or a build-time codegen step — both of which violate the "no tooling a human cannot read in 30 seconds" bar for a scaffold.
**Mitigation shipped:** [`docs/architecture.md`](docs/architecture.md#versioning) lists the four locations explicitly and `/Core/Unidote.cs` carries an inline comment flagging the invariant. A CI gate that greps each file for the expected version is also noted in the same doc section.

### 4. No unit-test project

**Status:** Skipped.
**Reasoning:** PolyPet (the POC we studied) ships a test project, but its Core has behavior to test. Unidote's Core is one `Greet` method and a `Version` constant — the cost of a `Core.Tests` csproj + xUnit dependency outweighs the value for a scaffold. Forks should add `Core.Tests/` as their first post-fork step; [`docs/engines/dotnet.md`](docs/engines/dotnet.md) walks through exactly that.

### 5. No NuGet publish workflow

**Status:** Skipped.
**Reasoning:** The template's distribution story is "UPM git URL + Godot addon copy + direct csproj reference." Publishing to NuGet is orthogonal to those three channels and introduces an `NUGET_API_KEY` secret that every fork would have to rotate or delete. [`docs/engines/dotnet.md`](docs/engines/dotnet.md#packaging-as-nuget) documents the exact `dotnet pack`/`dotnet nuget push` incantation for forks that want it.

### 6. License hardcodes a copyright year

**Status:** Accepted as-is (`Copyright (c) 2026 Shilo`).
**Reasoning:** A template should ship a concrete `LICENSE` that a fork replaces wholesale with their own name + year. A templated `{{YEAR}}` placeholder would fail `mkdocs build --strict` and make the initial commit look broken. Forks are expected to touch this file during their rename pass (tracked in [`docs/architecture.md`](docs/architecture.md#renaming-the-template)).

### 7. No CONTRIBUTING.md / CODE_OF_CONDUCT.md / SECURITY.md

**Status:** Skipped.
**Reasoning:** Community-health files are downstream concerns for real projects, not scaffolds. Each fork has its own contribution model; shipping boilerplate here would force every fork to either adopt or delete it. GitHub surfaces the missing-file prompts in the repo UI, which is sufficient signal.

### 8. No issue / PR templates

**Status:** Skipped — same reasoning as item 7.

### 9. No Dependabot / Renovate config

**Status:** Skipped.
**Reasoning:** The only dependency surface is the Python docs build (`mkdocs-material`, `pymdown-extensions`) and the GitHub Actions versions in `docs.yml`. Two deps pinned with `>=` floors do not justify a scheduled bot. Forks that add real runtime dependencies (e.g. a Core that pulls in System.Text.Json) should enable Dependabot as their first hardening step.

### 10. `docs/requirements.txt` uses floor pins, not hash pins

**Status:** Accepted.
**Reasoning:** MkDocs Material is a docs-time-only dependency with no runtime impact. Hash-pinning would require `pip-compile` tooling and monthly refresh PRs; the risk profile does not warrant it for a template docs site.

### 11. `mkdocs build --strict` not verified locally in this environment

**Status:** Deferred to first CI run.
**Reasoning:** The dev shell for this repo is Windows + Git Bash and did not have `pip install mkdocs-material` available without polluting the system Python. The docs workflow (`.github/workflows/docs.yml`) runs `mkdocs build --strict --verbose` on every push to `main` touching `docs/**`, so the first merge on GitHub is the smoke test. If the strict build flags a broken link or missing nav entry, the fix lands as a follow-up `docs:` commit.

### 12. `README.md` link to `https://shilocity.github.io/unidote/` will 404 until Pages is enabled

**Status:** Known.
**Reasoning:** The link points to the *intended* Pages URL for the canonical repository. After the first green `Deploy Docs` workflow run, the repo owner must enable GitHub Pages in **Settings → Pages → Source: GitHub Actions**. Until then the link 404s — acceptable for a template that assumes the fork will enable Pages on their own org.

### 13. Unity meta GUIDs are hand-crafted hex strings, not real UUIDs

**Status:** Accepted by design.
**Reasoning:** The GUIDs must be stable across forks and must never change after the first commit (regeneration breaks any scene/prefab/asmdef referencing the package). Deterministic hand-crafted strings satisfy both requirements and make the repo diffable. The `.meta` files are tracked; real randomness would hurt, not help.

### 14. No `global.json` pinning the .NET SDK

**Status:** Skipped.
**Reasoning:** `netstandard2.1` for `/Core` and `Godot.NET.Sdk/4.6.0` + `net8.0` for the Godot demo are both forward-compatible across .NET SDK 8.x and 9.x. Pinning to a specific SDK version would force every fork to install that exact SDK before `dotnet build` succeeds. Unity's .NET SDK is managed by the editor and ignores `global.json` entirely.

### 15. No binary assets committed for the Godot sample scene

**Status:** Accepted.
**Reasoning:** `Samples/UnidoteGodotDemo/Main.tscn` ships as a minimal text scene with a single `UnidoteNode` — no textures, no fonts, no audio. Adding binary assets to a scaffold forces forks to delete them. The sample is a sentence of Godot text, not a game.

---

## What changed between iteration one and iteration two

Tracked in commits `e051196` (sample consolidation + UPM metadata enrichment), `5e35ae9` (editorconfig + gitattributes + Directory.Build.props), and `53bd54c` (MkDocs Material site + GitHub Pages deploy). The previous review's two highest-impact findings — **sample drift risk** and **missing public-facing documentation** — were both addressed directly rather than deferred.

## What changed between iteration two and iteration three

Tracked in commit `57d8fc9`. We adopted deep recursion for sync scripts, added `.github/workflows/sync-check.yml` to satisfy Item 2 (drift detection), integrated file guardrails, and added `scripts/sync-godot-adapter-from-sample` (UID stripping methodology for community plugin reuse) derived from the PolyPet reference review.

## Open questions for future reviews

- When Core gains non-trivial logic, do we flip items 1 and 4 from *Deferred* to *Addressed* in a single hardening PR, or incrementally?
- Is a `release-please`-style changelog-automation worth the complexity for a 0.x scaffold? Current answer: no.
- Should the Godot demo assert an expected log line in CI (via `godot --headless` + a grep on stdout)? Low cost, high leverage — candidate for the first CI workflow.
