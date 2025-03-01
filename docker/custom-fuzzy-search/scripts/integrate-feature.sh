#!/bin/bash
# integrate-feature.sh
#
# This script integrates a feature branch into the custom-docker-image branch
# and triggers a build of the custom Docker image with all features.
#
# Usage: ./integrate-feature.sh feature-branch-name

set -e  # Exit on any error

# Check if a feature branch name was provided
FEATURE=$1
if [ -z "$FEATURE" ]; then
  echo "Usage: ./integrate-feature.sh feature-branch-name"
  echo "Example: ./integrate-feature.sh asset-id-lookup"
  exit 1
fi

echo "=== Starting integration of feature '$FEATURE' into custom Docker image ==="

# Update all branches
echo "Fetching latest changes from remote..."
git fetch origin

# Make sure feature branch exists
if ! git show-ref --verify --quiet refs/heads/$FEATURE; then
  if ! git show-ref --verify --quiet refs/remotes/origin/$FEATURE; then
    echo "Error: Feature branch '$FEATURE' does not exist locally or remotely"
    exit 1
  else
    echo "Feature branch exists remotely but not locally. Creating local branch..."
    git checkout -b $FEATURE origin/$FEATURE
  fi
fi

# Update feature branch
echo "Updating feature branch '$FEATURE'..."
git checkout $FEATURE
git pull origin $FEATURE

# Update custom Docker branch
echo "Updating custom-docker-image branch..."
git checkout custom-docker-image
git pull origin custom-docker-image

# Merge feature
echo "Merging feature '$FEATURE' into custom-docker-image..."
git merge --no-ff $FEATURE -m "Integrate $FEATURE feature into custom Docker image"

# Push changes
echo "Pushing changes to remote..."
git push origin custom-docker-image

echo "=== Integration complete ==="
echo "Feature '$FEATURE' has been integrated into the custom-docker-image branch"
echo "GitHub Actions will build and push the updated image"
echo ""
echo "To use the updated image:"
echo "1. Wait for the GitHub Actions workflow to complete"
echo "2. Pull the new image: docker pull danielrosehill/homebox:fuzzy-search"
echo "3. Restart your container: docker-compose down && docker-compose up -d"
