#!/bin/bash

# Script to selectively merge feature branches into the docker/testing-favorite-items branch
# Usage: ./merge-feature-branches.sh [branch1] [branch2] ...

set -e

# Check if we're on the right branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "docker/testing-favorite-items" ]; then
    echo "Switching to docker/testing-favorite-items branch..."
    git checkout docker/testing-favorite-items
fi

# Always ensure we have the latest feature/favorite-items branch
echo "Merging feature/favorite-items branch..."
git merge feature/favorite-items

# Process additional feature branches if specified
if [ $# -gt 0 ]; then
    for branch in "$@"; do
        echo "Merging $branch branch..."
        git merge "$branch" || {
            echo "Merge conflict with $branch. Please resolve conflicts manually."
            exit 1
        }
    done
fi

echo "All specified branches have been merged into docker/testing-favorite-items"
echo "You can now build the Docker image with:"
echo "cd docker/testing-favorite-items && docker-compose build"
