#!/usr/bin/env bash
# =============================================================
# Copy with RAW — macOS Installer
# =============================================================
set -e

INSTALL_DIR="/usr/local/lib/CopyWithRAW"
SERVICE_DIR="$HOME/Library/Services"
CONFIG_DIR="$HOME/.config/CopyWithRAW"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Copy with RAW — macOS Installer ==="
echo

# --- Check Python 3 ---
if ! command -v python3 &>/dev/null; then
    echo "ERROR: Python 3 is required. Install it from https://www.python.org/downloads/"
    exit 1
fi

# --- Install Python script ---
echo "Installing core script to $INSTALL_DIR ..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$SCRIPT_DIR/../src/copy_with_raw.py" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/copy_with_raw.py"

# --- Ask for WL destination ---
echo
read -rp "Enter your Wildlife destination folder (e.g. /Volumes/Photos/Selected/Wildlife): " WL_DEST
read -rp "Enter default folder picker location (e.g. /Volumes/Photos/Selected): " PICKER_DEST

# --- Save config ---
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/config.ini" <<EOF
[Paths]
WLDestination = $WL_DEST
DefaultPickerFolder = $PICKER_DEST
EOF
echo "Config saved to $CONFIG_DIR/config.ini"

# --- Install Automator Quick Action (Finder right-click) ---
echo
echo "Installing Finder Quick Action ..."
mkdir -p "$SERVICE_DIR"
cp -R "$SCRIPT_DIR/../src/macos/CopyWithRAW.workflow" "$SERVICE_DIR/"

# Reload services
/System/Library/CoreServices/pbs -update 2>/dev/null || true

echo
echo "=== Installation complete! ==="
echo
echo "How to use:"
echo "  1. Select JPEG or RAW files in Finder"
echo "  2. Right-click → Quick Actions → 'Copy with RAW'"
echo "     (or Services menu if Quick Actions is not shown)"
echo
echo "To use WL shortcuts, go to:"
echo "  System Settings → Privacy & Security → Extensions → Finder Extensions"
echo "  and make sure 'Copy with RAW' is enabled."
