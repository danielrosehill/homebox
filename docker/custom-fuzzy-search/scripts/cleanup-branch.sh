#!/bin/bash
# cleanup-branch.sh
#
# This script cleans up the custom-docker-image branch by removing unnecessary files and directories.
#
# Usage: ./cleanup-branch.sh

set -e  # Exit on any error

echo "=== Cleaning up custom-docker-image branch ==="

# Make sure we're on the custom-docker-image branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "custom-docker-image" ]; then
  echo "Error: You must be on the custom-docker-image branch to run this script"
  echo "Current branch: $CURRENT_BRANCH"
  exit 1
fi

# List of directories and files to remove
REMOVE_DIRS=(
  "docs"
  ".scaffold"
  ".devcontainer"
  "conflicts"
  ".aider.tags.cache.v3"
)

REMOVE_FILES=(
  "CODE_OF_CONDUCT.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
  "Taskfile.yml"
  ".aider.chat.history.md"
  ".aider.input.history"
  "Dockerfile.rootless"
  "docker-compose.yml"  # We have our own in docker/custom-fuzzy-search
)

# Remove directories
for dir in "${REMOVE_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "Removing directory: $dir"
    git rm -rf "$dir"
  else
    echo "Directory not found: $dir"
  fi
done

# Remove files
for file in "${REMOVE_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Removing file: $file"
    git rm "$file"
  else
    echo "File not found: $file"
  fi
done

# Simplify README.md
echo "Updating README.md"
cat > README.md << 'EOF'
# Homebox Custom Docker Image

This is a custom build of Homebox that includes additional features not yet merged into the main project.

## Features

- Fuzzy search functionality
- Asset ID lookup (coming soon)

## Quick Start

```bash
docker run -d \
  --name homebox \
  -p 7745:7745 \
  -v homebox-data:/data \
  danielrosehill/homebox:fuzzy-search
```

For more detailed instructions, see the [docker/custom-fuzzy-search/README.md](docker/custom-fuzzy-search/README.md) file.
EOF

# Commit changes
echo "Committing changes..."
git add README.md
git commit -m "Clean up branch for custom use only"

echo "=== Cleanup complete ==="
echo "The custom-docker-image branch has been cleaned up"
echo "To push these changes to GitHub, run: git push origin custom-docker-image"
