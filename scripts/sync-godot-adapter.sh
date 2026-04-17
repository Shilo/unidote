#!/usr/bin/env bash
# sync-godot-adapter.sh — mirror src/Unidote.Godot/addons/Unidote/ (non-Core files)
# into the Godot sample project. Idempotent. Strips Godot UID fields to prevent
# registry collisions when the addon is copied into downstream projects.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${1:-$script_dir/..}"
repo_root="$(cd "$repo_root" && pwd)"

source_dir="$repo_root/src/Unidote.Godot/addons/Unidote"
dest="$repo_root/samples/UnidoteGodotDemo/addons/Unidote"

if [[ ! -d "$source_dir" || ! -f "$source_dir/plugin.cfg" ]]; then
    echo "error: addon source not found at $source_dir" >&2
    exit 1
fi

strip_godot_uid_fields() {
    local root="$1"
    find "$root" -type f \( \
        -name '*.cfg' -o \
        -name '*.import' -o \
        -name '*.res' -o \
        -name '*.theme' -o \
        -name '*.tscn' -o \
        -name '*.tres' \
    \) -print0 | while IFS= read -r -d '' file; do
        perl -0pi -e \
            's/[ \t]+uid[ \t]*=[ \t]*"uid:\/\/[^"]*"//g; s/^[ \t]*uid[ \t]*=[ \t]*"uid:\/\/[^"]*"\r?\n//mg;' \
            "$file"
    done
}

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/addon"

# Copy everything except the Core/ mirror dir (handled by sync-core.sh)
cp -R "$source_dir"/. "$staging/addon/"
rm -rf "$staging/addon/Core"

strip_godot_uid_fields "$staging/addon"

# Preserve the existing Core/ dir in dest — only replace non-Core files
mkdir -p "$dest"
find "$dest" -mindepth 1 -not -path "$dest/Core" -not -path "$dest/Core/*" \
    -delete 2>/dev/null || true
cp -R "$staging/addon"/. "$dest/"

echo "synced Godot adapter from src/Unidote.Godot/addons/Unidote -> samples/UnidoteGodotDemo/addons/Unidote"
