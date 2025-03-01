# Homebox Scripts

This directory contains utility scripts for managing the Homebox repository and its features.

## Available Scripts

### merge-features.sh

An interactive script to merge feature branches into the custom-docker-image branch.

**Features:**
- Shows which branches haven't been merged yet
- Allows you to select which branches to merge using an interactive menu
- Updates branches before merging
- Handles merge conflicts gracefully
- Pushes changes to remote after successful merges

**Usage:**
```bash
./scripts/merge-features.sh
```

**Instructions:**
1. The script will display a list of branches that haven't been merged into the custom-docker-image branch
2. Use the space key to toggle selection of branches
3. Enter the number of the branch you want to toggle
4. Press Enter to confirm your selections
5. Confirm the merge operation
6. The script will merge the selected branches and push the changes to remote

## Adding New Scripts

When adding new scripts to this directory, please follow these guidelines:
1. Make the script executable (`chmod +x script-name.sh`)
2. Add a header comment explaining the purpose and usage of the script
3. Update this README with information about the new script
