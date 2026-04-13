#!/bin/bash

echo "Installing GE-Proton ..."

# GE-Proton update script for Linux desktops
# Installs latest GE-Proton to Steam's compatibilitytools.d directory
#
# Usage Notes:
# - Ideal as a post-hook for apt-up or pac-up (e.g., /etc/apt-up.d/post.d/50-ge-proton or /etc/pac-up.d/post.d/50-ge-proton)
# - Set GE_PROTON_TARGET to override the install directory:
#   - In-script: GE_PROTON_TARGET="/custom/path" (uncomment below)
#   - Export: export GE_PROTON_TARGET="/home/user/.steam/steam/compatibilitytools.d"
#   - CLI: GE_PROTON_TARGET="/path" ./50-ge-proton
# - Use --force-root to allow installation to /root/.steam/... as root
# - Use --debug for verbose output
# - Designed for apt-up/pac-up hooks or standalone use

set -euo pipefail  # Exit on errors, unset vars, and pipe failures


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
source "${SCRIPT_DIR}/../../common.sh"

# GitHub API URL for latest GE-Proton release
GH_API_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

# Uncomment to set a default GE_PROTON_TARGET (optional)
# GE_PROTON_TARGET="/custom/path/to/compatibilitytools.d"

# Debug mode flag
DEBUG=0

# Minimum files expected after extraction (configurable via env var)
MIN_FILES=${MIN_FILES:-5}

# Use apt-up's cecho if available, else fallback to printf
if declare -f cecho >/dev/null 2>&1; then
	log() { cecho "$1" "$2"; }
else
	log() { printf "%b%s%b\n" "${2:-$NC}" "$1" "$NC" >&2; }
fi

# Debug logging function
debug_log() {
	if [[ "$DEBUG" -eq 1 ]]; then
		log "DEBUG: $1" "$YELLOW"
	fi
}

# Function to create a secure temp directory
make_secure_temp() {
	if command -v mktemp >/dev/null 2>&1; then
		mktemp -d /tmp/ge-proton-update.XXXXXX
	else
		local base_dir="${TMPDIR:-/tmp}"
		local template="ge-proton-update.XXXXXX"
		local dir
		local rand
		for _ in {1..10}; do
			rand=$(od -An -N4 -tx /dev/urandom | tr -d ' \n')
			dir="$base_dir/${template/XXXXXX/$rand}"
			if mkdir -m 700 "$dir" 2>/dev/null; then
				echo "$dir"
				return 0
			fi
		done
		log "Error: Failed to create secure temp directory" "$RED"
		exit 1
	fi
}

# Function to detect the effective user
get_effective_user() {
	if [[ "$EUID" -eq 0 ]]; then
		if [[ -v SUDO_USER && -n "$SUDO_USER" ]]; then
			echo "$SUDO_USER"
		else
			echo "root"
		fi
	else
		echo "$USER"
	fi
}

# Function to infer the target user from GE_PROTON_TARGET or fall back to effective user
infer_target_user() {
	local target_dir="$1" effective_user="$2"
	local inferred_user

    # If target_dir is unset or empty, fallback to effective user immediately
    if [[ -z "$target_dir" ]]; then
	    debug_log "GE_PROTON_TARGET is unset or empty, using effective user: $effective_user"
	    echo "$effective_user"
	    return 0
    fi

    # Extract user from path like /home/username/...
    if [[ "$target_dir" =~ ^/home/([^/]+)/ ]]; then
	    inferred_user="${BASH_REMATCH[1]}"
	    if id "$inferred_user" >/dev/null 2>&1; then
		    debug_log "Inferred user from GE_PROTON_TARGET: $inferred_user"
		    echo "$inferred_user"
		    return 0
	    else
		    log "Warning: Inferred user '$inferred_user' from GE_PROTON_TARGET does not exist, falling back to $effective_user" "$YELLOW"
	    fi
    else
	    debug_log "GE_PROTON_TARGET ($target_dir) not in /home, using effective user: $effective_user"
    fi

    # Fallback to effective user
    echo "$effective_user"
}

# Function to detect Steam directory or use override
find_steam_dir() {
	local user="$1" home_dir compat_dir

	if [[ "$EUID" -eq 0 && "$user" != "root" ]]; then
		if ! sudo -u "$user" true 2>/dev/null; then
			log "Error: Cannot switch to user $user via sudo" "$RED"
			exit 1
		fi
	fi

	if [[ -v GE_PROTON_TARGET && -n "${GE_PROTON_TARGET}" ]]; then
		if [[ -d "$GE_PROTON_TARGET" || -w "$(dirname "$GE_PROTON_TARGET")" ]]; then
			if [[ "$EUID" -eq 0 && "$user" != "root" ]]; then
				sudo -u "$user" mkdir -p "$GE_PROTON_TARGET" 2>/dev/null || {
					log "Error: Cannot create $GE_PROTON_TARGET as $user" "$RED"
									exit 1
								}
							else
								mkdir -p "$GE_PROTON_TARGET" 2>/dev/null || {
									log "Error: Cannot create $GE_PROTON_TARGET" "$RED"
																	exit 1
																}
			fi
			echo "$GE_PROTON_TARGET"
			return 0
		else
			log "Warning: GE_PROTON_TARGET ($GE_PROTON_TARGET) is invalid or unwritable" "$RED"
		fi
	fi

	home_dir=$(getent passwd "$user" | cut -d: -f6)
	local steam_base_paths=(
	"$home_dir/.steam/steam"              # Most common native Steam
	"$home_dir/.steam"                    # Older native setups
	"$home_dir/.var/app/com.valvesoftware.Steam/data/Steam"  # Flatpak (may vary)
)

for base in "${steam_base_paths[@]}"; do
	compat_dir="$base/compatibilitytools.d"
	if [[ -d "$compat_dir" ]]; then
		echo "$compat_dir"
		return 0
	fi
done

for base in "${steam_base_paths[@]}"; do
	if [[ -d "$base/steamapps" ]]; then
		compat_dir="$base/compatibilitytools.d"
		if [[ "$EUID" -eq 0 && "$user" != "root" ]]; then
			sudo -u "$user" mkdir -p "$compat_dir" 2>/dev/null || {
				log "Error: Cannot create $compat_dir as $user" "$RED"
							exit 1
						}
					else
						mkdir -p "$compat_dir" 2>/dev/null || {
							log "Error: Cannot create $compat_dir" "$RED"
													exit 1
												}
		fi
		echo "$compat_dir"
		return 0
	fi
done

default_base="$home_dir/.steam/steam"
compat_dir="$default_base/compatibilitytools.d"
if [[ "$EUID" -eq 0 && "$user" != "root" ]]; then
	sudo -u "$user" mkdir -p "$compat_dir" 2>/dev/null || {
		log "Error: Cannot create $compat_dir as $user" "$RED"
			exit 1
		}
	else
		mkdir -p "$compat_dir" 2>/dev/null || {
			log "Error: Cannot create $compat_dir" "$RED"
					exit 1
				}
fi
echo "$compat_dir"
}

# Function to get latest GE-Proton version and URLs
get_latest_release() {
	local compat_dir_param="$1"  # Pass COMPAT_DIR as parameter
	local release_info http_code
	debug_log "Fetching latest release info from GitHub API"
	debug_log "API URL: $GH_API_URL"
	debug_log "Temp dir: $TMP_DIR"

	release_info=$(curl -s -w "%{http_code}" "$GH_API_URL" -o "$TMP_DIR/release.json" 2>&1)
	http_code="${release_info: -3}"
	debug_log "HTTP response code: $http_code"
	debug_log "curl output: $release_info"

	if [[ ! -f "$TMP_DIR/release.json" ]]; then
		log "Error: Failed to create release.json file" "$RED"
		debug_log "Temp directory contents: $(ls -la "$TMP_DIR" 2>&1)"
		exit 1
	fi

	release_info=$(cat "$TMP_DIR/release.json" 2>&1)
	debug_log "JSON file size: $(wc -c < "$TMP_DIR/release.json" 2>/dev/null || echo "unknown")"
	debug_log "First 200 chars of response: ${release_info:0:200}"

	if [[ "$http_code" -eq 403 ]]; then
		log "Error: GitHub API rate limit exceeded" "$RED"
		debug_log "Full API response: $release_info"
		exit 1
	elif [[ "$http_code" -ne 200 ]]; then
		log "Error: GitHub API request failed with HTTP $http_code" "$RED"
		debug_log "Full API response: $release_info"
		exit 1
	fi

	debug_log "Starting JSON parsing"
	if command -v jq >/dev/null 2>&1; then
		debug_log "Using jq for JSON parsing"
		version=$(echo "$release_info" | jq -r '.tag_name' 2>/dev/null || echo "")
		debug_log "jq version result: $version"
		tarball_url=$(echo "$release_info" | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url' 2>/dev/null || echo "")
		debug_log "jq tarball_url result: $tarball_url"
		checksum_url=$(echo "$release_info" | jq -r '.assets[] | select(.name | endswith(".sha512sum")) | .browser_download_url' 2>/dev/null || echo "")
		debug_log "jq checksum_url result: $checksum_url"
	else
		debug_log "Using grep/cut for JSON parsing"
		if grep -P >/dev/null 2>&1 <<< "test"; then
			debug_log "Using grep -P (Perl regex)"
			version=$(echo "$release_info" | grep -oP '"tag_name": "\K[^"]+' 2>/dev/null || echo "")
			tarball_url=$(echo "$release_info" | grep -oP '"browser_download_url": "\K[^"]+\.tar\.gz' 2>/dev/null || echo "")
			checksum_url=$(echo "$release_info" | grep -oP '"browser_download_url": "\K[^"]+\.sha512sum' 2>/dev/null || echo "")
		else
			debug_log "Using basic grep"
			version=$(echo "$release_info" | grep -o '"tag_name": "[^"]*"' 2>/dev/null | head -n1 | cut -d'"' -f4 || echo "")
			tarball_url=$(echo "$release_info" | grep -o '"browser_download_url": "[^"]*\.tar\.gz"' 2>/dev/null | head -n1 | cut -d'"' -f4 || echo "")
			checksum_url=$(echo "$release_info" | grep -o '"browser_download_url": "[^"]*\.sha512sum"' 2>/dev/null | head -n1 | cut -d'"' -f4 || echo "")
		fi
		debug_log "grep/cut version result: $version"
		debug_log "grep/cut tarball_url result: $tarball_url"
		debug_log "grep/cut checksum_url result: $checksum_url"
	fi

	if [[ -z "$version" ]]; then
		log "Error: Failed to parse version from GitHub API" "$RED"
		debug_log "Full API response: $release_info"
		exit 1
	fi

	debug_log "Successfully parsed version: $version"
	debug_log "Checking for assets availability"

	# Check if assets are available
	if [[ -z "$tarball_url" || -z "$checksum_url" ]]; then
		log "Warning: Latest release ($version) doesn't have binary assets available yet" "$YELLOW"
		log "This usually happens when a release is just published but assets are still being uploaded" "$YELLOW"
		log "Please try again in a few minutes, or check: https://github.com/GloriousEggroll/proton-ge-custom/releases/latest" "$YELLOW"

		debug_log "Checking if version already installed in: $compat_dir_param"
		# Check if we already have this version installed (only if compat_dir is provided)
		if [[ -n "$compat_dir_param" && -d "$compat_dir_param/$version" ]]; then
			log "$version is already installed, nothing to do" "$GREEN"
			exit 0
		else
			log "Assets not available for download yet, exiting" "$RED"
			exit 1
		fi
	fi

	log "Latest version: $version" "$NC"
	debug_log "Tarball URL: $tarball_url"
	debug_log "Checksum URL: $checksum_url"
	debug_log "get_latest_release function completed successfully"
}

# Function to download and verify
download_and_verify() {
	local tarball_name checksum_name
	tarball_name=$(basename "$tarball_url")
	checksum_name=$(basename "$checksum_url")

	log "Downloading $tarball_name..." "$NC"
	debug_log "Download location: $TMP_DIR/$tarball_name"

	if command -v wget >/dev/null 2>&1; then
		debug_log "Using wget for download"
		wget -q --show-progress -O "$TMP_DIR/$tarball_name" "$tarball_url" || {
			log "Error: Download failed with wget" "$RED"
					if [[ "$DEBUG" -eq 1 ]]; then
						wget -O "$TMP_DIR/$tarball_name" "$tarball_url"
					fi
					exit 1
				}
				wget -q -O "$TMP_DIR/$checksum_name" "$checksum_url" || {
					log "Error: Checksum download failed with wget" "$RED"
									exit 1
								}
							else
								debug_log "Using curl for download"
								curl -s -L "$tarball_url" -o "$TMP_DIR/$tarball_name" || {
									log "Error: Download failed with curl" "$RED"
																	if [[ "$DEBUG" -eq 1 ]]; then
																		curl -v -L "$tarball_url" -o "$TMP_DIR/$tarball_name"
																	fi
																	exit 1
																}
																curl -s -L "$checksum_url" -o "$TMP_DIR/$checksum_name" || {
																	log "Error: Checksum download failed with curl" "$RED"
																																	exit 1
																																}
	fi

	if [[ ! -s "$TMP_DIR/$tarball_name" ]]; then
		log "Error: Downloaded tarball is empty or not found at $TMP_DIR/$tarball_name" "$RED"
		exit 1
	fi

	if [[ ! -s "$TMP_DIR/$checksum_name" ]]; then
		log "Error: Downloaded checksum file is empty or not found at $TMP_DIR/$checksum_name" "$RED"
		exit 1
	fi

	log "Verifying checksum..." "$NC"
	cd "$TMP_DIR"
	debug_log "Checksum file content: $(cat "$checksum_name")"
	debug_log "Calculated SHA512: $(sha512sum "$tarball_name")"

	if sha512sum -c "$checksum_name" >/dev/null 2>&1; then
		log "Checksum verification passed" "$GREEN"
	else
		log "Error: Checksum verification failed" "$RED"
		debug_log "Expected vs actual:"
		if [[ "$DEBUG" -eq 1 ]]; then
			sha512sum -c "$checksum_name" || true
		fi
		exit 1
	fi

	debug_log "Tarball exists after verification: $(ls -lh "$TMP_DIR/$tarball_name" 2>/dev/null || echo 'Not found')"
	echo "$tarball_name"
}

# Function to install as the target user
install_ge_proton() {
	local user="$1" target_dir="$2" tarball_name="$3" version="$4"
	local install_path="$target_dir/$version"

	if [[ -d "$install_path" ]]; then
		log "$version already installed at $install_path" "$NC"
		return 0
	fi

	debug_log "Creating target directory: $target_dir"
	mkdir -p "$target_dir" 2>/dev/null || {
		log "Error: Cannot create $target_dir" "$RED"
			exit 1
		}

		local tarball_path="$TMP_DIR/$tarball_name"
		debug_log "Checking tarball before extraction: $tarball_path"
		debug_log "Tarball details: $(ls -lh "$tarball_path" 2>/dev/null || echo 'Not found')"
		if [[ ! -s "$tarball_path" ]]; then
			log "Error: Tarball not found or empty at $tarball_path" "$RED"
			exit 1
		fi

		local tarball_size
		tarball_size=$(stat -c%s "$tarball_path" 2>/dev/null ||
			stat -f%z "$tarball_path" 2>/dev/null ||
			wc -c < "$tarball_path")
					debug_log "Tarball size: $tarball_size bytes"

					if [[ "$tarball_size" -lt 1000000 ]]; then
						log "Warning: Tarball size ($tarball_size bytes) seems unusually small" "$YELLOW"
					fi

					log "Extracting to $install_path as user $user..." "$NC"
					debug_log "Tarball path: $tarball_path"
					debug_log "Extract command: tar -xzf $tarball_path -C $target_dir"

					debug_log "Testing tarball integrity"
					tar -tzf "$tarball_path" >/dev/null 2>&1 || {
						log "Error: Tarball integrity check failed" "$RED"
											debug_log "Trying with verbose output: tar -tvzf $tarball_path"
											if [[ "$DEBUG" -eq 1 ]]; then
												tar -tvzf "$tarball_path" || true
											fi
											exit 1
										}

										if [[ "$user" != "root" && "$EUID" -eq 0 ]]; then
											debug_log "Extracting as user $user using sudo"
											local extract_script="$TMP_DIR/extract.sh"
											echo "#!/bin/bash" > "$extract_script"
											echo "cd '$TMP_DIR' && tar -xzf '$tarball_name' -C '$target_dir'" >> "$extract_script"
											chmod +x "$extract_script"

											local extract_output
											extract_output=$(sudo -u "$user" "$extract_script" 2>&1) || {
												log "Error: Extraction failed as user $user" "$RED"
																							debug_log "Extraction output: $extract_output"
																							exit 1
																						}

																						chown -R "$user:$user" "$install_path" 2>/dev/null || {
																							log "Warning: Failed to set ownership of $install_path to $user" "$RED"
																						}
																					else
																						debug_log "Extracting directly"
																						local extract_output
																						extract_output=$(tar -xzf "$tarball_path" -C "$target_dir" 2>&1) || {
																							log "Error: Extraction failed" "$RED"
																																													debug_log "Extraction output: $extract_output"
																																													exit 1
																																												}
										fi

										if [[ ! -d "$install_path" ]]; then
											log "Error: Installation directory not created after extraction" "$RED"
											debug_log "Target directory contents: $(ls -la "$target_dir")"
											exit 1
										fi

										local file_count
										file_count=$(find "$install_path" -type f | wc -l)
										debug_log "Files extracted: $file_count"
										debug_log "Extracted files (first 10): $(find "$install_path" -type f | head -n 10)"

										if [[ "$file_count" -lt "$MIN_FILES" ]]; then
											log "Warning: Extraction produced fewer files than expected ($file_count < $MIN_FILES)" "$YELLOW"
										fi

										log "$version installed successfully!" "$GREEN"
										log "==> Note: Steam requires a restart to detect $version." "$GREEN"
										log "In Steam: Steam > Settings > Compatibility > Set 'Default compatibility tool' to '$version'." "$GREEN"
										return 0
									}

# Function to clean up old GE-Proton versions
cleanup_old_versions() {
	local user="$1" target_dir="$2" latest_version="$3"
	local versions_to_keep=2

	log "Cleaning up old GE-Proton versions..." "$NC"
	local versions
	# Use find to list directories matching GE-Proton*, sort by version, and take the oldest ones
	versions=$(find "$target_dir" -maxdepth 1 -type d -name 'GE-Proton*' 2>/dev/null | sort -V | head -n -$versions_to_keep)

	if [[ -z "$versions" ]]; then
		log "No old versions to clean up." "$NC"
		return
	fi

	for old_version in $versions; do
		if [[ "$old_version" != "$target_dir/$latest_version" ]]; then
			log "Removing $old_version..." "$NC"
			if [[ "$user" != "root" && "$EUID" -eq 0 ]]; then
				sudo -u "$user" rm -rf "$old_version" 2>/dev/null || {
					log "Warning: Failed to remove $old_version" "$RED"
				}
			else
				rm -rf "$old_version" 2>/dev/null || {
					log "Warning: Failed to remove $old_version" "$RED"
				}
			fi
		fi
	done
	log "Cleanup complete." "$NC"
}

# Check for flags
FORCE_ROOT=0
for arg in "$@"; do
	if [[ "$arg" == "--force-root" ]]; then
		FORCE_ROOT=1
	elif [[ "$arg" == "--debug" ]]; then
		DEBUG=1
	fi
done

# Print system info in debug mode
if [[ "$DEBUG" -eq 1 ]]; then
	debug_log "System info: $(uname -a)"
	debug_log "Current user: $(whoami)"
	debug_log "EUID: $EUID"
	if [[ -v SUDO_USER ]]; then
		debug_log "SUDO_USER: $SUDO_USER"
	fi
fi

# Main execution
log "Checking for GE-Proton updates..." "$NC"

EFFECTIVE_USER=$(get_effective_user)
debug_log "Effective user: $EFFECTIVE_USER"

# Infer the target user, passing GE_PROTON_TARGET only if set, otherwise an empty string
TARGET_USER=$(infer_target_user "${GE_PROTON_TARGET:-}" "$EFFECTIVE_USER")
debug_log "Target user for installation: $TARGET_USER"

TARGET_SET=0
if [[ -v GE_PROTON_TARGET && -n "${GE_PROTON_TARGET}" ]]; then
	if [[ -d "$GE_PROTON_TARGET" || -w "$(dirname "$GE_PROTON_TARGET")" ]]; then
		COMPAT_DIR="$GE_PROTON_TARGET"
		TARGET_SET=1
		log "Using overridden Steam directory: $COMPAT_DIR" "$NC"
	else
		# If running as root, try to fix permissions or error out
		if [[ "$EUID" -eq 0 ]]; then
			if [[ "$TARGET_USER" != "root" ]]; then
				sudo -u "$TARGET_USER" mkdir -p "$GE_PROTON_TARGET" 2>/dev/null || {
					log "Error: GE_PROTON_TARGET ($GE_PROTON_TARGET) is invalid or unwritable even as $TARGET_USER" "$RED"
									exit 1
								}
								COMPAT_DIR="$GE_PROTON_TARGET"
								TARGET_SET=1
								log "Created and using overridden Steam directory: $COMPAT_DIR" "$NC"
							else
								log "Error: GE_PROTON_TARGET ($GE_PROTON_TARGET) is invalid or unwritable for root" "$RED"
								exit 1
			fi
		else
			log "Error: GE_PROTON_TARGET ($GE_PROTON_TARGET) is invalid or unwritable" "$RED"
			exit 1
		fi
	fi
fi

if [[ "$TARGET_SET" -eq 0 && "$EFFECTIVE_USER" == "root" && "$EUID" -eq 0 && ! -v SUDO_USER ]]; then
	if [[ "$FORCE_ROOT" -eq 1 ]]; then
		log "Installing to root's Steam dir with --force-root" "$NC"
	else
		log "Skipping GE-Proton update: Running as root without sudo user, --force-root, or valid GE_PROTON_TARGET" "$RED"
		exit 0
	fi
fi

if [[ "$TARGET_SET" -eq 0 ]]; then
	COMPAT_DIR=$(find_steam_dir "$TARGET_USER")
	log "Using Steam directory: $COMPAT_DIR" "$NC"
	debug_log "Target directory access check: $(ls -la "$COMPAT_DIR" 2>&1 || echo "Cannot access")"
fi

# Ensure the target directory is owned by the target user if running as root
if [[ "$EUID" -eq 0 && "$TARGET_USER" != "root" ]]; then
	chown "$TARGET_USER:$TARGET_USER" "$COMPAT_DIR" 2>/dev/null || {
		log "Warning: Failed to set ownership of $COMPAT_DIR to $TARGET_USER" "$RED"
	}
fi

TMP_DIR=$(make_secure_temp)
debug_log "Using temp directory: $TMP_DIR"

if [[ "$EUID" -eq 0 && "$TARGET_USER" != "root" ]]; then
	debug_log "Setting permissions on temp directory for $TARGET_USER"
	chown "$TARGET_USER:$TARGET_USER" "$TMP_DIR" || {
		log "Warning: Failed to set ownership of temp directory to $TARGET_USER" "$RED"
			debug_log "Current temp dir permissions: $(ls -la "$TMP_DIR")"
		}
		chmod 700 "$TMP_DIR" || {
			log "Warning: Failed to set permissions on temp directory" "$RED"
		}
fi

trap 'rm -rf "$TMP_DIR" && debug_log "Cleanup: Removed temp directory" || log "Warning: Failed to clean up $TMP_DIR" "$RED"' EXIT

get_latest_release "$COMPAT_DIR"

if [[ -d "$COMPAT_DIR/$version" ]]; then
	log "$version already installed at $COMPAT_DIR/$version" "$NC"
	INSTALL_NEEDED=0
else
	INSTALL_NEEDED=1
	debug_log "Installation needed: Latest version not found in target directory"
fi

if [[ "$INSTALL_NEEDED" -eq 1 ]]; then
	tarball_name=$(download_and_verify)
	debug_log "Tarball name returned: $tarball_name"
	debug_log "Full tarball path: $TMP_DIR/$tarball_name"
	debug_log "Tarball check before install: $(ls -lh "$TMP_DIR/$tarball_name" 2>/dev/null || echo 'Not found')"
	if [[ "$tarball_name" =~ ^Downloading ]]; then
		log "Error: Invalid tarball name detected: $tarball_name" "$RED"
		exit 1
	fi
	install_ge_proton "$TARGET_USER" "$COMPAT_DIR" "$tarball_name" "$version"
else
	log "No installation needed." "$NC"
fi

cleanup_old_versions "$TARGET_USER" "$COMPAT_DIR" "$version"

log "Done!" "$NC"

# exit 0
