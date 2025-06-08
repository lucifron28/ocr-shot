#!/bin/bash

# Required packages
DEPS=(gnome-screenshot tesseract wl-clipboard libnotify)

# Check and install missing packages
for pkg in "${DEPS[@]}"; do
  if ! command -v "${pkg%%-*}" &>/dev/null; then
    echo "[!] Missing: $pkg — installing..."
    sudo pacman -S --noconfirm "$pkg"
  fi
done

# Ensure tesseract language data for English and Filipino are installed
if ! ls /usr/share/tessdata/fil.traineddata &>/dev/null; then
  echo "[!] Missing tesseract-fil — installing..."
  sudo pacman -S --noconfirm tesseract-data-fil
fi

# Temporary file
FILE=$(mktemp --suffix=.png)

# Take screenshot
gnome-screenshot -a -f "$FILE"
if [[ ! -s "$FILE" ]]; then
  notify-send "❌ OCR Failed" "Screenshot was not taken properly."
  exit 1
fi

# OCR using English + Filipino
TEXT=$(tesseract "$FILE" - -l eng+fil 2>/dev/null)

# Copy to clipboard
echo "$TEXT" | wl-copy

# Show notification
if [[ -n "$TEXT" ]]; then
  notify-send "✅ OCR Complete" "Text copied to clipboard."
else
  notify-send "⚠️ OCR Warning" "No text detected or recognition failed."
fi
