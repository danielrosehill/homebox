#!/bin/bash

# Script to build and push a custom Docker image to DockerHub
# This script is designed to work with the docker/custom-image branch

set -e

# Configuration
IMAGE_NAME="danielrosehill/homebox"
TAG="latest"
DOCKERFILE_PATH="./Dockerfile"

# Ensure we're on the docker/custom-image branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "docker/custom-image" ]; then
    echo "Warning: You are not on the docker/custom-image branch."
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
fi

# Build the Docker image
echo "Building Docker image: $IMAGE_NAME:$TAG"
docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE_PATH" .

# Push to DockerHub
echo "Pushing Docker image to DockerHub: $IMAGE_NAME:$TAG"
docker push "$IMAGE_NAME:$TAG"

echo "Done! Image $IMAGE_NAME:$TAG has been built and pushed to DockerHub."
