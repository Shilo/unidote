#!/usr/bin/env bash
#
# init.sh
# Rebrand the Unidote scaffold for a fresh fork.
#
# Prompts for a human-readable project name, derives PascalCase, snake_case,
# and kebab-case identifiers, then rewrites every text occurrence of
# "Unidote", "unidote", and "unidote-id" and renames every matching file
# or folder.
#
# Case-sensitive substitutions ensure the PascalCase sweep does
# not eat lowercase tokens before the snake/kebab sweeps run.

set -euo pipefail

read -p "Enter Project Name (e.g., My Super Project): " raw_input
# Trim whitespace
trimmed=$(echo "$raw_input" | xargs)

if [[ -z "$trimmed" ]]; then
    echo "Error: Project name cannot be empty." >&2
    exit 1
fi

# Generate PascalCase: "MySuperProject"
pascal_name=$(echo "$trimmed" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1' | tr -d ' ')

# snake_case: "my_super_project"
snake_name=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '_')

# kebab-case: "my-super-project"
kebab_id=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')

echo -e "\nInitializing Unidote Scaffold..."
echo "-------------------------------------------"
echo "Project Name (Pascal): $pascal_name"
echo "Project ID (Kebab):    $kebab_id"
echo "Internal Name (Snake): $snake_name"
echo "-------------------------------------------"
echo

# --- PREPARATION ---
# Ensure we are running from the project root (one level up from /scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

WHITELIST=("src" "tests" "samples")

# Validate targets exist
EXISTING_TARGETS=()
for dir in "${WHITELIST[@]}"; do
    if [[ -d "$dir" ]]; then
        EXISTING_TARGETS+=("$dir")
    fi
done

if [[ ${#EXISTING_TARGETS[@]} -eq 0 ]]; then
    echo "Error: No target directories (src/, tests/, samples/) found." >&2
    exit 1
fi

script_name=$(basename "$0")

# --- 1. REPLACE CONTENT ---
echo "Updating file contents..."
find "${EXISTING_TARGETS[@]}" -type f -not -path '*/\.git/*' | while read -r file; do
    if grep -qE 'Unidote|unidote' "$file"; then
        echo "  [Content] $file"
        tmp_file=$(mktemp)
        sed -e "s/unidote-id/$kebab_id/g" \
            -e "s/Unidote/$pascal_name/g" \
            -e "s/unidote/$snake_name/g" "$file" > "$tmp_file"
        
        # Show individual line changes (diff-style)
        diff -u "$file" "$tmp_file" | grep -E '^\-|\+' | grep -vE '^---|^[+]{3}' | sed 's/^/      /' || true
        
        cat "$tmp_file" > "$file"
        rm "$tmp_file"
    fi
done

# --- 2. RENAME FILES AND FOLDERS ---
echo -e "\nRenaming files and folders..."
# Use -depth for deepest-first renaming to ensure parents aren't moved before children
find "${EXISTING_TARGETS[@]}" -depth -not -path '*/\.git/*' | while read -r item; do
    dirname=$(dirname "$item")
    basename=$(basename "$item")
    new_basename="$basename"
    
    if echo "$new_basename" | grep -q 'unidote-id'; then
        new_basename=$(echo "$new_basename" | sed "s/unidote-id/$kebab_id/g")
    fi
    if echo "$new_basename" | grep -q 'Unidote'; then
        new_basename=$(echo "$new_basename" | sed "s/Unidote/$pascal_name/g")
    fi
    if echo "$new_basename" | grep -q 'unidote'; then
        new_basename=$(echo "$new_basename" | sed "s/unidote/$snake_name/g")
    fi
    
    if [[ "$basename" != "$new_basename" ]]; then
        echo "  [Renamed] $item -> $new_basename"
        mv "$item" "$dirname/$new_basename"
    fi
done

echo -e "\nSuccess! Project rebranded as $pascal_name."
echo "Note: You can now safely delete 'init.sh' and 'init.ps1'."
