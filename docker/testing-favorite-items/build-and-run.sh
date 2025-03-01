#!/bin/bash

# Script to build and run the Docker image for testing the favorites feature
# Usage: ./build-and-run.sh

set -e

# Build the Docker image
echo "Building Docker image for favorites feature testing..."
docker build -t danielrosehill/homebox:favorite-items -f Dockerfile ../..

# Run the Docker container
echo "Running Docker container for favorites feature testing..."
docker-compose up -d

echo "Docker container is now running."
echo "You can access the application at http://localhost:7745"
echo "To stop the container, run: docker-compose down"
