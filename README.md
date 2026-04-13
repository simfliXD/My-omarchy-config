# Omarchy-config ( THIS README WAS MOSTLY AI GENERATED)

A collection of installer and configuration scripts for Omarchy Linux setups, focused on gaming, utilities, themes, and system components.

## Overview

This repository is a shell-script-based installer toolkit for setting up and configuring a Linux desktop environment with Omarchy-specific tweaks. It includes:

- GPU and gaming setup
- Wine, Bottles, and Steam compatibility
- Spotify and nice-to-have apps
- Theme management and Hyprland overrides
- Shared logging and install helpers

## Getting Started

From the repository root, run the installer script you want:

```bash
./master-install.sh
```

Or run a targeted installer:

```bashAdd
./ai-install.sh
./essentials-install.sh
./gaming-install.sh
./nicetohave-install.sh
./remove-shit.sh
```

> Run these scripts from the repo root so relative paths resolve correctly.

## Recommended Workflow

1. Clone or sync this repository to your local machine.
2. Review the installer scripts and make any customizations you want.
3. Run the installer from the repo root.

## Top-Level Scripts

- `master-install.sh` — orchestrates the full installation flow.
- `ai-install.sh` — installs AI-related tools and packages.
- `essentials-install.sh` — installs core utilities and dependencies.
- `gaming-install.sh` — installs gaming-related components and tools.
- `nicetohave-install.sh` — installs optional nice-to-have packages.
- `remove-shit.sh` — removes unwanted packages or cleanup items.

## Script Structure

- `install-scripts/common.sh` — shared logging helpers and standard output formatting.
- `install-scripts/gaming/` — gaming-focused installers including gamemode, mangohud, GE Proton, and more.
- `install-scripts/nice-to-have/` — optional packages such as Spotify alternatives, theme extensions, and TLP.
- `install-scripts/webapps/` — webapp installers and desktop shortcuts.
- `install-scripts/` — reusable installers for packages like VS Code, Tailscale, and Wine. Includes a GPU-setup file that detects the gpu and installs apropriate packages.
- `hypr/` — Hyprland overrides and default variable configuration.

## Notes

- Omarchy must be setup before installation.
- Most scripts are written for `bash` and use `set -euo pipefail` for safer execution.
- Install scripts asume an arch installation using yay and pacman as package helpers.
- User service commands such as `systemctl --user` are handled carefully when scripts are run from an elevated install context.

## Contributing

- Add or update installer scripts in `install-scripts/`.
- Keep logging consistent by using `install-scripts/common.sh` helpers: `log_info`, `log_success`, `log_warn`, `log_error`, and `section`.
- Validate path references for top-level scripts using `SCRIPT_DIR` or repo-relative logic.

## License

This repository does not include a license file. Use and modify at your own discretion.
