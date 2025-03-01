#!/bin/bash

# Script to remove unwanted GitHub Actions workflows
# This will delete all workflow files except the fuzzy search workflow

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

WORKFLOWS_DIR=".github/workflows"
KEEP_WORKFLOW="docker-fuzzy-search.yml"

echo -e "${BLUE}=== Removing Unwanted GitHub Actions Workflows ===${NC}"
echo -e "${YELLOW}This script will delete all workflow files except ${KEEP_WORKFLOW}${NC}"

# Create a backup directory
BACKUP_DIR="workflow-backups-$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}Created backup directory: ${BACKUP_DIR}${NC}"

# Process each workflow file
for workflow in ${WORKFLOWS_DIR}/*.{yml,yaml}; do
    # Skip if file doesn't exist (in case no .yml or .yaml files)
    [ -f "$workflow" ] || continue
    
    # Skip the fuzzy search workflow
    if [ "$(basename "$workflow")" = "$KEEP_WORKFLOW" ]; then
        echo -e "${GREEN}Keeping ${workflow}${NC}"
        continue
    fi
    
    # Backup the workflow file
    cp "$workflow" "${BACKUP_DIR}/$(basename "$workflow")"
    echo -e "${BLUE}Backed up ${workflow} to ${BACKUP_DIR}/$(basename "$workflow")${NC}"
    
    # Remove the workflow file
    git rm "$workflow"
    echo -e "${RED}Removed ${workflow}${NC}"
done

echo -e "${GREEN}=== Workflow Removal Complete ===${NC}"
echo -e "${YELLOW}Don't forget to commit and push these changes${NC}"
echo -e "${YELLOW}Backup files are stored in ${BACKUP_DIR}${NC}"
