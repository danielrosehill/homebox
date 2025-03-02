#!/bin/bash

# Script to merge selected feature branches into the docker/custom-image branch
# This script helps maintain a clean custom Docker image branch with selected features

set -e

# Configuration
TARGET_BRANCH="docker/custom-image"
MAIN_BRANCH="main"

# Function to display help
show_help() {
    echo "Usage: $0 [options] [feature_branches...]"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -r, --reset             Reset the target branch to match main before merging features"
    echo "  -p, --push              Push changes to remote after merging"
    echo
    echo "Example:"
    echo "  $0 feature/asset-id-lookup feature/fuzzy-search"
    echo
    echo "This will merge the specified feature branches into the $TARGET_BRANCH branch."
    exit 0
}

# Parse command line arguments
RESET_BRANCH=false
PUSH_CHANGES=false
FEATURE_BRANCHES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -r|--reset)
            RESET_BRANCH=true
            shift
            ;;
        -p|--push)
            PUSH_CHANGES=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            FEATURE_BRANCHES+=("$1")
            shift
            ;;
    esac
done

# Check if any feature branches were specified
if [ ${#FEATURE_BRANCHES[@]} -eq 0 ]; then
    echo "Error: No feature branches specified"
    echo "Use --help for usage information"
    exit 1
fi

# Save the current branch to return to it later
CURRENT_BRANCH=$(git branch --show-current)

# Function to clean up and return to the original branch
cleanup() {
    echo "Returning to branch: $CURRENT_BRANCH"
    git checkout "$CURRENT_BRANCH"
}

# Set up trap to ensure we return to the original branch on exit
trap cleanup EXIT

# Switch to the target branch
echo "Switching to branch: $TARGET_BRANCH"
git checkout "$TARGET_BRANCH" || { echo "Error: Failed to switch to $TARGET_BRANCH branch"; exit 1; }

# Reset the branch to match main if requested
if [ "$RESET_BRANCH" = true ]; then
    echo "Resetting $TARGET_BRANCH to match $MAIN_BRANCH"
    git fetch origin
    git reset --hard "origin/$MAIN_BRANCH" || { echo "Error: Failed to reset branch"; exit 1; }
fi

# Merge each feature branch
for branch in "${FEATURE_BRANCHES[@]}"; do
    echo "Merging branch: $branch"
    
    # Check if the branch exists
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Warning: Branch $branch does not exist locally"
        
        # Check if it exists remotely
        if git ls-remote --exit-code --heads origin "$branch" >/dev/null; then
            echo "Branch $branch exists remotely, fetching..."
            git fetch origin "$branch":"$branch" || { echo "Error: Failed to fetch branch $branch"; exit 1; }
        else
            echo "Error: Branch $branch does not exist locally or remotely"
            exit 1
        fi
    fi
    
    # Try to merge the branch
    if ! git merge --no-ff "$branch" -m "Merge branch '$branch' into $TARGET_BRANCH"; then
        echo "Merge conflict detected in branch: $branch"
        echo "Please resolve conflicts manually and then continue"
        echo "After resolving conflicts, run: git merge --continue"
        echo "Or to abort the merge, run: git merge --abort"
        exit 1
    fi
done

# Push changes if requested
if [ "$PUSH_CHANGES" = true ]; then
    echo "Pushing changes to remote"
    git push origin "$TARGET_BRANCH" || { echo "Error: Failed to push changes"; exit 1; }
fi

echo "Done! All specified feature branches have been merged into $TARGET_BRANCH"
