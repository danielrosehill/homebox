#!/bin/bash

# Script to build and run the Docker image for testing the favorites feature
# Usage: ./build-and-run.sh

set -e

# Set build arguments
COMMIT=$(git rev-parse --short HEAD)
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION="dev-favorites"

# Build the Docker image
echo "Building Docker image for favorites feature testing..."
docker build \
  --build-arg COMMIT="$COMMIT" \
  --build-arg BUILD_TIME="$BUILD_TIME" \
  --build-arg VERSION="$VERSION" \
  -t danielrosehill/homebox:favorite-items -f Dockerfile ../..

# Run the Docker container
echo "Running Docker container for favorites feature testing..."
docker-compose up -d

echo "Docker container is now running."
echo "You can access the application at http://localhost:7745"
echo "To stop the container, run: docker-compose down"
