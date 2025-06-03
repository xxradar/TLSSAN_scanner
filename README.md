# TLSSAN_scanner
**Version 1.6**

## Overview
This project provides a tool, `tlssan_scan.sh`, to scan a target server for X.509 Subject Alternative Name (SAN) extensions in its TLS/SSL certificate. It also includes Docker support for building and running the scanner in a containerized environment, along with scripts for CI/CD integration.

## Prerequisites
For manual use of the shell script or for building/running Docker images locally, you will need the following tools installed:
- **Bash**: For running the shell scripts.
- **OpenSSL**: The `tlssan_scan.sh` script relies on the `openssl` command-line tool.
- **Docker**: For building, running, and pushing Docker images.

## `tlssan_scan.sh` Script

### Purpose
The `tlssan_scan.sh` script connects to a specified Fully Qualified Domain Name (FQDN) and port, retrieves its TLS/SSL certificate, and extracts the X.509 Subject Alternative Name (SAN) extensions. These SANs are then printed to standard output.

### Usage
To run the script directly:
```bash
./tlssan_scan.sh <fqdn> <port>
```
**Example:**
```bash
./tlssan_scan.sh www.google.com 443
```

### Help Option
For more information and to check your OpenSSL version, use the `-h` or `--help` option:
```bash
./tlssan_scan.sh -h
```

## Docker Usage

The project includes scripts to manage the Docker image lifecycle: build, push, and deploy (run).

### Building the Image (`scripts/build.sh`)
The `scripts/build.sh` script automates the Docker image build process.
**Usage:**
```bash
cd scripts
./build.sh
```
**Required Environment Variables:**
- `AQUA_TOKEN`: An Aqua Security token, likely used for security scanning during the build process (as suggested by the variable name in the build script).
- `BUILD_ID`: A unique identifier for the build (e.g., a timestamp, commit hash, or version number). This ID is used to tag the Docker image (e.g., `fqdnsan_scan:$BUILD_ID`).

### Pushing the Image (`scripts/push.sh`)
The `scripts/push.sh` script tags the locally built image and pushes it to a Docker registry (configured for `xxradar/fqdnsan_scan`).
**Usage:**
```bash
cd scripts
./push.sh
```
**Required Environment Variables:**
- `DOCKER_USER`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password or access token.
- `BUILD_ID`: The same build identifier used during the build phase to identify the image to be pushed (e.g., `xxradar/fqdnsan_scan:$BUILD_ID`).

### Running the Scanner via Docker (`scripts/deploy.sh`)
The `scripts/deploy.sh` script runs the scanner Docker container. It pulls the image if not available locally (assuming it was pushed to a registry accessible to Docker).
**Usage:**
```bash
cd scripts
./deploy.sh
```
**Required Environment Variables:**
- `URLTOSCAN`: The FQDN of the target server to scan (e.g., `www.example.com`).
- `PORTTOSCAN`: The TLS port of the target server (e.g., `443`).
- `BUILD_ID`: The build identifier of the Docker image to run (e.g., `xxradar/fqdnsan_scan:$BUILD_ID`). This ensures you are running the intended version of the scanner.

## Testing
The project includes a test script to verify the functionality of `tlssan_scan.sh`.
To run the tests:
```bash
cd scripts
./test.sh
```
This script executes various test cases, including checks for help options, argument handling, error conditions, and successful SAN retrieval.

## CI/CD
A `JENKINSFILE` is included in the project. This file defines a Jenkins pipeline for automating the build, test, push, and deploy stages of the TLSSAN_scanner, facilitating a Continuous Integration/Continuous Deployment workflow.

---
*Ensure all scripts in the `scripts/` directory are executable (`chmod +x scripts/*.sh`)*
