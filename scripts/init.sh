#!/usr/bin/env bash
#
# init.sh
# Rebrand this scaffold for a fresh fork.
#
# Reads the current project identity from the root .slnx (or .sln) file
# and the current author name from the sample Unity package.json, prompts
# for replacements, then rewrites every matching text occurrence and
# renames every matching file or folder across the whitelisted paths.
#
# Each identity has two case variants:
#   project → PascalCase (spaces removed)       + kebab-case (spaces → dashes)
#   author  → display    (title case, spaces OK) + kebab-case (spaces → dashes)
#
# Display / PascalCase variants are replaced first so the kebab sweep
# does not collide with tokens that were just written.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# --- DETECT CURRENT IDENTITY ---

# Current project name comes from the root .slnx (or .sln) basename. If no
# solution file exists (e.g. after a partial rebrand deleted it) we fall
# back to the template's original value, "Unidote".
PROJECT_FALLBACK="Unidote"

SLN_PATH=$(find . -maxdepth 1 \( -name "*.slnx" -o -name "*.sln" \) | head -n 1)
if [[ -n "$SLN_PATH" ]]; then
    OLD_PROJECT_PASCAL=$(basename "$SLN_PATH")
    OLD_PROJECT_PASCAL="${OLD_PROJECT_PASCAL%.*}"
else
    OLD_PROJECT_PASCAL="$PROJECT_FALLBACK"
fi
OLD_PROJECT_KEBAB=$(echo "$OLD_PROJECT_PASCAL" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')

# Current author comes from the sample Unity package.json → author.name.
# That file carries the unmodified template author. If missing (e.g. after
# a previous rebrand removed or renamed the sample) we fall back to the
# template's original value, "Shilo".
AUTHOR_FALLBACK="Shilo"
SAMPLE_PACKAGE_JSON="samples/UnidoteUnityDemo/Packages/com.shilo.unidote/package.json"

OLD_AUTHOR_DISPLAY=""
if [[ -f "$SAMPLE_PACKAGE_JSON" ]]; then
    # Object form: "author": { "name": "..." }
    OLD_AUTHOR_DISPLAY=$(grep -A2 '"author"' "$SAMPLE_PACKAGE_JSON" \
        | grep -m1 '"name"' \
        | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
    # String form: "author": "..."
    if [[ -z "$OLD_AUTHOR_DISPLAY" ]]; then
        OLD_AUTHOR_DISPLAY=$(grep -m1 -E '"author"[[:space:]]*:[[:space:]]*"' "$SAMPLE_PACKAGE_JSON" \
            | sed -E 's/.*"author"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
    fi
fi
if [[ -z "$OLD_AUTHOR_DISPLAY" ]]; then
    OLD_AUTHOR_DISPLAY="$AUTHOR_FALLBACK"
fi
OLD_AUTHOR_KEBAB=$(echo "$OLD_AUTHOR_DISPLAY" \
    | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' \
    | tr '[:upper:]' '[:lower:]' \
    | tr -s ' ' '-')

echo -e "\nRebranding Workspace"
echo "Current Project: $OLD_PROJECT_PASCAL"
echo "Current Author:  $OLD_AUTHOR_DISPLAY"
echo "-------------------------------------------"

# --- PROMPT ---

prompt_trimmed() {
    # prompt_trimmed <label> <example>
    local label="$1" example="$2" raw
    read -p "New ${label} (e.g., ${example}): " raw
    # trim leading/trailing whitespace and collapse internal runs
    echo "$raw" | awk '{$1=$1};1'
}

NEW_PROJECT_RAW=$(prompt_trimmed "Project Name" "My Project")
if [[ -z "$NEW_PROJECT_RAW" ]]; then
    echo "Error: Project name cannot be empty." >&2
    exit 1
fi

NEW_AUTHOR_RAW=$(prompt_trimmed "Author Name" "John Doe")
if [[ -z "$NEW_AUTHOR_RAW" ]]; then
    echo "Error: Author name cannot be empty." >&2
    exit 1
fi

# --- DERIVE NEW IDENTIFIERS ---

titlecase_words() {
    # Uppercase first letter of each whitespace-separated word, lowercase the rest.
    awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1'
}

# Display-case a raw input.
# Multi-word input → Title Case. Single-token input → preserved verbatim
# so the user can pass PascalCase/camelCase ("MyProject", "shiloDev") without
# being flattened to "Myproject" / "Shilodev".
display_case() {
    local raw="$1"
    if [[ "$raw" == *[[:space:]]* ]]; then
        echo "$raw" | titlecase_words
    else
        echo "$raw"
    fi
}

# Kebab-case a raw input.
# Multi-word input → lowercase + spaces → dashes.
# Single-token input → insert dash between lowercase/digit and uppercase
# so "MyProject" becomes "my-project" (camel → kebab).
kebab_case() {
    local raw="$1"
    if [[ "$raw" == *[[:space:]]* ]]; then
        echo "$raw" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-'
    else
        echo "$raw" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]'
    fi
}

# Project: PascalCase (no spaces) + kebab-case.
NEW_PROJECT_PASCAL=$(display_case "$NEW_PROJECT_RAW" | tr -d ' ')
NEW_PROJECT_KEBAB=$(kebab_case "$NEW_PROJECT_RAW")

# Author: display (title case, spaces preserved) + kebab-case.
# The display variant keeps spaces so human-readable fields like
# package.json → author.name and Godot plugin.cfg → author stay intact.
# The kebab variant powers package IDs (com.<author>.<project>),
# GitHub slugs, doc URLs, and asmdef prefixes.
NEW_AUTHOR_DISPLAY=$(display_case "$NEW_AUTHOR_RAW")
NEW_AUTHOR_KEBAB=$(kebab_case "$NEW_AUTHOR_RAW")

echo -e "\nInitializing Rebrand..."
echo "-------------------------------------------"
printf "Project Pascal : %-20s -> %s\n" "$OLD_PROJECT_PASCAL" "$NEW_PROJECT_PASCAL"
printf "Project kebab  : %-20s -> %s\n" "$OLD_PROJECT_KEBAB"  "$NEW_PROJECT_KEBAB"
printf "Author display : %-20s -> %s\n" "$OLD_AUTHOR_DISPLAY" "$NEW_AUTHOR_DISPLAY"
printf "Author kebab   : %-20s -> %s\n" "$OLD_AUTHOR_KEBAB"   "$NEW_AUTHOR_KEBAB"
echo "-------------------------------------------"
echo

# --- TARGETS ---

WHITELIST=("src" "samples" "scripts" ".github" "docs" \
           "README.md" "mkdocs.yml" "Directory.Build.props" "Directory.Packages.props" "research.md" \
           ".gitignore" ".gitattributes")
if [[ -n "$SLN_PATH" ]]; then
    WHITELIST+=("$(basename "$SLN_PATH")")
fi

EXISTING_TARGETS=()
for item in "${WHITELIST[@]}"; do
    [[ -e "$item" ]] && EXISTING_TARGETS+=("$item")
done

if [[ ${#EXISTING_TARGETS[@]} -eq 0 ]]; then
    echo "Error: No whitelisted targets exist." >&2
    exit 1
fi

# --- REPLACEMENT PAIRS ---
#
# Ordered PascalCase / display first so the lowercase / kebab sweep does
# not touch tokens that were just replaced. Project and author share the
# same mechanism — only the derivation above differs.

REPLACE_OLD=(
    "$OLD_PROJECT_PASCAL"
    "$OLD_AUTHOR_DISPLAY"
    "$OLD_PROJECT_KEBAB"
    "$OLD_AUTHOR_KEBAB"
)
REPLACE_NEW=(
    "$NEW_PROJECT_PASCAL"
    "$NEW_AUTHOR_DISPLAY"
    "$NEW_PROJECT_KEBAB"
    "$NEW_AUTHOR_KEBAB"
)

# Combined regex used to detect files worth rewriting (cheap precheck)
JOINED_OLD=$(IFS='|'; echo "${REPLACE_OLD[*]}")

# Two-phase sed with unique placeholder markers. Single-pass sed would
# chain-replace when a NEW value contains another OLD token (e.g. if the
# new project name contained "shilo" the author-kebab sweep would corrupt
# it). Marker round-trip isolates each substitution.
SED_TO_MARKER=()
SED_FROM_MARKER=()
for i in "${!REPLACE_OLD[@]}"; do
    marker="__UNIDOTE_REBRAND_${i}__"
    SED_TO_MARKER+=(-e "s|${REPLACE_OLD[$i]}|${marker}|g")
    SED_FROM_MARKER+=(-e "s|${marker}|${REPLACE_NEW[$i]}|g")
done

# Apply every pair to a single string (file and folder basenames).
rename_string() {
    local name="$1"
    name=$(echo "$name" | sed "${SED_TO_MARKER[@]}")
    name=$(echo "$name" | sed "${SED_FROM_MARKER[@]}")
    echo "$name"
}

CONTENT_CHANGES=0
RENAME_CHANGES=0

# --- 1. REPLACE CONTENT ---

# Self-exclusion: the init scripts themselves carry literal "Unidote" and
# "Shilo" fallbacks (PROJECT_FALLBACK / AUTHOR_FALLBACK) that must never be
# rewritten — otherwise re-running init after a rebrand would corrupt the
# fallback path. The init.ps1 proxy references "init.sh" by name, so skip
# both.
BLACKLIST=(-not -name 'init.sh' -not -name 'init.ps1')

echo "Updating file contents..."
while read -r file; do
    if grep -qE "$JOINED_OLD" "$file"; then
        echo "  [Content] $file"
        tmp_file=$(mktemp)

        sed "${SED_TO_MARKER[@]}" "$file" | sed "${SED_FROM_MARKER[@]}" > "$tmp_file"

        changes=$(diff -U0 "$file" "$tmp_file" | grep -c '^-' || true)
        CONTENT_CHANGES=$((CONTENT_CHANGES + changes))

        # Colour the diff so humans can spot accidental collisions.
        diff -U0 "$file" "$tmp_file" | grep -E '^\-|\+' | grep -vE '^---|^[+]{3}' | \
            sed -e "s/^-/$(printf '\033[1;31m-')/" \
                -e "s/^+/$(printf '\033[1;32m')+/" \
                -e "s/$/$(printf '\033[0m')/" \
                -e "s/^/      /" || true

        cat "$tmp_file" > "$file"
        rm "$tmp_file"
    fi
done < <(find "${EXISTING_TARGETS[@]}" -type f \
    -not -path '*/\.git/*' \
    -not -path '*/bin/*' \
    -not -path '*/obj/*' \
    -not -path '*/.godot/*' \
    -not -path '*/.import/*' \
    -not -path '*/.mono/*' \
    -not -path '*/Library/*' \
    -not -path '*/Temp/*' \
    -not -path '*/Logs/*' \
    -not -path '*/UserSettings/*' \
    -not -path '*/Build/*' \
    "${BLACKLIST[@]}")

# --- 2. RENAME FILES AND FOLDERS ---

echo -e "\nRenaming files and folders..."
# -depth renames children before parents so paths stay valid mid-sweep.
while read -r item; do
    dirname=$(dirname "$item")
    basename=$(basename "$item")
    new_basename=$(rename_string "$basename")

    if [[ "$basename" != "$new_basename" ]]; then
        RENAME_CHANGES=$((RENAME_CHANGES + 1))
        echo -e "  \033[1;32m[Renamed] $item -> $new_basename\033[0m"
        mv "$item" "$dirname/$new_basename"
    fi
done < <(find "${EXISTING_TARGETS[@]}" -depth \
    -not -path '*/\.git/*' \
    -not -path '*/bin/*' \
    -not -path '*/obj/*' \
    -not -path '*/.godot/*' \
    -not -path '*/.import/*' \
    -not -path '*/.mono/*' \
    -not -path '*/Library/*' \
    -not -path '*/Temp/*' \
    -not -path '*/Logs/*' \
    -not -path '*/UserSettings/*' \
    -not -path '*/Build/*' \
    "${BLACKLIST[@]}")

echo -e "\nSuccess! Project rebranded as $NEW_PROJECT_PASCAL by $NEW_AUTHOR_DISPLAY."
echo "-------------------------------------------"
echo "Lines updated: $CONTENT_CHANGES"
echo "Files renamed: $RENAME_CHANGES"
echo "-------------------------------------------"
echo "Note: You can now safely delete 'init.sh' and 'init.ps1'."
