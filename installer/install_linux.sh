#!/usr/bin/env bash
# =============================================================
# Copy with RAW — Linux Installer (Nautilus / GNOME)
# =============================================================
set -e

INSTALL_DIR="/usr/local/lib/CopyWithRAW"
NAUTILUS_SCRIPTS="$HOME/.local/share/nautilus/scripts"
CONFIG_DIR="$HOME/.config/CopyWithRAW"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Copy with RAW — Linux Installer ==="
echo

# --- Check Python 3 ---
if ! command -v python3 &>/dev/null; then
    echo "ERROR: Python 3 is required. Install it with: sudo apt install python3"
    exit 1
fi

# --- Check tkinter ---
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "Installing python3-tk (required for GUI) ..."
    sudo apt-get install -y python3-tk 2>/dev/null || sudo dnf install -y python3-tkinter 2>/dev/null || true
fi

# --- Install Python script ---
echo "Installing core script to $INSTALL_DIR ..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$SCRIPT_DIR/../src/copy_with_raw.py" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/copy_with_raw.py"

# --- Ask for WL destination ---
echo
read -rp "Enter your Wildlife destination folder (e.g. /mnt/Photos/Selected/Wildlife): " WL_DEST
read -rp "Enter default folder picker location (e.g. /mnt/Photos/Selected): " PICKER_DEST

# --- Save config ---
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/config.ini" <<EOF
[Paths]
WLDestination = $WL_DEST
DefaultPickerFolder = $PICKER_DEST
EOF
echo "Config saved to $CONFIG_DIR/config.ini"

# --- Install Nautilus scripts ---
echo
echo "Installing Nautilus right-click scripts ..."
mkdir -p "$NAUTILUS_SCRIPTS"

# Copy with RAW (pick folder)
cat > "$NAUTILUS_SCRIPTS/Copy with RAW" <<'SCRIPT'
#!/usr/bin/env bash
IFS=$'\n' read -r -d '' -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" || true
python3 /usr/local/lib/CopyWithRAW/copy_with_raw.py "${files[@]}"
SCRIPT

# Copy to WL
cat > "$NAUTILUS_SCRIPTS/Copy to Selected WL" <<'SCRIPT'
#!/usr/bin/env bash
IFS=$'\n' read -r -d '' -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" || true
python3 /usr/local/lib/CopyWithRAW/copy_with_raw.py --dest "WL:" "${files[@]}"
SCRIPT

# Copy to WL (Auto folder)
cat > "$NAUTILUS_SCRIPTS/Copy to WL (Original Folder)" <<'SCRIPT'
#!/usr/bin/env bash
IFS=$'\n' read -r -d '' -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" || true
python3 /usr/local/lib/CopyWithRAW/copy_with_raw.py --dest "WL:" --auto-subfolder "${files[@]}"
SCRIPT

chmod +x "$NAUTILUS_SCRIPTS/Copy with RAW"
chmod +x "$NAUTILUS_SCRIPTS/Copy to Selected WL"
chmod +x "$NAUTILUS_SCRIPTS/Copy to WL (Original Folder)"

echo
echo "=== Installation complete! ==="
echo
echo "How to use (GNOME/Nautilus):"
echo "  1. Select JPEG or RAW files in the Files app"
echo "  2. Right-click → Scripts → choose an option"
echo
echo "If you use a different file manager:"
echo "  Dolphin (KDE): copy scripts to ~/.local/share/kservices5/ServiceMenus/"
echo "  Thunar (XFCE): configure via Edit → Configure custom actions"
