#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine the real (non-root) user and their home directory robustly.
# - If running as root, prefer SUDO_USER when it maps to a non-root home.
# - If running non-root, prefer the login name (logname) or USER.
REAL_USER=""
REAL_HOME=""
if [ "$(id -u)" -eq 0 ]; then
    # running as root; try SUDO_USER first
    if [ -n "${SUDO_USER:-}" ]; then
        candidate_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        if [ -n "$candidate_home" ] && [ "$candidate_home" != "/root" ]; then
            REAL_USER="$SUDO_USER"
            REAL_HOME="$candidate_home"
        fi
    fi
    # fallback to SUDO_UID if available
    if [ -z "$REAL_USER" ] && [ -n "${SUDO_UID:-}" ]; then
        candidate_user=$(getent passwd "${SUDO_UID}" | cut -d: -f1)
        candidate_home=$(getent passwd "$candidate_user" | cut -d: -f6)
        if [ -n "$candidate_user" ] && [ -n "$candidate_home" ] && [ "$candidate_home" != "/root" ]; then
            REAL_USER="$candidate_user"
            REAL_HOME="$candidate_home"
        fi
    fi
    # final fallback to root
    REAL_USER="${REAL_USER:-root}"
    REAL_HOME="${REAL_HOME:-/root}"
else
    # running as non-root: prefer logname, then USER
    login_user=$(logname 2>/dev/null || true)
    if [ -n "$login_user" ]; then
        REAL_USER="$login_user"
    else
        REAL_USER="${USER:-$(id -un)}"
    fi
    REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
    REAL_HOME="${REAL_HOME:-$HOME}"
fi

SCREENSHOTS_DIR="$REAL_HOME/Pictures/Screenshots"
SCREENRECORD_DIR="$REAL_HOME/Videos/Screencasts"
EDITOR=code

echo "Setting default variables ..."

# Desired modes and owner
DESIRED_DIR_MODE=755
DESIRED_FILE_MODE=644
DESIRED_OWNER="$REAL_USER"
DESIRED_GROUP="$REAL_USER"

# Helper: check and enforce directory mode/owner idempotently
ensure_dir() {
    local path="$1"
    mkdir -p "$path"

    # gather current metadata
    cur_owner=$(stat -c '%U' "$path" 2>/dev/null || echo "")
    cur_group=$(stat -c '%G' "$path" 2>/dev/null || echo "")
    cur_mode=$(stat -c '%a' "$path" 2>/dev/null || echo "")

    if [ "$cur_owner" = "$DESIRED_OWNER" ] && [ "$cur_group" = "$DESIRED_GROUP" ] && [ "$cur_mode" = "$DESIRED_DIR_MODE" ]; then
        echo "Skip: $path already has owner ${DESIRED_OWNER}:${DESIRED_GROUP} and mode ${DESIRED_DIR_MODE}"
        return 0
    fi

    # If running as root we can change owner and mode; otherwise only attempt mode if owned by current user
    if [ "$(id -u)" -eq 0 ]; then
        chown -R "$DESIRED_OWNER:$DESIRED_GROUP" "$path" 2>/dev/null || true
        chmod "$DESIRED_DIR_MODE" "$path" 2>/dev/null || true
        echo "Updated: $path -> ${DESIRED_OWNER}:${DESIRED_GROUP} ${DESIRED_DIR_MODE}"
    else
        if [ "$cur_owner" = "$(id -un)" ]; then
            chmod "$DESIRED_DIR_MODE" "$path" 2>/dev/null || true
            echo "Updated mode: $path -> ${DESIRED_DIR_MODE}"
        else
            echo "Notice: cannot change owner of $path (run as root to fix)."
        fi
    fi
}

# Helper: check and enforce file mode/owner idempotently
ensure_file() {
    local file="$1"
    # Try to create the file; if touch fails due to permissions, attempt to
    # create it using sudo so the caller (non-root) can subsequently write to it.
    if ! touch "$file" 2>/dev/null; then
        if command -v sudo >/dev/null 2>&1; then
            echo "Info: creating $file with sudo and fixing ownership -> $DESIRED_OWNER"
            sudo mkdir -p "$(dirname "$file")"
            sudo bash -c ": > '$file'"
            sudo chown "$DESIRED_OWNER:$DESIRED_GROUP" "$file" 2>/dev/null || true
            sudo chmod "$DESIRED_FILE_MODE" "$file" 2>/dev/null || true
        else
            echo "Error: cannot create $file and sudo is unavailable. Run as a user that can write to $(dirname "$file")" >&2
            return 1
        fi
    fi

    cur_owner=$(stat -c '%U' "$file" 2>/dev/null || echo "")
    cur_group=$(stat -c '%G' "$file" 2>/dev/null || echo "")
    cur_mode=$(stat -c '%a' "$file" 2>/dev/null || echo "")

    if [ "$cur_owner" = "$DESIRED_OWNER" ] && [ "$cur_group" = "$DESIRED_GROUP" ] && [ "$cur_mode" = "$DESIRED_FILE_MODE" ]; then
        echo "Skip: $file already has owner ${DESIRED_OWNER}:${DESIRED_GROUP} and mode ${DESIRED_FILE_MODE}"
        return 0
    fi

    if [ "$(id -u)" -eq 0 ]; then
        chown "$DESIRED_OWNER:$DESIRED_GROUP" "$file" 2>/dev/null || true
        chmod "$DESIRED_FILE_MODE" "$file" 2>/dev/null || true
        echo "Updated: $file -> ${DESIRED_OWNER}:${DESIRED_GROUP} ${DESIRED_FILE_MODE}"
    else
        if [ "$cur_owner" = "$(id -un)" ]; then
            chmod "$DESIRED_FILE_MODE" "$file" 2>/dev/null || true
            echo "Updated mode: $file -> ${DESIRED_FILE_MODE}"
        else
            echo "Notice: cannot change owner of $file (run as root to fix)."
        fi
    fi
}

# Ensure directories and file exist and have correct permissions/ownership
ensure_dir "$SCREENSHOTS_DIR"
ensure_dir "$SCREENRECORD_DIR"

UWSM_DEFAULTS_FILE="$REAL_HOME/.config/uwsm/default"
UWSM_DIR="$(dirname "$UWSM_DEFAULTS_FILE")"

# Create the directory if needed. If it exists but is not writable by the
# real user, use sudo to fix ownership and permissions so we can write the
# defaults file while keeping the top-level installer non-root.
mkdir -p "$UWSM_DIR" 2>/dev/null || true
if [ ! -w "$UWSM_DIR" ]; then
    if command -v sudo >/dev/null 2>&1; then
        echo "Info: fixing ownership/permissions for $UWSM_DIR with sudo -> $DESIRED_OWNER"
        sudo mkdir -p "$UWSM_DIR"
        sudo chown -R "$DESIRED_OWNER:$DESIRED_GROUP" "$UWSM_DIR"
        sudo chmod 0755 "$UWSM_DIR"
    else
        echo "Error: $UWSM_DIR is not writable and sudo is unavailable. Run as a user that can write to $UWSM_DIR" >&2
        exit 1
    fi
fi

ensure_file "$UWSM_DEFAULTS_FILE"


# Function to set a variable (written as an exported env var) in the UWSM defaults file
# This will write lines like: export VAR="value"
set_uwsm_variable() {
    local var_name="$1"
    local var_value="$2"
    local file_path="$3"

    # If a line with either 'VAR=' or 'export VAR=' exists, replace it; otherwise append
    if grep -qE "^[[:space:]]*(export[[:space:]]+)?${var_name}[[:space:]]*=" "$file_path"; then
        sed -i "s|^[[:space:]]*\(export[[:space:]]\+\)\?${var_name}[[:space:]]*=.*|export ${var_name}=\"${var_value}\"|" "$file_path"
        echo "${var_name} already present moving on ..."
    else
        echo "export ${var_name}=\"${var_value}\"" >> "$file_path"
        echo "Updated ${var_name} in $file_path"
    fi
}

# Add Omarchy-specific exports that point to the resolved directories
set_uwsm_variable "OMARCHY_SCREENSHOT_DIR" "$SCREENSHOTS_DIR" "$UWSM_DEFAULTS_FILE"
set_uwsm_variable "OMARCHY_SCREENRECORD_DIR" "$SCREENRECORD_DIR" "$UWSM_DEFAULTS_FILE"
