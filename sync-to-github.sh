#!/usr/bin/env bash
# Copy the widget demo site into the GitHub repo that deploys it with GitHub Pages.
#
# Usage:
#   ./sync-to-github.sh                 # copy files only
#   ./sync-to-github.sh --push          # copy, commit and push to origin/main
#   ./sync-to-github.sh --push "msg"    # same, with a custom commit message
#   TARGET_DIR=/path/to/repo ./sync-to-github.sh
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${TARGET_DIR:-$HOME/Desktop/project/github-nghiaw/hdc-mrag-widget-demo}"

# Files published by the site (paths relative to SRC_DIR).
FILES=(
    "index.html"
    "style.css"
    ".github/workflows/pages.yml"
)

PUSH=false
COMMIT_MSG="chore: sync widget demo from GitLab"
if [[ "${1:-}" == "--push" ]]; then
    PUSH=true
    COMMIT_MSG="${2:-$COMMIT_MSG}"
fi

if [[ ! -d "$TARGET_DIR/.git" ]]; then
    echo "Error: $TARGET_DIR is not a git repository." >&2
    exit 1
fi

for file in "${FILES[@]}"; do
    if [[ ! -f "$SRC_DIR/$file" ]]; then
        echo "Error: missing source file $SRC_DIR/$file" >&2
        exit 1
    fi
    mkdir -p "$TARGET_DIR/$(dirname "$file")"
    cp "$SRC_DIR/$file" "$TARGET_DIR/$file"
    echo "Copied $file"
done

cd "$TARGET_DIR"
echo
git status --short

if [[ "$PUSH" != true ]]; then
    echo
    echo "Done. Review the changes in $TARGET_DIR, or rerun with --push to commit and push."
    exit 0
fi

git add -- "${FILES[@]}"
if git diff --cached --quiet; then
    echo "Nothing changed, skip commit."
    exit 0
fi
git commit -m "$COMMIT_MSG"
git push origin main
echo
echo "Pushed. Pages URL: https://20206205tech.github.io/$(basename "$TARGET_DIR")/"
