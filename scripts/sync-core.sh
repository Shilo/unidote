#!/usr/bin/env bash
# sync-core.sh — mirror src/Unidote.Core/**/*.cs into the Unity and Godot
# distribution folders. Idempotent, UTF-8-safe, fails fast.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"

core_dir="$root_dir/src/Unidote.Core"
unity_core_dir="$root_dir/src/Unidote.Unity/Runtime/Core"
godot_core_dir="$root_dir/src/Unidote.Godot/addons/Unidote/Core"
godot_sample_core_dir="$root_dir/samples/UnidoteGodotDemo/addons/Unidote/Core"

if [[ ! -d "$core_dir" ]]; then
    echo "error: Core directory not found at $core_dir" >&2
    exit 1
fi

sources=()
while IFS= read -r -d $'\0'; do
    sources+=("$REPLY")
done < <(find "$core_dir" -type d \( -name 'bin' -o -name 'obj' \) -prune -o -type f -name '*.cs' -print0)

if [[ ${#sources[@]} -eq 0 ]]; then
    echo "error: no .cs files found under $core_dir" >&2
    exit 1
fi

mkdir -p "$unity_core_dir" "$godot_core_dir" "$godot_sample_core_dir"

# Purge previously synced .cs files. Preserve Unity .meta and Godot .uid.
find "$unity_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true
find "$godot_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true
find "$godot_sample_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true

header=$'// AUTO-GENERATED. DO NOT EDIT. Edit source in src/Unidote.Core instead.\n'

for src in "${sources[@]}"; do
    rel_path="${src#$core_dir/}"
    dest_u="$unity_core_dir/$rel_path"
    dest_g="$godot_core_dir/$rel_path"
    dest_gs="$godot_sample_core_dir/$rel_path"

    mkdir -p "$(dirname "$dest_u")" "$(dirname "$dest_g")" "$(dirname "$dest_gs")"

    # printf preserves bytes verbatim — no locale-driven re-encoding.
    { printf '%s' "$header"; cat "$src"; } > "$dest_u"
    cp -f "$dest_u" "$dest_g"
    cp -f "$dest_u" "$dest_gs"
done

# --- UTF-8 regression gate -------------------------------------------------
# Reject double-encoded cp1252→UTF-8 sequences (the classic "â€" mojibake)
# before they land in a mirror. Guards against editor or shell misconfigurations
# silently re-encoding em-dashes, smart quotes, or apostrophes.
mojibake_pattern=$'\xc3\xa2\xe2\x82\xac'
if grep -rlF --binary-files=text "$mojibake_pattern" \
        "$unity_core_dir" "$godot_core_dir" "$godot_sample_core_dir" 2>/dev/null; then
    echo "error: mojibake detected in a mirrored file. Re-save the offending source as UTF-8 (no BOM) and re-run." >&2
    exit 2
fi

echo "synced ${#sources[@]} file(s) from src/Unidote.Core -> Unity, Godot, Godot Sample"
