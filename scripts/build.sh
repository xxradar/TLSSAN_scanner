#!/bin/bash
docker --version
docker build --no-cache -t fqdnsan_scan:$BUILD_ID .
