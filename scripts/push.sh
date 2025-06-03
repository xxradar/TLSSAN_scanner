#!/bin/bash
# This script tags and pushes the built Docker image to Docker Hub.
# It requires DOCKER_USER, DOCKER_PASSWORD, and BUILD_ID environment variables to be set.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if DOCKER_USER is set
if [ -z "$DOCKER_USER" ]; then
  echo "Error: DOCKER_USER environment variable is not set." >&2
  exit 1
fi

# Check if DOCKER_PASSWORD is set
if [ -z "$DOCKER_PASSWORD" ]; then
  echo "Error: DOCKER_PASSWORD environment variable is not set." >&2
  exit 1
fi

# Check if BUILD_ID is set
if [ -z "$BUILD_ID" ]; then
  echo "Error: BUILD_ID environment variable is not set." >&2
  exit 1
fi

echo "*** Logging in to Docker Hub ***"
# Log in to Docker Hub using the provided credentials.
# The password is piped from stdin to avoid it appearing in process lists.
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin

echo "*** Tagging image fqdnsan_scan:$BUILD_ID to xxradar/fqdnsan_scan:$BUILD_ID ***"
docker tag "fqdnsan_scan:$BUILD_ID" "xxradar/fqdnsan_scan:$BUILD_ID"

echo "*** Pushing image xxradar/fqdnsan_scan:$BUILD_ID ***"
docker push "xxradar/fqdnsan_scan:$BUILD_ID"

echo "*** Image xxradar/fqdnsan_scan:$BUILD_ID pushed successfully ***"
