#!/bin/bash
docker --version
docker build --no-cache --build-arg=token=YjRlYTBmZDIxNTdl -t fqdnsan_scan:$BUILD_ID .
