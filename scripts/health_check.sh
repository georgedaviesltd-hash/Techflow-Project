#!/bin/bash
URL="${1:-http://localhost/health}"
ATTEMPTS=5
TIMEOUT=3

echo "Starting deployment validation on endpoint: $URL"

for ((i=1; i<=ATTEMPTS; i++)); do
  echo "Attempt $i of $ATTEMPTS: Pinging system..."
  
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$URL" || true)
  
  if [ "$STATUS_CODE" = "200" ]; then
    echo "Application passed health check verification!"
    exit 0
  fi
  
  echo "Endpoint responded with code ${STATUS_CODE:-unavailable}."
  if [ "$i" -lt "$ATTEMPTS" ]; then
    echo "Retrying in 5 seconds..."
    sleep 5
  fi
done

echo "System failed to respond successfully within 5 validation checks."
exit 1
