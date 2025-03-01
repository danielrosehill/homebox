#!/bin/bash
# build-and-test.sh
#
# This script builds and tests the custom Docker image locally
# without pushing to Docker Hub.
#
# Usage: ./build-and-test.sh [tag]

set -e  # Exit on any error

# Default tag
TAG=${1:-"local-test"}

echo "=== Building custom Docker image with tag '$TAG' ==="

# Build the image
echo "Building image..."
docker build -t danielrosehill/homebox:$TAG -f ../Dockerfile ../../../

echo "=== Build complete ==="
echo "Image built as danielrosehill/homebox:$TAG"
echo ""
echo "To test the image locally:"
echo "1. Run: docker run -d --name homebox-test -p 7746:7745 -v homebox-test-data:/data danielrosehill/homebox:$TAG"
echo "2. Access Homebox at: http://localhost:7746"
echo "3. When finished testing: docker stop homebox-test && docker rm homebox-test"
echo ""
echo "To push this image to Docker Hub:"
echo "docker push danielrosehill/homebox:$TAG"
