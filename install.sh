#!/bin/bash

set -e

# Dependencies required
deps=(gnome-screenshot tesseract wl-clipboard brightnessctl notify-send)

echo "Checking and installing dependencies..."
for dep in "${deps[@]}"; do
  if ! command -v "$dep" &>/dev/null; then
    echo "Installing $dep..."
    sudo pacman -S --needed --noconfirm "$dep"
  else
    echo "$dep is already installed."
  fi
done

# Install OCR script
INSTALL_PATH="$HOME/.local/bin"
mkdir -p "$INSTALL_PATH"

echo "Installing OCR script to $INSTALL_PATH/ocr-shot.sh"
cp ./ocr-shot.sh "$INSTALL_PATH/ocr-shot.sh"
chmod +x "$INSTALL_PATH/ocr-shot.sh"

# Setup GNOME keybinding
# Use gsettings to create a custom shortcut "OCR Screenshot"
echo "Setting up GNOME keyboard shortcut..."

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_KEY="custom-keybindings"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ocr-shot/"

# Get existing custom keybindings list
existing=$(gsettings get "$SCHEMA" custom-keybindings)
if [[ $existing == "@as []" ]]; then
  new_bindings="['$CUSTOM_PATH']"
else
  # Append if not present
  if [[ $existing != *"$CUSTOM_PATH"* ]]; then
    existing=${existing%]*}
    new_bindings="${existing}, '$CUSTOM_PATH']"
  else
    new_bindings=$existing
  fi
fi

gsettings set "$SCHEMA" custom-keybindings "$new_bindings"

# Set keybinding details
gsettings set "$SCHEMA.custom-keybinding:$CUSTOM_PATH" name "OCR Screenshot"
gsettings set "$SCHEMA.custom-keybinding:$CUSTOM_PATH" command "$INSTALL_PATH/ocr-shot.sh"
gsettings set "$SCHEMA.custom-keybinding:$CUSTOM_PATH" binding "<Super>o"

echo "Installation complete!"
echo "Press Super+O to run the OCR screenshot tool."
