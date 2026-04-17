#!/usr/bin/env bash
# pull-unity-adapter-from-sample.sh — reverse flow. Pulls edits made in the
# Unity sample project's embedded package back into the adapter source tree.
# Skips the Runtime/Core subtree (owned by sync-core.sh) so Core edits must
# happen in the canonical Core source tree.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${1:-$script_dir/..}"
repo_root="$(cd "$repo_root" && pwd)"

source_dir="$repo_root/samples/UnidoteUnityDemo/Packages/com.shilo.unidote"
dest="$repo_root/src/Unidote.Unity"

if [[ ! -d "$source_dir" || ! -f "$source_dir/package.json" ]]; then
    echo "error: sample Unity package not found at $source_dir" >&2
    exit 1
fi

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/package"

# Copy everything except Runtime/Core (owned by sync-core.sh)
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

echo "pulled Unity adapter from samples/UnidoteUnityDemo/Packages/com.shilo.unidote -> src/Unidote.Unity"
