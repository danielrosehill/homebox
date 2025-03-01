#!/bin/bash

# build-and-push-docker-image.sh
# Script to build and push the Docker image to Docker Hub

set -e  # Exit on error

# Default values
IMAGE_NAME="danielrosehill/homebox"
TAG="latest"
PUSH_TO_HUB=true
BRANCH="docker/custom-image"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tag=*)
      TAG="${1#*=}"
      shift
      ;;
    --no-push)
      PUSH_TO_HUB=false
      shift
      ;;
    --branch=*)
      BRANCH="${1#*=}"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --tag=TAG         Specify the Docker image tag (default: latest)"
      echo "  --no-push         Build the image but don't push to Docker Hub"
      echo "  --branch=BRANCH   Specify the Git branch to build from (default: docker/custom-image)"
      echo "  --help            Display this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Function to check if Docker is running
check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not accessible"
    exit 1
  fi
}

# Function to check if user is logged in to Docker Hub
check_docker_login() {
  if ! docker info | grep -q "Username"; then
    echo "Warning: You don't appear to be logged in to Docker Hub"
    echo "Please run 'docker login' first or the push will fail"
    
    # Ask if the user wants to continue
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
}

# Main script
main() {
  # Check if Docker is running
  check_docker
  
  # Switch to the specified branch
  echo "Switching to branch: $BRANCH"
  git checkout $BRANCH
  
  # Pull latest changes
  echo "Pulling latest changes from origin/$BRANCH"
  git pull origin $BRANCH
  
  # Build the Docker image
  echo "Building Docker image: $IMAGE_NAME:$TAG"
  docker build -t $IMAGE_NAME:$TAG .
  
  # Push to Docker Hub if requested
  if [ "$PUSH_TO_HUB" = true ]; then
    check_docker_login
    echo "Pushing image to Docker Hub: $IMAGE_NAME:$TAG"
    docker push $IMAGE_NAME:$TAG
    echo "✅ Image successfully pushed to Docker Hub"
  else
    echo "✅ Image successfully built (not pushed to Docker Hub)"
  fi
  
  echo "Done!"
}

# Run the main function
main
