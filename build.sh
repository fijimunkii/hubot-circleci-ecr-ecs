#!/usr/bin/env bash

set -e
set -u
set -o pipefail

DOCKER_LOGIN=`aws ecr get-login --region us-east-1`
DOCKER_REGISTRY=`echo $DOCKER_LOGIN | sed 's|.*https://||'`
eval "$DOCKER_LOGIN"
docker info
docker pull $DOCKER_REGISTRY/$DOCKER_IMAGE:latest || true
docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
