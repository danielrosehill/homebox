#!/bin/bash

# Set the name of the docker testing branch
DOCKER_BRANCH="docker/features-favorite-items"

# Set the feature branch to merge
FEATURE_BRANCH="feature/favorite-items"

# Create the docker testing branch from the current branch
git checkout -b "$DOCKER_BRANCH"

# Merge the feature branch into the docker testing branch
git merge "$FEATURE_BRANCH"

echo "Successfully created and merged $FEATURE_BRANCH into $DOCKER_BRANCH"
