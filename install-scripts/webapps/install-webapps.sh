#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Webapps"
WEBAPPS_DIR="$SCRIPT_DIR"

log_info "Installing webapps from $WEBAPPS_DIR..."

find "$WEBAPPS_DIR" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
    app_name=$(basename "$dir")
    desktop_file="$dir/$app_name.desktop"
    icon_file="$dir/$app_name.png"

    if [ ! -f "$icon_file" ]; then
        icon_file="$dir/$app_name.svg"
    fi

    if [ -f "$desktop_file" ] && [ -f "$icon_file" ]; then
        log_info "Installing $app_name..."

        applications_folder="$HOME/.local/share/applications/$app_name.desktop"
        icon_dest="$HOME/.local/share/applications/icons/$app_name.$(basename "$icon_file" | sed 's/.*\.//')"

        mkdir -p "$(dirname "$applications_folder")"
        mkdir -p "$(dirname "$icon_dest")"

        rm -f "$applications_folder"
        rm -f "$icon_dest"

        cp "$desktop_file" "$applications_folder"
        cp "$icon_file" "$icon_dest"

        if grep -q '^[[:space:]]*Icon[[:space:]]*=' "$applications_folder" 2>/dev/null; then
            sed -i "s|^[[:space:]]*Icon[[:space:]]*=.*|Icon=$icon_dest|" "$applications_folder"
        else
            echo "Icon=$icon_dest" >> "$applications_folder"
        fi

        chown "$USER:$USER" "$applications_folder" "$icon_dest" 2>/dev/null || true
        chmod 755 "$applications_folder"
        chmod 644 "$icon_dest"

        log_success "$app_name successfully installed!"
        echo
    else
        log_warn "Warning: $app_name"
        if [ ! -f "$desktop_file" ]; then
            log_error "No desktop file found ($desktop_file)"
        fi
        if [ ! -f "$icon_file" ]; then
            log_error "No icon file found (tried $dir$app_name.png and $dir$app_name.svg)"
        fi
        echo
    fi
done

log_success "Webapp installation completed!"
