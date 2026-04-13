#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install-scripts/common.sh"

section "Installing AI packages"
log_info "Installing required packages..."
yay -S --noconfirm --needed ollama ollama-rocm ollama-vulkan

if ! command -v docker >/dev/null 2>&1; then
  log_error "Docker is not installed. Please install it."
  exit 1
fi

log_info "Starting Open-WebUI with Ollama backend in Docker..."
docker run -d -p 3000:8080 -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama

log_success "AI installation and Open-WebUI setup completed."
