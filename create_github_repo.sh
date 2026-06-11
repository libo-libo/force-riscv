#!/usr/bin/env bash
# Helper to create a GitHub repo and push this project.
# Usage:
#   ./create_github_repo.sh --name my-repo --public
#   ./create_github_repo.sh --dry-run --name my-repo

set -euo pipefail

REPO_NAME=""
PUBLIC=true
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) REPO_NAME="$2"; shift 2;;
    --public) PUBLIC=true; shift;;
    --private) PUBLIC=false; shift;;
    --dry-run) DRY_RUN=true; shift;;
    -h|--help) echo "Usage: $0 --name repo-name [--public|--private] [--dry-run]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

if [ -z "$REPO_NAME" ]; then
  echo "Error: --name is required" >&2
  exit 1
fi

VISIBILITY="public"
if [ "$PUBLIC" = false ]; then
  VISIBILITY="private"
fi

if command -v gh >/dev/null 2>&1; then
  if [ "$DRY_RUN" = true ]; then
    echo "gh repo create $REPO_NAME --$VISIBILITY --source=. --remote=origin --push"
    exit 0
  fi

  echo "Creating repo via gh..."
  gh repo create "$REPO_NAME" --$VISIBILITY --source=. --remote=origin --push
  echo "Repository created and pushed as origin/$REPO_NAME"
  exit 0
fi

cat <<'EOF'
gh (GitHub CLI) not found or not authenticated on this machine.
Follow these manual steps to create the repo and push:

1) Create a new repository on GitHub (via web or `gh auth login` + `gh repo create`).

2) On your local machine, run (replace USERNAME and REPO with your values):

   git status --porcelain >/dev/null || git init
   git add .
   git commit -m "Local: make modern-toolchain fixes and build helpers"
   git branch -M main
   git remote add origin git@github.com:YOUR_GITHUB_USERNAME/$REPO_NAME.git
   git push -u origin main

If you prefer HTTPS remote, use:

   git remote add origin https://github.com/YOUR_GITHUB_USERNAME/$REPO_NAME.git
   git push -u origin main

If you want me to prepare a branch and a patch instead of pushing, run this script with --dry-run and tell me how to proceed.
EOF
