#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

cd "$repo_root"

if ! grep -q '"Shilo.Unidote.Unity"' "$repo_root/src/Unidote.Unity/Editor/Unidote.Editor.asmdef"; then
    echo "expected Unity editor asmdef to reference Shilo.Unidote.Unity" >&2
    exit 1
fi

bash "$repo_root/scripts/sync-core.sh" >/dev/null
bash "$repo_root/scripts/sync-unity-adapter.sh" >/dev/null

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

unexpected_markers=()
while IFS= read -r -d '' marker; do
    unexpected_markers+=("${marker#$repo_root/}")
done < <(find \
    "$repo_root/src/Unidote.Unity/Runtime/Core" \
    "$repo_root/src/Unidote.Godot/addons/Unidote/Core" \
    "$repo_root/samples/UnidoteGodotDemo/addons/Unidote/Core" \
    "$repo_root/samples/UnidoteUnityDemo/Packages/com.shilo.unidote/Runtime/Core" \
    -type f -name 'DO_NOT_EDIT.md' -print0)

if [[ ${#unexpected_markers[@]} -gt 0 ]]; then
    printf 'unexpected DO_NOT_EDIT markers:\n' >&2
    printf '  %s\n' "${unexpected_markers[@]}" >&2
    exit 1
fi

echo "unity package integrity checks passed"
