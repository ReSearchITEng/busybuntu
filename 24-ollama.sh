#!/bin/bash

# Install and configure Ollama (CPU) as a systemd service, bind to 0.0.0.0, and set threads.
# Configuration via environment variables (override by exporting before running):
#   OLLAMA_BIND       (default: 0.0.0.0:11434)
#   OLLAMA_THREADS    (default: $(nproc))
#   OLLAMA_ORIGINS    (default: empty; set to * to allow browser UIs)
#   OLLAMA_PULL_MODELS (default: "") e.g. "qwen2:7b-instruct-q4_K_M llama3.2:3b-instruct"
#   OLLAMA_INSTALL    (default: yes) set to no to skip install
#   OLLAMA_CONFIGURE_CONTINUE (default: yes) set to no to skip Continue VSCode extension config
#
# Usage examples:
#   ./24-ollama.sh
#   OLLAMA_PULL_MODELS="qwen2:7b-instruct-q4_K_M" ./24-ollama.sh
#   OLLAMA_BIND=0.0.0.0:11434 OLLAMA_THREADS=16 ./24-ollama.sh
#   OLLAMA_CONFIGURE_CONTINUE=no ./24-ollama.sh

set -euo pipefail

. ./001-helper-functions-library.sh 2>/dev/null || true
. ./001-versions.sh 2>/dev/null || true

echo "$0"

# Defaults
OLLAMA_BIND="${OLLAMA_BIND:-0.0.0.0:11434}"
OLLAMA_THREADS="${OLLAMA_THREADS:-$(nproc)}"
OLLAMA_ORIGINS="${OLLAMA_ORIGINS:-}"
# If not provided, pre-pull a small, CPU-friendly set of instruct models (4-bit where available)
OLLAMA_PULL_MODELS="${OLLAMA_PULL_MODELS:-qwen2:7b-instruct-q4_K_M llama3.1:8b-instruct-q4_K_M mistral:7b-instruct-v0.3-q4_K_M}"
OLLAMA_INSTALL="${OLLAMA_INSTALL:-yes}"
OLLAMA_CONFIGURE_CONTINUE="${OLLAMA_CONFIGURE_CONTINUE:-yes}"

install_ollama() {
  if command -v ollama >/dev/null 2>&1; then
    echo "ollama already installed: $(command -v ollama)"
    return 0
  fi
  echo "Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
}

ensure_service_override() {
  sudo mkdir -p /etc/systemd/system/ollama.service.d
  local override=/etc/systemd/system/ollama.service.d/override.conf
  echo "Writing systemd drop-in: $override"
  sudo bash -c "cat > '$override' <<EOF
[Service]
Environment=OLLAMA_HOST=${OLLAMA_BIND}
Environment=OLLAMA_NUM_THREADS=${OLLAMA_THREADS}
${OLLAMA_ORIGINS:+Environment=OLLAMA_ORIGINS=${OLLAMA_ORIGINS}}
EOF"
  sudo systemctl daemon-reload
  sudo systemctl enable ollama >/dev/null 2>&1 || true
  sudo systemctl restart ollama
}

probe() {
  echo "Probing Ollama API..."
  if command -v curl >/dev/null 2>&1; then
    if curl -sSf "http://127.0.0.1:${OLLAMA_BIND#*:}/api/version" >/dev/null; then
      echo "Local probe OK"
    else
      echo "Warning: local probe failed; check service logs (sudo journalctl -u ollama -n 100 -e)."
    fi
  fi
  echo "Listening sockets for ${OLLAMA_BIND#*:}:"
  (ss -lntp 2>/dev/null || netstat -lntp 2>/dev/null || true) | grep "$(echo "${OLLAMA_BIND#*:}")" || true
}

pull_models() {
  [ -z "$OLLAMA_PULL_MODELS" ] && return 0
  echo "Pulling models: $OLLAMA_PULL_MODELS"
  for m in $OLLAMA_PULL_MODELS; do
    echo "-> ollama pull $m"
    ollama pull "$m" || true
  done
}

configure_continue_vscode() {
  [ "$OLLAMA_CONFIGURE_CONTINUE" != "yes" ] && return 0
  
  echo "Configuring Continue VSCode extension for Ollama..."
  
  # Get the actual bind address for the config
  local ollama_host="127.0.0.1"
  local ollama_port="${OLLAMA_BIND#*:}"
  
  # If binding to 0.0.0.0, use localhost for the Continue config
  if [[ "$OLLAMA_BIND" == "0.0.0.0:"* ]]; then
    ollama_host="127.0.0.1"
  else
    ollama_host="${OLLAMA_BIND%:*}"
  fi
  
  local continue_dir="$HOME/.continue"
  local config_file="$continue_dir/config.json"
  
  # Create Continue config directory
  mkdir -p "$continue_dir"
  
  # Get the first model from OLLAMA_PULL_MODELS for the default
  local default_model
  if [ -n "$OLLAMA_PULL_MODELS" ]; then
    default_model=$(echo "$OLLAMA_PULL_MODELS" | awk '{print $1}')
  else
    default_model="qwen2:7b-instruct-q4_K_M"
  fi
  
  echo "Creating Continue config: $config_file"
  cat > "$config_file" <<EOF
{
  "models": [
    {
      "title": "Ollama",
      "provider": "ollama",
      "model": "$default_model",
      "apiBase": "http://$ollama_host:$ollama_port"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Ollama Autocomplete",
    "provider": "ollama",
    "model": "$default_model",
    "apiBase": "http://$ollama_host:$ollama_port"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://$ollama_host:$ollama_port"
  },
  "allowAnonymousTelemetry": false,
  "docs": []
}
EOF
  
  echo "Continue VSCode extension configured!"
  echo "Default model: $default_model"
  echo "Ollama endpoint: http://$ollama_host:$ollama_port"
  echo ""
  echo "To use Continue in VSCode:"
  echo "1. Install the Continue extension from the marketplace"
  echo "2. Press Ctrl+I to start a conversation with the AI"
  echo "3. Press Tab to accept autocomplete suggestions"
  echo ""
  echo "Note: You may want to pull the embedding model:"
  echo "  ollama pull nomic-embed-text"
}

# 1) Install (optional)
if [ "$OLLAMA_INSTALL" = "yes" ]; then
  install_ollama
else
  echo "Skipping Ollama install (OLLAMA_INSTALL=no)."
fi

# 2) Ensure service exists
check_ollama_service() {
  # Try multiple methods to check if ollama service exists
  if systemctl cat ollama.service >/dev/null 2>&1; then
    return 0
  elif [ -f /etc/systemd/system/ollama.service ] || [ -f /usr/lib/systemd/system/ollama.service ]; then
    return 0
  elif systemctl list-unit-files ollama.service 2>/dev/null | grep -q ollama.service; then
    return 0
  else
    return 1
  fi
}

if ! check_ollama_service; then
  echo "Error: ollama.service not found. Install Ollama first."
  exit 1
fi

# 3) Configure and restart
ensure_service_override

# 4) Verify
probe

# 5) Optionally pull models
pull_models

# 6) Optionally configure Continue VSCode extension
configure_continue_vscode

echo "Done. Connect clients to: http://$(hostname -I | awk '{print $1}'):${OLLAMA_BIND#*:} (LAN)"
echo "Example Open WebUI setting: OLLAMA_BASE_URL=http://<this-host>:${OLLAMA_BIND#*:}"
