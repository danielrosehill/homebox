#!/bin/bash

# Script to disable unwanted GitHub Actions workflows
# This will modify the workflow files to only run on the main branch
# and keep only the fuzzy search workflow active for the custom-docker-image branch

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

WORKFLOWS_DIR=".github/workflows"
KEEP_ACTIVE="docker-fuzzy-search.yml"

echo -e "${BLUE}=== Disabling Unwanted GitHub Actions Workflows ===${NC}"
echo -e "${YELLOW}This script will modify workflow files to only run on the main branch${NC}"
echo -e "${YELLOW}Only ${KEEP_ACTIVE} will remain active for the custom-docker-image branch${NC}"

# Process each workflow file
for workflow in ${WORKFLOWS_DIR}/*.{yml,yaml}; do
    # Skip if file doesn't exist (in case no .yml or .yaml files)
    [ -f "$workflow" ] || continue
    
    # Skip the fuzzy search workflow
    if [ "$(basename "$workflow")" = "$KEEP_ACTIVE" ]; then
        echo -e "${GREEN}Keeping ${workflow} active${NC}"
        continue
    fi
    
    echo -e "${BLUE}Processing ${workflow}...${NC}"
    
    # Check if the file has an 'on' section
    if grep -q "^on:" "$workflow"; then
        # Backup the original file
        cp "$workflow" "${workflow}.bak"
        
        # Replace the 'on' section to only trigger on main branch
        sed -i '/^on:/,/^[a-z]/ s/branches:.*/branches:\n      - main/' "$workflow"
        
        echo -e "${GREEN}Modified ${workflow} to only run on main branch${NC}"
    else
        echo -e "${YELLOW}Skipping ${workflow} - could not find 'on' section${NC}"
    fi
done

echo -e "${GREEN}=== Workflow Modification Complete ===${NC}"
echo -e "${YELLOW}Don't forget to commit and push these changes${NC}"
