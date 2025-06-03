#!/bin/bash
# This script builds the Docker image for the FQDN SAN scanner.
# It requires AQUA_TOKEN and BUILD_ID environment variables to be set.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if AQUA_TOKEN is set
if [ -z "$AQUA_TOKEN" ]; then
  echo "Error: AQUA_TOKEN environment variable is not set." >&2
  exit 1
fi

# Check if BUILD_ID is set
if [ -z "$BUILD_ID" ]; then
  echo "Error: BUILD_ID environment variable is not set." >&2
  exit 1
fi

echo "--- Checking Docker version ---"
docker --version

echo "--- Building Docker image fqdnsan_scan:$BUILD_ID ---"
# Build the Docker image, passing AQUA_TOKEN as a build argument.
# --no-cache is used to ensure the image is always rebuilt with the latest dependencies/code.
docker build --no-cache --build-arg=token="$AQUA_TOKEN" -t "fqdnsan_scan:$BUILD_ID" .

echo "--- Docker image fqdnsan_scan:$BUILD_ID built successfully ---"
