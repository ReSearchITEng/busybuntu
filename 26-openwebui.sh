#!/bin/bash

# Deploy Open WebUI with Docker and connect it to an Ollama server.
# Configure via environment variables before running:
#   OLLAMA_URL      (default: http://localhost:11434)
#   OPENWEBUI_PORT  (default: 8080)
#   OPENWEBUI_IMAGE (default: ghcr.io/open-webui/open-webui:latest)
#   CONTAINER_NAME  (default: open-webui)
#   VOLUME_NAME     (default: open-webui)
# Example overrides:
#   OLLAMA_URL=http://<ollama-host>:11434 OPENWEBUI_PORT=3000 ./26-openwebui.sh

set -euo pipefail

# Try to source helper libs if present (non-fatal if missing)
. ./001-helper-functions-library.sh 2>/dev/null || true
. ./001-versions.sh 2>/dev/null || true

echo "$0"

OPENWEBUI_PORT="${OPENWEBUI_PORT:-8080}"
OLLAMA_URL="${OLLAMA_URL:-http://192.168.3.50:11434}"
OPENWEBUI_IMAGE="${OPENWEBUI_IMAGE:-ghcr.io/open-webui/open-webui:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-open-webui}"
VOLUME_NAME="${VOLUME_NAME:-open-webui}"

# Ensure Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Run 31-docker.sh first."
  exit 1
fi

# Create a persistent data volume if missing
if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
  docker volume create "$VOLUME_NAME" >/dev/null
fi

# Optional: probe Ollama endpoint reachability
if command -v curl >/dev/null 2>&1; then
  if curl -sSf "${OLLAMA_URL%/}/api/version" >/dev/null 2>&1; then
    echo "Detected Ollama at ${OLLAMA_URL}"
  else
    echo "Warning: Cannot reach ${OLLAMA_URL%/}/api/version from host. Ensure the container can reach it."
  fi
fi

# Recreate container idempotently
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "$CONTAINER_NAME" >/dev/null || true
fi

# On Linux, make host.docker.internal resolvable inside the container
ADD_HOST_ARG=(--add-host=192.168.3.50:host-gateway)

# Run Open WebUI
exec docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "${OPENWEBUI_PORT}:8080" \
  "${ADD_HOST_ARG[@]}" \
  -e "OLLAMA_BASE_URL=${OLLAMA_URL}" \
  -e "WEBUI_AUTH=true" \
  -e "TZ=${TZ:-UTC}" \
  -v "${VOLUME_NAME}:/app/backend/data" \
  "$OPENWEBUI_IMAGE"
