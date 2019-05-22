#!/bin/bash
echo  "*** Login to Dockerhub ***"
docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
echo  "*** TAG image to xxradar repo ***"
docker tag fqdnsan_scan:$BUILD_VAR xxradar/fqdnsan_scan:$BUILD_VAR
echo  "*** Push image ***"
docker push xxradar/fqdnsan_scan:$BUILD_VAR
