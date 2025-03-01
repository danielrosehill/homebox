#!/bin/bash

# Script to update feature branches from upstream
# Created: $(date)

set -e  # Exit immediately if a command exits with a non-zero status
echo "Starting feature branch update process..."

# Function to check if a branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/$1
    return $?
}

# Function to check if a branch is clean (no uncommitted changes)
is_branch_clean() {
    if [ -z "$(git status --porcelain | grep -v "update-feature-branches.sh")" ]; then
        return 0  # Clean
    else
        return 1  # Not clean
    fi
}

# Store current branch
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
echo "Current branch: $CURRENT_BRANCH"

# Check if current branch has uncommitted changes
if ! is_branch_clean; then
    echo "ERROR: You have uncommitted changes in your current branch."
    echo "Please commit or stash your changes before running this script."
    exit 1
fi

# Update main branch from upstream first
echo -e "\n=== Updating main branch from upstream ==="
if branch_exists "main"; then
    git checkout main
    
    # First, ensure local main is up-to-date with origin/main
    echo "Updating local main from origin/main..."
    git pull origin main --ff-only || {
        echo "Cannot fast-forward local main to origin/main."
        echo "This could be due to local commits that aren't on origin."
        echo "Trying to reset local main to origin/main..."
        git fetch origin
        git reset --hard origin/main
    }
    
    # Now update from upstream
    echo "Updating from upstream/main..."
    git fetch upstream
    git merge upstream/main
    
    # Push to origin
    echo "Pushing updated main to origin..."
    git push origin main
    
    echo "Main branch updated successfully from upstream"
else
    echo "ERROR: Main branch does not exist locally"
    exit 1
fi

# Get all local feature branches
echo -e "\n=== Finding feature branches to update ==="
FEATURE_BRANCHES=$(git branch | grep "feature/" | sed 's/^[ *]*//')
DOCKER_BRANCHES=$(git branch | grep "docker/" | sed 's/^[ *]*//')

# Add any other branches you want to update
ALL_BRANCHES=("$FEATURE_BRANCHES" "$DOCKER_BRANCHES")

# Update method selection
echo -e "\n=== Select update method ==="
echo "1) Merge (safer, preserves history, creates merge commits)"
echo "2) Rebase (cleaner history, rewrites commits, best for private branches)"
read -p "Choose update method [1/2]: " UPDATE_METHOD

# Update each feature branch
echo -e "\n=== Updating feature branches ==="
for branch in $ALL_BRANCHES; do
    if [[ -z "$branch" ]]; then
        continue  # Skip if branch is empty
    fi
    
    echo -e "\nUpdating branch: $branch"
    git checkout "$branch"
    
    if [[ "$UPDATE_METHOD" == "2" ]]; then
        echo "Using rebase method..."
        git rebase main || {
            echo "Rebase encountered conflicts. Aborting rebase."
            git rebase --abort
            echo "Try using the merge method for this branch instead."
            continue
        }
    else
        echo "Using merge method..."
        git merge main
    fi
    
    # Push the updated branch to origin
    echo "Pushing updated branch to origin..."
    git push origin "$branch" --force-with-lease
    
    echo "Branch $branch updated successfully"
done

# Return to original branch
echo -e "\n=== Returning to original branch ==="
git checkout "$CURRENT_BRANCH"
echo "Returned to original branch: $CURRENT_BRANCH"

echo -e "\n=== Feature branch update complete ==="
echo "All feature branches have been updated from upstream main."
echo "Your branches are now up-to-date with the latest upstream changes."
