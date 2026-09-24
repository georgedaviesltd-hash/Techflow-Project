#!/bin/bash
RUNNING_IMAGE=$(docker ps --filter "name=techflow-app" --format "{{.Image}}")

if [ -z "$RUNNING_IMAGE" ]; then
  echo "No baseline active container found. Skipping pre-tagging procedures."
  exit 0
fi

DOCKER_USER=$(echo $RUNNING_IMAGE | cut -d'/' -f1)

echo "Active environment found ($RUNNING_IMAGE). Staging previous_stable tag to DockerHub..."
docker tag $RUNNING_IMAGE ${DOCKER_USER}/techflow-app:previous_stable
docker push ${DOCKER_USER}/techflow-app:previous_stable
