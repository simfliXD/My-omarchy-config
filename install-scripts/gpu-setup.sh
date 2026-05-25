#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"


section "Setting up GPU drivers..."

########################################
# Snapper snapshot
########################################
SNAP_ID="N/A"
if snapper list-configs &>/dev/null; then
  log_info "Creating Snapper pre-install snapshot..."
  SNAP_ID=$(sudo snapper create --description "Pre GPU & power driver install" --print-number)
  log_success "Snapshot created: $SNAP_ID"
fi

########################################
# Laptop / Desktop detection
########################################
IS_LAPTOP=false
if [ -d /sys/class/power_supply ]; then
  if ls /sys/class/power_supply 2>/dev/null | grep -qi "bat"; then
    IS_LAPTOP=true
  fi
fi

if $IS_LAPTOP; then
  log_success "System type detected: LAPTOP"
else
  log_success "System type detected: DESKTOP"
fi

########################################
# GPU detection
########################################
GPU_INFO=$(lspci -nn | grep -Ei 'vga|3d|2d|display' | sort -u)

echo
log_info "Detected GPUs:"
echo "$GPU_INFO"
echo

HAS_NVIDIA=false
HAS_INTEL=false
HAS_AMD=false

echo "$GPU_INFO" | grep -qi nvidia && HAS_NVIDIA=true
echo "$GPU_INFO" | grep -qi intel && HAS_INTEL=true
echo "$GPU_INFO" | grep -qi -E 'amd|ati' && HAS_AMD=true

########################################
# NVIDIA legacy detection
########################################
NVIDIA_DRIVER="nvidia"

if $HAS_NVIDIA; then
  NVIDIA_PCI_ID=$(echo "$GPU_INFO" | grep -i nvidia | sed -n 's/.*\[\(10de:[0-9a-fA-F]\+\)\].*/\1/p')

  case "$NVIDIA_PCI_ID" in
    10de:0f*|10de:10*|10de:11*|10de:12*)
      NVIDIA_DRIVER="nvidia-390xx"
      ;;
    10de:13*|10de:14*|10de:15*|10de:16*)
      NVIDIA_DRIVER="nvidia-470xx"
      ;;
  esac

  log_info "Selected NVIDIA driver: $NVIDIA_DRIVER"
fi

########################################
# Base graphics stack
########################################
echo
log_info "Installing base graphics stack..."
 yay -Syu --noconfirm --needed \
  mesa \
  lib32-mesa \
  mesa-utils \
  libva-utils \
  vulkan-icd-loader \
  lib32-vulkan-icd-loader \
  vulkan-tools \
  vkd3d \
  linux-firmware

########################################
# INTEL
########################################
if $HAS_INTEL; then
  log_info "Installing Intel GPU drivers..."
   yay -S --noconfirm --needed \
   vulkan-intel \
   lib32-vulkan-intel \
   intel-media-driver \
   glu \
   lib32-glu
fi

########################################
# AMD
########################################
if $HAS_AMD; then
  log_info "Installing AMD GPU drivers..."
   yay -S --noconfirm --needed \
    vulkan-radeon \
    lib32-vulkan-radeon \
    glu \
    lib32-glu
  
  log_info "Installing AMD system monitoring tools..."
   yay -S --noconfirm --needed amdsmi rocm-smi-lib
fi

########################################
# NVIDIA
########################################

# Dont proceed with installation if nvidia-open is not detected indicating Legacy Nvidia GPU is present
if $HAS_NVIDIA && ! pacman -Si nvidia-open &>/dev/null; then
  log_error "Modern NVIDIA driver 'nvidia-open' not available in repos."
  log_error "This usually means your GPU is Pascal (GTX 10xx) / Maxwell (GTX 900) or older."
  log_error "The main nvidia package was replaced by nvidia-open in Dec 2025 (driver 590+)."
  log_error "For legacy GPUs install from AUR: nvidia-580xx-dkms (Pascal) or nvidia-470xx-dkms etc."
  log_error "Script cannot continue."
  exit 1
fi

if $HAS_NVIDIA; then
  log_info "Installing NVIDIA drivers (nvidia-open)..."
   yay -S --noconfirm --needed \
    nvidia-open \
    nvidia-settings \
    nvidia-utils \
    lib32-nvidia-utils \
    opencl-nvidia \
    lib32-opencl-nvidia \
    nvidia-prime \
    egl-wayland \
    libva-nvidia-driver 

  log_info "Enabling nvidia-persistenced (improves stability/power management)..."
   systemctl enable --now nvidia-persistenced.service
fi

########################################
# PRIME offload (hybrid laptops)
########################################
if $HAS_NVIDIA && { $HAS_INTEL || $HAS_AMD; }; then
  echo
  log_info "Hybrid GPU detected — configuring PRIME offload..."

   tee >/usr/local/bin/nvidia-offload <<'EOF'
   chmod +x /usr/local/bin/nvidia-offload
#!/bin/sh
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
exec "$@"
EOF

  chmod +x /usr/local/bin/nvidia-offload
  
  log_success "✓ PRIME wrapper created: nvidia-offload <app> (or use prime-run from nvidia-prime)"
fi

########################################
# Hyprland notes (bonus section)
########################################
echo
log_info "NOTES:"
log_info "  • NVIDIA: Use GBM + DRM KMS (nvidia-drm.modeset=1 recommended)"
log_info "  • PRIME offload: nvidia-offload steam or prime-run firefox"
log_info "  • Cursor glitches? Add to hyprland.conf: env = WLR_NO_HARDWARE_CURSORS,1"
log_info "  • Verify accel: glxinfo | grep renderer  vainfo"

########################################
# Finish
########################################
echo
log_success "Setup complete!"
log_warn "⚠️  REBOOT REQUIRED for everything to take full effect."
log_info "Rollback snapshot: $SNAP_ID"
sleep 2