# REVIEW

Audit of the findings surfaced by code reviews. The following are left over issues, deferred items, and intentionally accepted states.

## Left over issues

### No compile/test CI for Core, Unity adapter, or Godot addon

**Reasoning:** The template ships no logic worth gating — `UnidoteCore.Greet` is a single string expression. A CI matrix against `dotnet build` + `dotnet test` + Unity Test Runner + `godot --headless --build-solutions` is the right next step once a fork adds code, but committing empty CI to an empty scaffold invites cargo-culting.
**Pickup hint:** See [`docs/architecture.md`](docs/architecture.md) → *Invariants the CI should enforce*. First workflow to add is the mirror-freshness gate, not the build matrix.

### Version string repeated in four places

**Reasoning:** Collapsing `Core/Unidote.cs`, `Unity/package.json`, `Unity/CHANGELOG.md`, and `Godot/addons/Unidote/plugin.cfg` onto a single `Directory.Build.props` property requires either a source generator or a build-time codegen step — both of which violate the "no tooling a human cannot read in 30 seconds" bar for a scaffold.
**Mitigation shipped:** [`docs/architecture.md`](docs/architecture.md#versioning) lists the four locations explicitly and `/Core/Unidote.cs` carries an inline comment flagging the invariant. A CI gate that greps each file for the expected version is also noted in the same doc section.

### License hardcodes a copyright year

**Reasoning:** A template should ship a concrete `LICENSE` that a fork replaces wholesale with their own name + year. A templated `{{YEAR}}` placeholder would fail `mkdocs build --strict` and make the initial commit look broken. Forks are expected to touch this file during their rename pass (tracked in [`docs/architecture.md`](docs/architecture.md#renaming-the-template)).

### `docs/requirements.txt` uses floor pins, not hash pins

**Reasoning:** MkDocs Material is a docs-time-only dependency with no runtime impact. Hash-pinning would require `pip-compile` tooling and monthly refresh PRs; the risk profile does not warrant it for a template docs site.

### `mkdocs build --strict` not verified locally in this environment

**Reasoning:** The dev shell for this repo is Windows + Git Bash and did not have `pip install mkdocs-material` available without polluting the system Python. The docs workflow (`.github/workflows/docs.yml`) runs `mkdocs build --strict --verbose` on every push to `main` touching `docs/**`, so the first merge on GitHub is the smoke test. If the strict build flags a broken link or missing nav entry, the fix lands as a follow-up `docs:` commit.

### `README.md` link to `https://shilocity.github.io/unidote/` will 404 until Pages is enabled

**Reasoning:** The link points to the *intended* Pages URL for the canonical repository. After the first green `Deploy Docs` workflow run, the repo owner must enable GitHub Pages in **Settings → Pages → Source: GitHub Actions**. Until then the link 404s — acceptable for a template that assumes the fork will enable Pages on their own shell.

---

## Open questions for future reviews

- When Core gains non-trivial logic, do we implement CI for testing in a single hardening PR, or incrementally?
- Is a `release-please`-style changelog-automation worth the complexity for a 0.x scaffold? Current answer: no.
- Should the Godot demo assert an expected log line in CI (via `godot --headless` + a grep on stdout)? Low cost, high leverage — candidate for the first CI workflow.

