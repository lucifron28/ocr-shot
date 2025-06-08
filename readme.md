# OCR-Shot: Quick OCR Screenshot Tool for GNOME on Wayland

## Overview

**OCR-Shot** is a lightweight command-line tool designed for GNOME on Wayland that lets you quickly capture a selected screen area and extract text from it using OCR (Optical Character Recognition). The recognized text is automatically copied to your clipboard for easy pasting.

- Uses GNOME’s native screenshot tool (`gnome-screenshot -a`) for selection (Wayland-compatible)
- Performs OCR with Tesseract supporting English + Filipino (`eng+fil`)
- Displays desktop notifications on success/failure
- Optionally dims the screen briefly during selection for better focus
- Integrates with GNOME via a customizable keyboard shortcut (default: `Super + O`)

---

## Features

- Simple, no-frills shell script (`ocr-shot.sh`)
- One-step installer script (`install.sh`) to setup dependencies and keybinding
- Runs on Arch Linux (GNOME + Wayland)
- Clipboard integration with `wl-clipboard`
- Prevents multiple instances from running simultaneously

---

## Requirements

- Arch Linux (or Arch-based distro)
- GNOME desktop running on Wayland session
- Installed packages:
  - `gnome-screenshot`
  - `tesseract` (with Filipino language support)
  - `wl-clipboard`
  - `brightnessctl` (optional, for screen dimming)
  - `libnotify` (for `notify-send`)

---

## Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/lucifron28/ocr-shot.git
   cd ocr-shot
   ```

2. Run the installation script (you may be asked for your sudo password):

   ```bash
   ./install.sh
   ```

   This will:

   - Check and install missing dependencies
   - Copy the OCR script to `~/.local/bin/ocr-shot.sh`
   - Make it executable
   - Setup GNOME keyboard shortcut `Super + O` to launch OCR-Shot

---

## Usage

- Press **Super + O** (Windows key + O) to start a screen selection.
- Select the region you want to OCR.
- OCR-Shot will extract text and copy it to your clipboard.
- A notification will inform you of success or failure.

You can then paste (`Ctrl + V`) the extracted text anywhere.

---

## Customization

- Change the keyboard shortcut:

  Edit the `install.sh` and modify the line:

  ```bash
  gsettings set "$SCHEMA.custom-keybinding:$CUSTOM_PATH" binding "<Super>o"
  ```

  Replace `<Super>o` with your preferred keybinding, e.g., `<Ctrl><Alt>s`.

- Change OCR languages:

  The script uses `tesseract` with `-l eng+fil` by default. You can add/remove languages by editing `ocr-shot.sh`:

  ```bash
  tesseract "$FILE" - -l eng+fil
  ```

---

## Troubleshooting

- **No text detected**: Try selecting a clearer screenshot or check if Tesseract language packs are installed (`pacman -Ss tesseract`).

- **Brightness dimming not working**:
  - Make sure `brightnessctl` is installed and your user has permission to run it without a password.
  - Configure sudoers for `brightnessctl` (run `sudo visudo` and add):
    ```
    yourusername ALL=(ALL) NOPASSWD: /usr/bin/brightnessctl
    ```
  - If you don’t want dimming, you can comment out brightness-related lines in `ocr-shot.sh`.

- **Script says "OCR Already Running"**: You probably pressed the shortcut twice fast. Wait a moment and try again.

- **Keybinding does not work**:
  - Verify you are running GNOME on Wayland.
  - Check if the custom keybinding exists via:
    ```bash
    gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings
    ```
  - You can remove the binding with:
    ```bash
    gsettings reset-recursively org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ocr-shot/
    ```

---

## License

MIT License — feel free to modify and redistribute.

---

## Acknowledgments

- [grim](https://github.com/emersion/grim) and [slurp](https://github.com/emersion/slurp) for Wayland screenshots
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) project
- GNOME developers for the screenshot and keybinding APIs

---

## Contributions

Feel free to open issues or submit pull requests to improve the script or add features.
