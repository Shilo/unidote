#!/usr/bin/env bash
# sync-godot-adapter-from-sample.sh
# Harvests the Godot adapter from the sample project back to the root Godot/ distribution directory,
# while stripping all UIDs to ensure the scaffold provides highly stable, reusable plugins.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"

source_dir="$root_dir/Samples/UnidoteGodotDemo/addons/Unidote"
dest_dir="$root_dir/Godot/addons/Unidote"

if [[ ! -d "$source_dir" ]]; then
    echo "error: Source Godot addon directory not found at $source_dir" >&2
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
    perl -0pi -e 's/[ \t]+uid[ \t]*=[ \t]*"uid:\/\/[^"]*"//g; s/^[ \t]*uid[ \t]*=[ \t]*"uid:\/\/[^"]*"\r?\n//mg;' "$file"
  done
}

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/Unidote"
cp -R "$source_dir/." "$staging/Unidote/"
strip_godot_uid_fields "$staging/Unidote"

mkdir -p "$(dirname "$dest_dir")"
rm -rf "$dest_dir"
mv "$staging/Unidote" "$dest_dir"

echo "synced Unidote godot addon from sample to root distribution, UIDs stripped."
