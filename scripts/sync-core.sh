#!/usr/bin/env bash
# sync-core.sh — mirror /Core/*.cs into the Unity and Godot distribution folders.
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

shopt -s nullglob
sources=("$core_dir"/*.cs)
shopt -u nullglob

if [[ ${#sources[@]} -eq 0 ]]; then
    echo "error: no .cs files found under $core_dir" >&2
    exit 1
fi

mkdir -p "$unity_core_dir" "$godot_core_dir"

# Purge previously synced .cs (and Godot .cs.uid) files. Preserve Unity .meta.
find "$unity_core_dir" -maxdepth 1 -type f -name '*.cs' -delete
find "$godot_core_dir" -maxdepth 1 -type f \( -name '*.cs' -o -name '*.cs.uid' \) -delete

for src in "${sources[@]}"; do
    cp -f "$src" "$unity_core_dir/"
    cp -f "$src" "$godot_core_dir/"
done

echo "synced ${#sources[@]} file(s) from Core/ -> Unity/Runtime/Core and Godot/addons/Unidote/Core"
