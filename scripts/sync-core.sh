#!/usr/bin/env bash
# sync-core.sh — mirror /Core/**/*.cs into the Unity and Godot distribution folders.
# Idempotent. Safe to run repeatedly. Exits non-zero on any error.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"

core_dir="$root_dir/Core"
unity_core_dir="$root_dir/Unity/Runtime/Core"
godot_core_dir="$root_dir/Godot/addons/Unidote/Core"

if [[ ! -d "$core_dir" ]]; then
    echo "error: Core directory not found at $core_dir" >&2
    exit 1
fi

sources=()
while IFS=  read -r -d $'\0'; do
    sources+=("$REPLY")
done < <(find "$core_dir" -type d \( -name 'bin' -o -name 'obj' \) -prune -o -type f -name '*.cs' -print0)

if [[ ${#sources[@]} -eq 0 ]]; then
    echo "error: no .cs files found under $core_dir" >&2
    exit 1
fi

mkdir -p "$unity_core_dir" "$godot_core_dir"

# Purge previously synced .cs files. Preserve Unity .meta and Godot .uid files.
find "$unity_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true
find "$godot_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true

for src in "${sources[@]}"; do
    rel_path="${src#$core_dir/}"
    dest_u="$unity_core_dir/$rel_path"
    dest_g="$godot_core_dir/$rel_path"
    
    mkdir -p "$(dirname "$dest_u")" "$(dirname "$dest_g")"
    cp -f "$src" "$dest_u"
    cp -f "$src" "$dest_g"
done

echo "synced ${#sources[@]} file(s) from Core/ -> Unity/Runtime/Core and Godot/addons/Unidote/Core"
