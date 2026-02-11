#!/usr/bin/env bash
# Free port 8081 if in use, then start Spring Boot with local profile.
set -e
cd "$(dirname "$0")"

PORT=8081
PID=$(lsof -i :$PORT 2>/dev/null | awk '/LISTEN/ {print $2}' | head -1)
if [ -n "$PID" ]; then
  echo "Stopping process $PID on port $PORT..."
  kill -9 "$PID" 2>/dev/null || true
  sleep 2
fi

echo "Starting backend on port $PORT..."
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
