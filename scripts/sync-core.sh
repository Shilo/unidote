#!/usr/bin/env bash
# sync-core.sh — mirror canonical Core `.cs` files into the Unity and Godot
# distribution folders. Idempotent, UTF-8-safe, fails fast.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"

core_dir="$root_dir/src/Unidote.Core"
unity_core_dir="$root_dir/src/Unidote.Unity/Runtime/Core"
godot_core_dir="$root_dir/src/Unidote.Godot/addons/Unidote/Core"
godot_sample_core_dir="$root_dir/samples/UnidoteGodotDemo/addons/Unidote/Core"
unity_sample_core_dir="$root_dir/samples/UnidoteUnityDemo/Packages/com.shilo.unidote/Runtime/Core"
sync_targets="src/Unidote.Unity/Runtime/Core, src/Unidote.Godot/addons/Unidote/Core, samples/UnidoteGodotDemo/addons/Unidote/Core, samples/UnidoteUnityDemo/Packages/com.shilo.unidote/Runtime/Core"

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

mkdir -p "$unity_core_dir" "$godot_core_dir" "$godot_sample_core_dir" "$unity_sample_core_dir"

# Purge previously synced .cs files. Preserve Unity .meta and Godot .uid.
find "$unity_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true
find "$godot_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true
find "$godot_sample_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true
find "$unity_sample_core_dir" -type f -name '*.cs' -delete 2>/dev/null || true

header=$'// AUTO-GENERATED. DO NOT EDIT. Edit the matching file in the canonical Core source directory instead.\n'

generate_guid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr -d '-' | tr '[:upper:]' '[:lower:]'
        return
    fi

    if [[ -r /proc/sys/kernel/random/uuid ]]; then
        tr -d '-' </proc/sys/kernel/random/uuid | tr '[:upper:]' '[:lower:]'
        return
    fi

    if command -v python3 >/dev/null 2>&1; then
        python3 - <<'PY'
import uuid
print(uuid.uuid4().hex)
PY
        return
    fi

    python - <<'PY'
import uuid
print(uuid.uuid4().hex)
PY
}

ensure_unity_meta() {
    local asset_path="$1"
    local meta_path="${asset_path}.meta"

    if [[ -f "$meta_path" ]]; then
        return
    fi

    printf 'fileFormatVersion: 2\nguid: %s\n' "$(generate_guid)" > "$meta_path"
}

for src in "${sources[@]}"; do
    rel_path="${src#$core_dir/}"
    dest_u="$unity_core_dir/$rel_path"
    dest_g="$godot_core_dir/$rel_path"
    dest_gs="$godot_sample_core_dir/$rel_path"
    dest_us="$unity_sample_core_dir/$rel_path"

    mkdir -p "$(dirname "$dest_u")" "$(dirname "$dest_g")" "$(dirname "$dest_gs")" "$(dirname "$dest_us")"

    # printf preserves bytes verbatim — no locale-driven re-encoding.
    { printf '%s' "$header"; cat "$src"; } > "$dest_u"
    cp -f "$dest_u" "$dest_g"
    cp -f "$dest_u" "$dest_gs"
    cp -f "$dest_u" "$dest_us"

    ensure_unity_meta "$dest_u"
    ensure_unity_meta "$dest_us"
done

for unity_dir in "$unity_core_dir" "$unity_sample_core_dir"; do
    while IFS= read -r -d '' meta_path; do
        asset_path="${meta_path%.meta}"
        if [[ ! -f "$asset_path" ]]; then
            rm -f "$meta_path"
        fi
    done < <(find "$unity_dir" -type f -name '*.cs.meta' -print0)
done

# --- UTF-8 regression gate -------------------------------------------------
# Reject double-encoded cp1252→UTF-8 sequences (the classic "â€" mojibake)
# before they land in a mirror. Guards against editor or shell misconfigurations
# silently re-encoding em-dashes, smart quotes, or apostrophes.
mojibake_pattern=$'\xc3\xa2\xe2\x82\xac'
if grep -rlF --binary-files=text "$mojibake_pattern" \
        "$unity_core_dir" "$godot_core_dir" "$godot_sample_core_dir" "$unity_sample_core_dir" 2>/dev/null; then
    echo "error: mojibake detected in a mirrored file. Re-save the offending source as UTF-8 (no BOM) and re-run." >&2
    exit 2
fi

echo "synced ${#sources[@]} file(s) from src/Unidote.Core -> $sync_targets"
