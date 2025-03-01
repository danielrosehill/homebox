#!/bin/bash

# Script to seed 10 dummy assets for testing the asset ID search feature
# This script uses curl to make API calls to the Homebox API

set -e

# Configuration
API_URL="http://localhost:7746/api"
USERNAME="admin@example.com"
PASSWORD="Password123!"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Homebox Test Data Seeder ===${NC}"
echo -e "${BLUE}This script will create 10 test items with asset IDs for testing${NC}"
echo -e "${YELLOW}Using credentials:${NC}"
echo -e "${YELLOW}Username: ${USERNAME}${NC}"
echo -e "${YELLOW}Password: ${PASSWORD}${NC}"
echo -e "${YELLOW}If you've changed these credentials, please update them in this script.${NC}"

# Check if registration is needed
echo -e "${BLUE}Checking if registration is needed...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "${API_URL}/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}")

if [[ "$LOGIN_RESPONSE" == *"404"* || "$LOGIN_RESPONSE" == *"401"* || "$LOGIN_RESPONSE" == *"invalid credentials"* ]]; then
  echo -e "${YELLOW}User not found or invalid credentials. Attempting to register...${NC}"
  
  # Try to register
  REGISTER_RESPONSE=$(curl -s -X POST "${API_URL}/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${USERNAME}\",\"password\":\"${PASSWORD}\",\"name\":\"Admin User\"}")
  
  if [[ "$REGISTER_RESPONSE" == *"error"* ]]; then
    echo -e "${RED}Registration failed. Error: ${REGISTER_RESPONSE}${NC}"
    echo -e "${YELLOW}Please register manually with the credentials above and then run this script again.${NC}"
    exit 1
  else
    echo -e "${GREEN}Registration successful!${NC}"
  fi
fi

# Login and get token
echo -e "${BLUE}Logging in...${NC}"
TOKEN=$(curl -s -X POST "${API_URL}/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Failed to login. Please check your credentials and make sure Homebox is running.${NC}"
  exit 1
fi

echo -e "${GREEN}Login successful!${NC}"

# Get group ID
echo -e "${BLUE}Getting group ID...${NC}"
GROUP_ID=$(curl -s -X GET "${API_URL}/v1/users/self" \
  -H "Authorization: Bearer ${TOKEN}" | grep -o '"defaultGroup":"[^"]*' | cut -d'"' -f4)

if [ -z "$GROUP_ID" ]; then
  echo -e "${RED}Failed to get group ID.${NC}"
  exit 1
fi

echo -e "${GREEN}Got group ID: ${GROUP_ID}${NC}"

# Create a test location if it doesn't exist
echo -e "${BLUE}Creating test location...${NC}"
LOCATION_ID=$(curl -s -X POST "${API_URL}/v1/locations" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test Location\",\"description\":\"Location for test items\"}" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$LOCATION_ID" ]; then
  # Try to get existing location
  LOCATION_ID=$(curl -s -X GET "${API_URL}/v1/locations" \
    -H "Authorization: Bearer ${TOKEN}" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
  
  if [ -z "$LOCATION_ID" ]; then
    echo -e "${RED}Failed to create or find a location.${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}Using location ID: ${LOCATION_ID}${NC}"

# Create 10 test items with different asset IDs
echo -e "${BLUE}Creating 10 test items...${NC}"

# Array of item names and descriptions
ITEMS=(
  "Laptop|Dell XPS 13 Developer Edition"
  "Monitor|27-inch 4K Display"
  "Keyboard|Mechanical RGB Keyboard"
  "Mouse|Wireless Ergonomic Mouse"
  "Headphones|Noise Cancelling Headphones"
  "Desk|Standing Desk with Adjustable Height"
  "Chair|Ergonomic Office Chair"
  "Docking Station|USB-C Docking Station"
  "External Drive|1TB SSD External Drive"
  "Webcam|4K Webcam with Microphone"
)

for i in {1..10}; do
  # Get item details from array
  IFS='|' read -r NAME DESCRIPTION <<< "${ITEMS[$i-1]}"
  
  # Create item
  RESPONSE=$(curl -s -X POST "${API_URL}/v1/items" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\":\"${NAME}\",
      \"description\":\"${DESCRIPTION}\",
      \"locationId\":\"${LOCATION_ID}\"
    }")
  
  ITEM_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
  
  if [ -z "$ITEM_ID" ]; then
    echo -e "${RED}Failed to create item ${i}.${NC}"
    continue
  fi
  
  # Create a custom asset ID (1000 + index)
  ASSET_ID=$((1000 + i))
  
  # Update the item with the asset ID
  UPDATE_RESPONSE=$(curl -s -X PUT "${API_URL}/v1/items/${ITEM_ID}" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"id\":\"${ITEM_ID}\",
      \"name\":\"${NAME}\",
      \"description\":\"${DESCRIPTION}\",
      \"locationId\":\"${LOCATION_ID}\",
      \"assetId\":\"${ASSET_ID}\",
      \"quantity\":1,
      \"insured\":false,
      \"archived\":false,
      \"labelIds\":[],
      \"serialNumber\":\"SN${ASSET_ID}\",
      \"modelNumber\":\"MDL${ASSET_ID}\",
      \"manufacturer\":\"Test Manufacturer\",
      \"lifetimeWarranty\":false,
      \"warrantyExpires\":\"2025-12-31\",
      \"warrantyDetails\":\"Standard warranty\",
      \"purchaseTime\":\"2023-01-01\",
      \"purchaseFrom\":\"Test Store\",
      \"purchasePrice\":\"${i}99.99\",
      \"soldTime\":\"0001-01-01\",
      \"soldTo\":\"\",
      \"soldPrice\":\"0\",
      \"soldNotes\":\"\",
      \"notes\":\"Test item ${i} with asset ID ${ASSET_ID}\"
    }")
  
  if [[ "$UPDATE_RESPONSE" == *"error"* ]]; then
    echo -e "${RED}Failed to update item ${i} with asset ID ${ASSET_ID}.${NC}"
  else
    echo -e "${GREEN}Created item ${i}: ${NAME} with asset ID #${ASSET_ID}${NC}"
  fi
done

echo -e "${GREEN}=== Seeding complete! ===${NC}"
echo -e "${BLUE}You can now test the asset ID search feature with the following asset IDs: 1001-1010${NC}"
echo -e "${BLUE}Example: Toggle 'Search by Asset ID' and enter '1005' to find the 'Headphones'${NC}"
