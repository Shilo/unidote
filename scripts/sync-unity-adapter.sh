#!/usr/bin/env bash
# sync-unity-adapter.sh — mirror the Unity adapter's non-Core files into the
# Unity sample project as an embedded package. Idempotent. Preserves the
# Runtime/Core subtree in the destination so sync-core.sh remains the single
# owner of Core mirrors.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${1:-$script_dir/..}"
repo_root="$(cd "$repo_root" && pwd)"

source_dir="$repo_root/src/Unidote.Unity"
dest="$repo_root/samples/UnidoteUnityDemo/Packages/com.shilo.unidote"

if [[ ! -d "$source_dir" || ! -f "$source_dir/package.json" ]]; then
    echo "error: Unity package source not found at $source_dir" >&2
    exit 1
fi

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/package"

# Copy everything except the Runtime/Core mirror dir (handled by sync-core.sh)
cp -R "$source_dir"/. "$staging/package/"
rm -rf "$staging/package/Runtime/Core"

# Preserve the existing Runtime/Core dir in dest — only replace non-Core files
mkdir -p "$dest"
find "$dest" -mindepth 1 \
    -not -path "$dest/Runtime" \
    -not -path "$dest/Runtime/Core" \
    -not -path "$dest/Runtime/Core/*" \
    -delete 2>/dev/null || true
cp -R "$staging/package"/. "$dest/"

echo "synced Unity adapter from src/Unidote.Unity -> samples/UnidoteUnityDemo/Packages/com.shilo.unidote"
