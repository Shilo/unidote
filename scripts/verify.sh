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

missing_meta=()
for unity_tree in \
    "$repo_root/src/Unidote.Unity" \
    "$repo_root/samples/UnidoteUnityDemo/Packages/com.shilo.unidote"
do
    while IFS= read -r -d '' file; do
        if [[ ! -f "$file.meta" ]]; then
            missing_meta+=("${file#$repo_root/}")
        fi
    done < <(find "$unity_tree" -type f ! -name '*.meta' -print0)
done

if [[ ${#missing_meta[@]} -gt 0 ]]; then
    printf 'missing Unity .meta files:\n' >&2
    printf '  %s\n' "${missing_meta[@]}" >&2
    exit 1
fi

echo "unity package integrity checks passed"

dotnet build ./src/Unidote.Core/Unidote.Core.csproj --configuration Release
dotnet build ./samples/UnidoteGodotDemo/UnidoteGodotDemo.csproj --configuration Release

echo "verification complete"
