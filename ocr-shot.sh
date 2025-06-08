#!/bin/bash

LOCKFILE="/tmp/.ocr-shot.lock"
FILE=$(mktemp --suffix=.png)
OVERLAY_PID=

# Auto-clean
cleanup() {
  [[ -n "$OVERLAY_PID" ]] && kill "$OVERLAY_PID" &>/dev/null
  [[ -f "$LOCKFILE" ]] && rm -f "$LOCKFILE"
  [[ -f "$FILE" ]] && rm -f "$FILE"
}
trap cleanup EXIT

# Prevent multiple runs
if [[ -f "$LOCKFILE" ]]; then
  notify-send "⚠️ OCR Already Running"
  exit 1
fi
touch "$LOCKFILE"

# Screen dim with transparent overlay
RES=$(xrandr | grep '*' | awk '{print $1}')
OVERLAY=$(mktemp --suffix=.png)
convert -size "$RES" xc:black -alpha set -channel A -evaluate set 50% "$OVERLAY"
feh --fullscreen --image-bg black --no-fehbg "$OVERLAY" &
OVERLAY_PID=$!
sleep 0.2

# Screenshot selection
gnome-screenshot -a -f "$FILE"
[[ -n "$OVERLAY_PID" ]] && kill "$OVERLAY_PID" &>/dev/null

if [[ ! -s "$FILE" ]]; then
  notify-send "❌ OCR Failed" "Screenshot was not captured."
  exit 1
fi

# OCR: English + Filipino
TEXT=$(tesseract "$FILE" - -l eng+fil 2>/dev/null)
echo "$TEXT" | wl-copy

# Feedback
if [[ -n "$TEXT" ]]; then
  notify-send "✅ OCR Complete" "Text copied to clipboard."
else
  notify-send "⚠️ OCR Empty" "No text detected."
fi
