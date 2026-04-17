#!/usr/bin/env bash
# sync-godot-adapter-from-sample.sh — reverse flow. Pulls edits made in the
# Godot sample project back into src/Unidote.Godot. Skips the Core/ subtree
# (owned by sync-core.sh) so Core edits must happen in src/Unidote.Core.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${1:-$script_dir/..}"
repo_root="$(cd "$repo_root" && pwd)"

source_dir="$repo_root/samples/UnidoteGodotDemo/addons/Unidote"
dest="$repo_root/src/Unidote.Godot/addons/Unidote"

if [[ ! -d "$source_dir" || ! -f "$source_dir/plugin.cfg" ]]; then
    echo "error: sample Godot addon not found at $source_dir" >&2
    exit 1
fi

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/addon"

# Copy everything except Core (owned by sync-core.sh)
cp -R "$source_dir"/. "$staging/addon/"
rm -rf "$staging/addon/Core"

# Preserve the existing Core/ dir in dest — only replace non-Core files
mkdir -p "$dest"
find "$dest" -mindepth 1 \
    -not -path "$dest/Core" \
    -not -path "$dest/Core/*" \
    -not -name '.gitkeep' -delete 2>/dev/null || true
cp -R "$staging/addon"/. "$dest/"

echo "pulled Godot adapter from samples/UnidoteGodotDemo/addons/Unidote -> src/Unidote.Godot/addons/Unidote"
