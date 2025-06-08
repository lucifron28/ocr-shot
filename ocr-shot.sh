#!/bin/bash

LOCKFILE="/tmp/.ocr-shot.lock"
FILE=$(mktemp --suffix=.png)
OVERLAY_PID=

# Cleanup on exit
cleanup() {
  [[ -n "$OVERLAY_PID" ]] && kill "$OVERLAY_PID" &>/dev/null
  [[ -f "$LOCKFILE" ]] && rm -f "$LOCKFILE"
  [[ -f "$FILE" ]] && rm -f "$FILE"
}
trap cleanup EXIT

# Prevent multiple instances
if [[ -f "$LOCKFILE" ]]; then
  notify-send "⚠️ OCR Running" "An OCR process is already in progress."
  exit 1
fi
touch "$LOCKFILE"

# Required packages
DEPS=(gnome-screenshot tesseract wl-clipboard libnotify xrandr xdotool)

# Check and install missing dependencies
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

# Dim screen with a fullscreen transparent window
dim_screen() {
  (
    gnome-terminal --window --hide-menubar -- bash -c '
            sleep 0.2
            zenity --info --title="" --no-wrap --text="" --timeout=2 --width=1 --height=1 --display=:0
        ' &
  ) &
  disown
}

# Better overlay (requires ImageMagick and xrandr)
overlay_dim() {
  OVERLAY=$(mktemp --suffix=.png)
  RES=$(xrandr | grep '*' | awk '{print $1}')
  convert -size "$RES" xc:black -fill black -draw "color 0,0 reset" -alpha set -channel A -evaluate set 50% "$OVERLAY"
  feh --fullscreen --image-bg black --no-fehbg "$OVERLAY" &
  OVERLAY_PID=$!
  sleep 0.2
}

# Show dim screen
overlay_dim

# Take screenshot with GNOME tool
gnome-screenshot -a -f "$FILE"

# Hide overlay
[[ -n "$OVERLAY_PID" ]] && kill "$OVERLAY_PID" &>/dev/null

# Sanity check
if [[ ! -s "$FILE" ]]; then
  notify-send "❌ OCR Failed" "Screenshot not captured."
  exit 1
fi

# Perform OCR (English + Filipino)
TEXT=$(tesseract "$FILE" - -l eng+fil 2>/dev/null)

# Copy to clipboard
echo "$TEXT" | wl-copy

# Show final notification
if [[ -n "$TEXT" ]]; then
  notify-send "✅ OCR Done" "Text copied to clipboard."
else
  notify-send "⚠️ OCR Warning" "No text detected."
fi
