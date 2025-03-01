#!/bin/bash

# Script to merge a specific feature branch into the current branch
# Created: $(date)

set -e  # Exit immediately if a command exits with a non-zero status
echo "Starting feature branch merge process..."

# Default feature branch to merge
FEATURE_BRANCH="feature/favorite-items"

# Check if a branch name was provided as an argument
if [ "$1" != "" ]; then
    FEATURE_BRANCH="$1"
fi

# Function to check if a branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/$1
    return $?
}

# Function to check if a branch is clean (no uncommitted changes)
is_branch_clean() {
    if [ -z "$(git status --porcelain)" ]; then
        return 0  # Clean
    else
        return 1  # Not clean
    fi
}

# Store current branch
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
echo "Current branch: $CURRENT_BRANCH"
echo "Feature branch to merge: $FEATURE_BRANCH"

# Check if current branch has uncommitted changes
if ! is_branch_clean; then
    echo "ERROR: You have uncommitted changes in your current branch."
    echo "Please commit or stash your changes before running this script."
    exit 1
fi

# Check if feature branch exists
if ! branch_exists "$FEATURE_BRANCH"; then
    echo "ERROR: Feature branch '$FEATURE_BRANCH' does not exist locally."
    echo "Available branches:"
    git branch
    exit 1
fi

# Confirm merge
echo -e "\n=== Confirm Merge ==="
echo "This will merge '$FEATURE_BRANCH' into your current branch '$CURRENT_BRANCH'."
read -p "Continue? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Merge cancelled."
    exit 0
fi

# Merge method selection
echo -e "\n=== Select merge method ==="
echo "1) Merge (preserves history, creates merge commit)"
echo "2) Cherry-pick (selects specific commits, cleaner history)"
read -p "Choose merge method [1/2]: " MERGE_METHOD

# Perform the merge
echo -e "\n=== Merging $FEATURE_BRANCH into $CURRENT_BRANCH ==="

if [[ "$MERGE_METHOD" == "2" ]]; then
    echo "Using cherry-pick method..."
    
    # Get the commit range to cherry-pick
    echo "Determining commits to cherry-pick..."
    
    # Find the common ancestor between the current branch and the feature branch
    COMMON_ANCESTOR=$(git merge-base $CURRENT_BRANCH $FEATURE_BRANCH)
    
    # Get list of commits in feature branch since common ancestor
    COMMITS=$(git rev-list --reverse $COMMON_ANCESTOR..$FEATURE_BRANCH)
    
    if [ -z "$COMMITS" ]; then
        echo "No commits to cherry-pick. The feature branch might already be merged."
        exit 0
    fi
    
    # Cherry-pick each commit
    for COMMIT in $COMMITS; do
        COMMIT_MSG=$(git log --format=%B -n 1 $COMMIT | head -n 1)
        echo "Cherry-picking: $COMMIT_MSG"
        git cherry-pick $COMMIT || {
            echo "Cherry-pick encountered conflicts."
            echo "Please resolve conflicts and then run 'git cherry-pick --continue'"
            echo "Or abort with 'git cherry-pick --abort'"
            exit 1
        }
    done
else
    echo "Using merge method..."
    git merge $FEATURE_BRANCH || {
        echo "Merge encountered conflicts."
        echo "Please resolve conflicts and then run 'git merge --continue'"
        echo "Or abort with 'git merge --abort'"
        exit 1
    }
fi

echo -e "\n=== Merge complete ==="
echo "Successfully merged '$FEATURE_BRANCH' into '$CURRENT_BRANCH'."
echo "You may now push these changes to origin with:"
echo "  git push origin $CURRENT_BRANCH"
