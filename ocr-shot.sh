#!/bin/bash

LOCKFILE="/tmp/.ocr-shot.lock"
FILE=$(mktemp --suffix=".png")

cleanup() {
  # Restore brightness if we changed it
  if [[ -f "/tmp/.ocr_brightness_backup" ]]; then
    orig_brightness=$(cat /tmp/.ocr_brightness_backup)
    sudo brightnessctl set "$orig_brightness" >/dev/null 2>&1
    rm /tmp/.ocr_brightness_backup
  fi
  [[ -f "$LOCKFILE" ]] && rm -f "$LOCKFILE"
  [[ -f "$FILE" ]] && rm -f "$FILE"
}
trap cleanup EXIT

if [[ -f "$LOCKFILE" ]]; then
  notify-send "⚠️ OCR Already Running"
  exit 1
fi
touch "$LOCKFILE"

# Dim screen by reducing brightness (optional; requires sudo rights for brightnessctl)
if command -v brightnessctl &>/dev/null; then
  orig_brightness=$(brightnessctl get)
  echo "$orig_brightness" >/tmp/.ocr_brightness_backup
  # Reduce brightness by 50%
  half_brightness=$((orig_brightness / 2))
  sudo brightnessctl set "$half_brightness" >/dev/null 2>&1
fi

# Allow time for user to prepare
sleep 0.2

# Use GNOME screenshot selection
gnome-screenshot -a -f "$FILE"

# Restore brightness after screenshot
if [[ -f "/tmp/.ocr_brightness_backup" ]]; then
  orig_brightness=$(cat /tmp/.ocr_brightness_backup)
  sudo brightnessctl set "$orig_brightness" >/dev/null 2>&1
  rm /tmp/.ocr_brightness_backup
fi

if [[ ! -s "$FILE" ]]; then
  notify-send "❌ OCR Failed" "Screenshot was not captured."
  exit 1
fi

TEXT=$(tesseract "$FILE" - -l eng+fil 2>/dev/null)

if [[ -n "$TEXT" ]]; then
  echo "$TEXT" | wl-copy
  notify-send "✅ OCR Complete" "Text copied to clipboard."
else
  notify-send "⚠️ OCR Empty" "No text detected."
fi
