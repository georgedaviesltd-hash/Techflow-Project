#!/bin/bash
set -euo pipefail

DOCKER_USER="${1:?DockerHub username is required}"
IMAGE="${DOCKER_USER}/techflow-app:previous_stable"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "Initiating recovery rollback mechanisms..."

# Stop and clean the broken app container
docker stop techflow-app || true
docker rm techflow-app || true

echo "Pulling backup image: $IMAGE"
docker pull "$IMAGE"

echo "Re-deploying stable target environment..."
docker run -d \
  --name techflow-app \
  --restart unless-stopped \
  -p 80:5000 \
  "$IMAGE"

# Post-rollback stability check
if "$SCRIPT_DIR/health_check.sh"; then
  echo "Rollback successfully completed. Operational traffic stable."
  exit 0
else
  echo "CRITICAL FAULT: Previous baseline environment failed."
  exit 1
fi
