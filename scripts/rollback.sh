#!/bin/bash
echo "Initiating recovery rollback mechanisms..."

# Stop and clean the broken app container
docker stop techflow-app || true
docker rm techflow-app || true

# Get your Docker Hub username dynamically
DOCKER_USER=$(docker ps -a --format '{{.Image}}' | head -n 1 | cut -d'/' -f1)

echo "Pulling backup image: previous_stable"
docker pull ${DOCKER_USER}/techflow-app:previous_stable

echo "Re-deploying stable target environment..."
docker run -d -p 80:5000 --name techflow-app ${DOCKER_USER}/techflow-app:previous_stable

sleep 5
# Post-rollback stability check
ROLLBACK_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://localhost:5000/health)

if [ "$ROLLBACK_CODE" -eq 200 ]; then
  echo "Rollback successfully completed. Operational traffic stable."
  exit 0
else
  echo "CRITICAL FAULT: Previous baseline environment failed."
  exit 1
fi
