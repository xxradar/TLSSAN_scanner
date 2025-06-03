#!/bin/bash
# This script runs the FQDN SAN scanner Docker container.
# It requires URLTOSCAN, PORTTOSCAN, and BUILD_ID environment variables to be set.
# Note: BUILD_ID should match the ID of the image pushed by push.sh.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if URLTOSCAN is set
if [ -z "$URLTOSCAN" ]; then
  echo "Error: URLTOSCAN environment variable is not set." >&2
  exit 1
fi

# Check if PORTTOSCAN is set
if [ -z "$PORTTOSCAN" ]; then
  echo "Error: PORTTOSCAN environment variable is not set." >&2
  exit 1
fi

# Check if BUILD_ID is set (to ensure we run the correct image version)
if [ -z "$BUILD_ID" ]; then
  echo "Error: BUILD_ID environment variable is not set. Cannot determine which image version to run." >&2
  exit 1
fi

image_name="xxradar/fqdnsan_scan:$BUILD_ID"

echo "--- Running Docker container $image_name with URL: $URLTOSCAN and Port: $PORTTOSCAN ---"
# Run the Docker container, passing URLTOSCAN and PORTTOSCAN as arguments to the entrypoint/CMD.
# --rm automatically removes the container when it exits.
docker run --rm "$image_name" "$URLTOSCAN" "$PORTTOSCAN"

echo "--- Docker container $image_name finished ---"
