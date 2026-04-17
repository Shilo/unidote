#!/usr/bin/env bash
#
# init.sh
# Rebrand this scaffold for a fresh fork.
#
# Reads the current project identity from the root .sln file, prompts for a
# new project name, derives PascalCase and kebab-case identifiers, then
# rewrites every matching text occurrence and renames every matching file
# or folder across the whitelisted paths.
#
# PascalCase replacement runs first so the lowercase kebab sweep does
# not collide with already-replaced tokens.

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
# Derive kebab-case from Pascal for lowercase token replacement
OLD_KEBAB=$(echo "$OLD_PASCAL" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')

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

# kebab-case: "my-project" — used for URL slugs, package IDs, concurrency groups
kebab_id=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')

echo -e "\nInitializing Rebrand..."
echo "-------------------------------------------"
echo "New Name (PascalCase): $pascal_name"
echo "New ID (kebab-case):    $kebab_id"
echo "-------------------------------------------"
echo

WHITELIST=("src" "tests" "samples" "scripts" ".github" "docs" \
           "README.md" "mkdocs.yml" "Directory.Build.props" "research.md" \
           ".gitignore" \
           "$(basename "$SLN_PATH")")

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
while read -r file; do
    if grep -qE "${OLD_PASCAL}|${OLD_KEBAB}" "$file"; then
        echo "  [Content] $file"
        tmp_file=$(mktemp)

        # Two passes: PascalCase first, then all remaining lowercase → kebab.
        # Every lowercase occurrence in this C# scaffold is a URL slug,
        # package id, or concurrency group — all kebab context.
        sed -e "s/${OLD_PASCAL}/${pascal_name}/g" \
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
done < <(find "${EXISTING_TARGETS[@]}" -type f \
    -not -path '*/\.git/*' \
    -not -path '*/bin/*' \
    -not -path '*/obj/*')

# --- 2. RENAME FILES AND FOLDERS ---
echo -e "\nRenaming files and folders..."
# Use -depth for deepest-first renaming to ensure parents aren't moved before children
while read -r item; do
    dirname=$(dirname "$item")
    basename=$(basename "$item")
    new_basename="$basename"
    
    if echo "$new_basename" | grep -q "${OLD_PASCAL}"; then
        new_basename=$(echo "$new_basename" | sed "s/${OLD_PASCAL}/${pascal_name}/g")
    fi
    if echo "$new_basename" | grep -q "${OLD_KEBAB}"; then
        new_basename=$(echo "$new_basename" | sed "s/${OLD_KEBAB}/${kebab_id}/g")
    fi
    
    if [[ "$basename" != "$new_basename" ]]; then
        ((RENAME_CHANGES++))
        echo -e "  \033[1;32m[Renamed] $item -> $new_basename\033[0m"
        mv "$item" "$dirname/$new_basename"
    fi
done < <(find "${EXISTING_TARGETS[@]}" -depth \
    -not -path '*/\.git/*' \
    -not -path '*/bin/*' \
    -not -path '*/obj/*')

echo -e "\nSuccess! Project rebranded as $pascal_name."
echo "-------------------------------------------"
echo "Lines updated:      $CONTENT_CHANGES"
echo "Files renamed:      $RENAME_CHANGES"
echo "-------------------------------------------"
echo "Note: You can now safely delete 'init.sh' and 'init.ps1'."
