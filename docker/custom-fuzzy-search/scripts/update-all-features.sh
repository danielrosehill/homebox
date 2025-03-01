#!/bin/bash
# update-all-features.sh
#
# This script updates the custom-docker-image branch with all feature branches
# and triggers a build of the custom Docker image with all features.
#
# Usage: ./update-all-features.sh

set -e  # Exit on any error

# List of feature branches to integrate
# Add new feature branches to this array as you develop them
FEATURE_BRANCHES=("fuzzy-search-logic" "asset-id-lookup")

echo "=== Starting update of custom Docker image with all features ==="

# Update all branches
echo "Fetching latest changes from remote..."
git fetch origin

# Update custom Docker branch
echo "Updating custom-docker-image branch..."
git checkout custom-docker-image
git pull origin custom-docker-image

# Merge each feature branch
for branch in "${FEATURE_BRANCHES[@]}"; do
  # Check if branch exists
  if git show-ref --verify --quiet refs/heads/$branch || git show-ref --verify --quiet refs/remotes/origin/$branch; then
    echo "Integrating feature '$branch'..."
    
    # If branch exists remotely but not locally, create it
    if ! git show-ref --verify --quiet refs/heads/$branch; then
      git checkout -b $branch origin/$branch
    else
      git checkout $branch
      git pull origin $branch
    fi
    
    # Switch back to custom-docker-image and merge
    git checkout custom-docker-image
    git merge --no-ff $branch -m "Integrate feature '$branch' into custom Docker image"
  else
    echo "Warning: Feature branch '$branch' does not exist, skipping..."
  fi
done

# Push the updated custom-docker-image branch
echo "Pushing changes to remote..."
git push origin custom-docker-image

echo "=== Update complete ==="
echo "All available features have been integrated into the custom-docker-image branch"
echo "GitHub Actions will build and push the updated image"
echo ""
echo "To use the updated image:"
echo "1. Wait for the GitHub Actions workflow to complete"
echo "2. Pull the new image: docker pull danielrosehill/homebox:fuzzy-search"
echo "3. Restart your container: docker-compose down && docker-compose up -d"
