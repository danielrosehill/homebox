#!/bin/bash
# merge-features.sh
#
# Interactive script to merge feature branches into the custom-docker-image branch.
# This script shows which branches haven't been merged yet and allows you to
# select which ones to merge.
#
# Usage: ./scripts/merge-features.sh

set -e  # Exit on any error

# Target branch to merge features into
TARGET_BRANCH="custom-docker-image"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Interactive Feature Branch Merger ===${NC}"
echo -e "This script will help you merge feature branches into the ${GREEN}${TARGET_BRANCH}${NC} branch."

# Make sure we're up to date
echo -e "\n${YELLOW}Fetching latest changes from remote...${NC}"
git fetch origin

# Check if target branch exists
if ! git show-ref --verify --quiet refs/heads/$TARGET_BRANCH; then
  if ! git show-ref --verify --quiet refs/remotes/origin/$TARGET_BRANCH; then
    echo -e "${RED}Error: Target branch '${TARGET_BRANCH}' does not exist locally or remotely${NC}"
    exit 1
  else
    echo -e "${YELLOW}Target branch exists remotely but not locally. Creating local branch...${NC}"
    git checkout -b $TARGET_BRANCH origin/$TARGET_BRANCH
  fi
else
  # Update target branch
  echo -e "${YELLOW}Updating target branch '${TARGET_BRANCH}'...${NC}"
  git checkout $TARGET_BRANCH
  git pull origin $TARGET_BRANCH
fi

# Get all local branches
echo -e "\n${BLUE}Finding feature branches...${NC}"
ALL_BRANCHES=$(git branch | grep -v "^\*" | sed 's/^[ \t]*//' | grep -v "$TARGET_BRANCH" | sort)

# Array to store branches that haven't been merged yet
UNMERGED_BRANCHES=()

echo -e "\n${BLUE}Analyzing branches that haven't been merged into ${TARGET_BRANCH}...${NC}"
for branch in $ALL_BRANCHES; do
  # Check if branch is already merged
  if ! git merge-base --is-ancestor $branch $TARGET_BRANCH > /dev/null 2>&1; then
    UNMERGED_BRANCHES+=("$branch")
  fi
done

# Check if we found any unmerged branches
if [ ${#UNMERGED_BRANCHES[@]} -eq 0 ]; then
  echo -e "${GREEN}All local branches are already merged into ${TARGET_BRANCH}.${NC}"
  exit 0
fi

# Display unmerged branches with selection options
echo -e "\n${BLUE}The following branches have not been merged into ${TARGET_BRANCH}:${NC}"
echo -e "${YELLOW}Select branches to merge (toggle with space, confirm with Enter):${NC}"

# Create associative array for selections
declare -A SELECTED
for i in "${!UNMERGED_BRANCHES[@]}"; do
  SELECTED[${UNMERGED_BRANCHES[$i]}]=false
done

# Function to display the menu
display_menu() {
  local i=1
  for branch in "${UNMERGED_BRANCHES[@]}"; do
    if [ "${SELECTED[$branch]}" = true ]; then
      echo -e "$i) [${GREEN}*${NC}] $branch"
    else
      echo -e "$i) [ ] $branch"
    fi
    ((i++))
  done
  echo -e "\n${YELLOW}Press space to toggle selection, Enter to confirm, q to quit${NC}"
}

# Interactive selection
while true; do
  clear
  echo -e "${BLUE}=== Interactive Feature Branch Merger ===${NC}"
  echo -e "${YELLOW}Select branches to merge into ${TARGET_BRANCH}:${NC}\n"
  display_menu
  
  # Read a single character
  read -n 1 -s key
  
  case $key in
    q)
      echo -e "\n${YELLOW}Exiting without merging.${NC}"
      exit 0
      ;;
    "")
      # Enter key pressed, break the loop
      break
      ;;
    " ")
      # Space key pressed, prompt for number
      echo -e "\n${YELLOW}Enter branch number to toggle:${NC} "
      read -r num
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#UNMERGED_BRANCHES[@]} ]; then
        branch=${UNMERGED_BRANCHES[$((num-1))]}
        if [ "${SELECTED[$branch]}" = true ]; then
          SELECTED[$branch]=false
        else
          SELECTED[$branch]=true
        fi
      fi
      ;;
  esac
done

# Check if any branches were selected
MERGE_COUNT=0
for branch in "${UNMERGED_BRANCHES[@]}"; do
  if [ "${SELECTED[$branch]}" = true ]; then
    ((MERGE_COUNT++))
  fi
done

if [ $MERGE_COUNT -eq 0 ]; then
  echo -e "\n${YELLOW}No branches selected for merging. Exiting.${NC}"
  exit 0
fi

# Confirm before proceeding
echo -e "\n${BLUE}You have selected the following branches to merge:${NC}"
for branch in "${UNMERGED_BRANCHES[@]}"; do
  if [ "${SELECTED[$branch]}" = true ]; then
    echo -e "- ${GREEN}$branch${NC}"
  fi
done

echo -e "\n${YELLOW}Do you want to proceed with merging these branches? (y/n)${NC}"
read -n 1 -r confirm
echo

if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Merge operation cancelled.${NC}"
  exit 0
fi

# Perform the merges
echo -e "\n${BLUE}Starting merge operations...${NC}"

# Make sure we're on the target branch
git checkout $TARGET_BRANCH

# Merge each selected branch
for branch in "${UNMERGED_BRANCHES[@]}"; do
  if [ "${SELECTED[$branch]}" = true ]; then
    echo -e "\n${YELLOW}Merging branch '${branch}'...${NC}"
    
    # Update the branch first
    git checkout $branch
    git pull origin $branch || echo -e "${YELLOW}Warning: Could not pull latest changes for '$branch'. Continuing with local version.${NC}"
    
    # Switch back to target branch and merge
    git checkout $TARGET_BRANCH
    if git merge --no-ff $branch -m "Integrate feature '$branch' into $TARGET_BRANCH"; then
      echo -e "${GREEN}Successfully merged '$branch' into $TARGET_BRANCH${NC}"
    else
      echo -e "${RED}Merge conflict detected when merging '$branch'${NC}"
      echo -e "${YELLOW}Please resolve conflicts manually and then continue.${NC}"
      echo -e "${YELLOW}After resolving conflicts, run:${NC}"
      echo -e "  git add . && git commit -m \"Resolve merge conflicts with $branch\""
      exit 1
    fi
  fi
done

# Push changes
echo -e "\n${YELLOW}Pushing changes to remote...${NC}"
git push origin $TARGET_BRANCH

echo -e "\n${GREEN}=== Merge operations complete ===${NC}"
echo -e "${GREEN}Selected feature branches have been integrated into the ${TARGET_BRANCH} branch${NC}"
echo -e "${YELLOW}GitHub Actions will build and push the updated image${NC}"
echo -e "\n${BLUE}To use the updated image:${NC}"
echo -e "1. Wait for the GitHub Actions workflow to complete"
echo -e "2. Pull the new image: docker pull danielrosehill/homebox:fuzzy-search"
echo -e "3. Restart your container: docker-compose down && docker-compose up -d"
