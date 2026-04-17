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

# --- PREPARATION ---
# Ensure we are running from the project root (one level up from /scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# 1. Identify current project from the .sln file
SLN_PATH=$(find . -maxdepth 1 -name "*.sln" | head -n 1)
if [[ -z "$SLN_PATH" ]]; then
    echo "Error: No .sln file found in root. Cannot determine current project name." >&2
    exit 1
fi

OLD_PASCAL=$(basename "$SLN_PATH" .sln)
# Derive snake_case and kebab-case from Pascal (assuming PascalCase input)
OLD_SNAKE=$(echo "$OLD_PASCAL" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')
OLD_KEBAB=$(echo "$OLD_PASCAL" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')
# Handle the "id" suffix used in placeholders like "unidote-id"
OLD_ID_PLACEHOLDER="${OLD_KEBAB}-id"

echo -e "\nRebranding Workspace"
echo "Current Identity: $OLD_PASCAL"
echo "-------------------------------------------"

read -p "New Project Name (e.g., My Project): " raw_input
# Trim whitespace
trimmed=$(echo "$raw_input" | xargs)

if [[ -z "$trimmed" ]]; then
    echo "Error: Project name cannot be empty." >&2
    exit 1
fi

# Generate PascalCase: "MyProject"
pascal_name=$(echo "$trimmed" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1' | tr -d ' ')

# snake_case: "my_project"
snake_name=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '_')

# kebab-case: "my-project"
kebab_id=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')

echo -e "\nInitializing Rebrand..."
echo "-------------------------------------------"
echo "New Name (Pascal): $pascal_name"
echo "New ID (Kebab):    $kebab_id"
echo "New Name (Snake):  $snake_name"
echo "-------------------------------------------"
echo

WHITELIST=("src" "tests" "samples" "$(basename "$SLN_PATH")")

# Validate targets exist
EXISTING_TARGETS=()
for item in "${WHITELIST[@]}"; do
    if [[ -e "$item" ]]; then
        EXISTING_TARGETS+=("$item")
    fi
done

if [[ ${#EXISTING_TARGETS[@]} -eq 0 ]]; then
    echo "Error: No target directories (src/, tests/, samples/) or .sln found." >&2
    exit 1
fi

script_name=$(basename "$0")

CONTENT_CHANGES=0
RENAME_CHANGES=0

# --- 1. REPLACE CONTENT ---
echo "Updating file contents..."
find "${EXISTING_TARGETS[@]}" -type f -not -path '*/\.git/*' | while read -r file; do
    if grep -qEi "${OLD_PASCAL}|${OLD_SNAKE}" "$file"; then
        echo "  [Content] $file"
        tmp_file=$(mktemp)
        
        # Order matters: replace specific "id" placeholder first, then general names
        sed -e "s/${OLD_ID_PLACEHOLDER}/${kebab_id}/g" \
            -e "s/${OLD_PASCAL}/${pascal_name}/g" \
            -e "s/${OLD_SNAKE}/${snake_name}/g" \
            -e "s/${OLD_KEBAB}/${kebab_id}/g" "$file" > "$tmp_file"
        
        # Count lines changed (number of removals in diff)
        changes=$(diff -U0 "$file" "$tmp_file" | grep -c '^-' || true)
        ((CONTENT_CHANGES += changes))

        # Show individual line changes (industry-standard Bold Red/Green)
        # We use -U0 to show exactly the changed lines without surrounding context
        diff -U0 "$file" "$tmp_file" | grep -E '^\-|\+' | grep -vE '^---|^[+]{3}' | \
            sed -e "s/^-/$(printf '\033[1;31m-')/" \
                -e "s/^+/$(printf '\033[1;32m')+/" \
                -e "s/$/$(printf '\033[0m')/" \
                -e "s/^/      /" || true
        
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
    
    if echo "$new_basename" | grep -qi "${OLD_ID_PLACEHOLDER}"; then
        new_basename=$(echo "$new_basename" | sed "s/${OLD_ID_PLACEHOLDER}/${kebab_id}/g")
    fi
    if echo "$new_basename" | grep -qi "${OLD_PASCAL}"; then
        new_basename=$(echo "$new_basename" | sed "s/${OLD_PASCAL}/${pascal_name}/g")
    fi
    if echo "$new_basename" | grep -qi "${OLD_SNAKE}"; then
        new_basename=$(echo "$new_basename" | sed "s/${OLD_SNAKE}/${snake_name}/g")
    fi
    if echo "$new_basename" | grep -qi "${OLD_KEBAB}"; then
        new_basename=$(echo "$new_basename" | sed "s/${OLD_KEBAB}/${kebab_id}/g")
    fi
    
    if [[ "$basename" != "$new_basename" ]]; then
        ((RENAME_CHANGES++))
        echo -e "  \033[1;32m[Renamed] $item -> $new_basename\033[0m"
        mv "$item" "$dirname/$new_basename"
    fi
done

echo -e "\nSuccess! Project rebranded as $pascal_name."
echo "-------------------------------------------"
echo "Lines updated:      $CONTENT_CHANGES"
echo "Items renamed:      $RENAME_CHANGES"
echo "-------------------------------------------"
echo "Note: You can now safely delete 'init.sh' and 'init.ps1'."
