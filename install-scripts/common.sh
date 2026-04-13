#!/usr/bin/env bash
set -euo pipefail

# Guard against multiple sourcing
if [ "${_COMMON_SH_LOADED:-}" = "1" ]; then
  return 0
fi
readonly _COMMON_SH_LOADED=1

# Standardized logging output for installation scripts.
readonly COLOR_RESET='\033[0m'
readonly COLOR_INFO='\033[1;34m'
readonly COLOR_SUCCESS='\033[1;32m'
readonly COLOR_WARNING='\033[1;33m'
readonly COLOR_ERROR='\033[1;31m'
readonly COLOR_BOLD='\033[1m'

# Backwards-compatible aliases for legacy scripts
readonly NC="$COLOR_RESET"
readonly GREEN="$COLOR_SUCCESS"
readonly YELLOW="$COLOR_WARNING"
readonly BLUE="$COLOR_INFO"
readonly CYAN='\033[0;36m'

log_info() {
    printf "%b\n" "${COLOR_INFO}${*}${COLOR_RESET}"
}

log_success() {
    printf "%b\n" "${COLOR_SUCCESS}${*}${COLOR_RESET}"
}

log_warn() {
    printf "%b\n" "${COLOR_WARNING}${*}${COLOR_RESET}"
}

log_error() {
    printf "%b\n" "${COLOR_ERROR}ERROR:${COLOR_RESET} ${*}" >&2
}

section() {
    printf "%b\n\n" "${COLOR_BOLD}${COLOR_INFO}==> ${*}${COLOR_RESET}"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Required command '$1' not found. Please install it first."
        exit 1
    fi
}

user_systemctl() {
    if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
        TARGET_USER="$SUDO_USER"
        TARGET_UID="$(id -u "$TARGET_USER")"
        USER_RUNTIME_DIR="/run/user/$TARGET_UID"

        if [ -S "$USER_RUNTIME_DIR/bus" ]; then
            sudo -u "$TARGET_USER" env \
                XDG_RUNTIME_DIR="$USER_RUNTIME_DIR" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$USER_RUNTIME_DIR/bus" \
                systemctl --user "$@"
            return $?
        fi
        return 1
    fi

    systemctl --user "$@"
}
