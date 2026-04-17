#!/usr/bin/env bash
# verify.sh — CI-only pre-release gate. Runs every forward sync script,
# then builds Core and the Godot sample via dotnet to confirm the synced
# state compiles. Fails fast on any step.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

cd "$repo_root"

bash ./scripts/sync-core.sh
bash ./scripts/sync-godot-adapter.sh
bash ./scripts/sync-unity-adapter.sh
bash ./scripts/test-unity-package-integrity.sh

dotnet build ./src/Unidote.Core/Unidote.Core.csproj --configuration Release
dotnet build ./samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj --configuration Release

echo "verification complete"
