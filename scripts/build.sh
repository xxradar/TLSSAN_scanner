#!/bin/bash
docker --version
docker build --no-cache --build-arg=token=$AQUA_TOKEN -t fqdnsan_scan:$BUILD_ID .
