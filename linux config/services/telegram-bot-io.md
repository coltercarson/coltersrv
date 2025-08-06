## Instructions for scripts used to process telegram bot downloads:

Auto-Extract & Copy Watcher

Script: auto_extract_downloads.sh
Purpose: Watches a downloads folder for new archives, extracts each into a same-name folder, then copies the extracted folder to a target inbox for further processing (e.g., beets).

    Watch folder (default): /DATA/AppData/big-bear-jlesage-firefox/config/downloads

    Target folder: /mnt/media_1tb/music_temp/telegram_bot/beets-flask-inbox

    Unit file: ~/.config/systemd/user/auto-extract-downloads.service (user service)

## Features

    Supported archives: .zip, .tar, .tar.gz/.tgz, .tar.bz2/.tbz2, .tar.xz/.txz, .7z, .rar

    Extracts to WATCH_DIR/<archive_stem> (no “_extracted” suffix)

    Copies extracted folder to the target inbox automatically

    Ignores temp/incomplete files (.part, .crdownload, .tmp)

    Idempotent start-up pass (processes any pre-existing archives)

    Logs to journalctl (user)

## Requirements

Install once (Debian/Ubuntu shown):

    sudo apt update
    sudo apt install -y inotify-tools unzip p7zip-full unrar tar

    # (RHEL/Fedora: use dnf and p7zip p7zip-plugins.)

## Installation
### Place the script:
sudo nano /usr/local/bin/auto_extract_downloads.sh :

    #!/usr/bin/env bash
    # Auto-extract any archives placed in WATCH_DIR.
    # After extraction, copy the extracted folder to a target inbox.
    
    set -euo pipefail
    
    WATCH_DIR="${WATCH_DIR:-/DATA/AppData/big-bear-jlesage-firefox/config/downloads}"
    TARGET_DIR="/mnt/media_1tb/music_temp/telegram_bot/beets-flask-inbox"
    
    log(){ logger -t auto-extract "$*"; printf '%s\n' "$*"; }
    
    stem_from(){
      local base="$1" lower="${1,,}"
      for ext in ".tar.gz" ".tar.bz2" ".tar.xz" ".tgz" ".tbz2" ".txz" ".zip" ".7z" ".rar" ".tar"; do
        if [[ "$lower" == *"$ext" ]]; then
          printf '%s' "${base:0:${#base}-${#ext}}"
          return 0
        fi
      done
      printf '%s' "${base%.*}"
    }
    
    extract_one(){
      local f="$1"
      [[ -f "$f" ]] || { log "Skip (not a regular file): $f"; return 0; }
    
      local base; base="$(basename "$f")"
      local stem; stem="$(stem_from "$base")"
      local outdir="$WATCH_DIR/$stem"
    
      mkdir -p "$outdir"
    
      shopt -s nocasematch
      case "$base" in
        *.zip)        unzip -n -- "$f" -d "$outdir" ;;
        *.tar.gz|*.tgz)  tar -xzf "$f" -C "$outdir" ;;
        *.tar.bz2|*.tbz2) tar -xjf "$f" -C "$outdir" ;;
        *.tar.xz|*.txz)   tar -xJf "$f" -C "$outdir" ;;
        *.7z)         7z x -y -aos -o"$outdir" -- "$f" ;;
        *.rar)        unrar x -o- -- "$f" "$outdir"/ ;;
        *.tar)        tar -xf "$f" -C "$outdir" ;;
        *)            log "Skip (unknown type): $f"; shopt -u nocasematch; return 0 ;;
      esac
      shopt -u nocasematch
    
      log "Extracted: $base -> $outdir"
    
      # Copy extracted folder to target directory
      if [[ -d "$outdir" ]]; then
        cp -r "$outdir" "$TARGET_DIR"/
        log "Copied $outdir -> $TARGET_DIR"
      else
        log "Warning: $outdir not found after extraction"
      fi
    
      # Optional: remove archive after extraction
      rm -f -- "$f"
    }
    
    # Process any existing archives on start
    find "$WATCH_DIR" -maxdepth 1 -type f \
      \( -iname '*.zip' -o -iname '*.tar.gz' -o -iname '*.tgz' -o -iname '*.tar.bz2' \
         -o -iname '*.tbz2' -o -iname '*.tar.xz' -o -iname '*.txz' -o -iname '*.tar' \
         -o -iname '*.7z' -o -iname '*.rar' \) \
      -print0 | while IFS= read -r -d '' f; do extract_one "$f"; done
    
    # Watch for new/finished files
    inotifywait -m -e close_write -e moved_to --format '%w%f' "$WATCH_DIR" \
      --exclude '(\.part|\.crdownload|\.tmp)$' | while read -r f; do
        if [[ -f "$f" ]]; then
          local s1 s2
          s1=$(stat -c%s "$f" 2>/dev/null || echo 0)
          sleep 1
          s2=$(stat -c%s "$f" 2>/dev/null || echo 0)
          if [[ "$s1" -eq "$s2" ]]; then
            extract_one "$f"
          else
            sleep 2
            s2=$(stat -c%s "$f" 2>/dev/null || echo 0)
            [[ "$s1" -eq "$s2" ]] && extract_one "$f" || log "Skip (still changing): $f"
          fi
        fi
      done

sudo chmod 0755 /usr/local/bin/auto_extract_downloads.sh

### If created on Windows, normalise line endings:
    sudo sed -i 's/\r$//' /usr/local/bin/auto_extract_downloads.sh

### Create the user systemd unit
    mkdir -p ~/.config/systemd/user
    tee ~/.config/systemd/user/auto-extract-downloads.service >/dev/null <<'EOF'
    [Unit]
    Description=Automatically extract archives dropped into the Firefox downloads inbox
    
    [Service]
    # If /usr/local is mounted noexec, call via /bin/bash instead:
    ExecStart=/usr/local/bin/auto_extract_downloads.sh
    Restart=always
    RestartSec=2
    # Prefer setting WATCH_DIR here so script default can differ by host:
    Environment=WATCH_DIR=/DATA/AppData/big-bear-jlesage-firefox/config/downloads
    Nice=10

    [Install]
    WantedBy=default.target
    EOF

### Enable & start
    systemctl --user daemon-reload
    systemctl --user enable --now auto-extract-downloads.service

### Restart (if needed)
    systemctl --user daemon-reload
    systemctl --user restart auto-extract-downloads.service
    systemctl --user status  auto-extract-downloads.service --no-pager

### Optional on headless servers: keep user services running after logout
    sudo loginctl enable-linger "$USER"

## Usage

    Drop any supported archive into the watch folder.

    The script extracts into WATCH_DIR/<archive_stem> and copies that folder into the target folder.

    Watch progress:

        journalctl --user -u auto-extract-downloads.service -f

### Quick test

    cd /DATA/AppData/big-bear-jlesage-firefox/config/downloads
    printf 'hello\n' > sample.txt
    zip test.zip sample.txt
    # Expect: extracted ./test/ and copied to /mnt/media_1tb/music_temp/telegram_bot/beets-flask-inbox/test/

## Customisation

### Change the watch folder
    # Edit the unit file (preferred):

    sed -i 's|^Environment=WATCH_DIR=.*|Environment=WATCH_DIR=/new/watch/path|' \
      ~/.config/systemd/user/auto-extract-downloads.service
    systemctl --user daemon-reload && systemctl --user restart auto-extract-downloads.service
    
    Or set a new default in the script (WATCH_DIR=...).
    
    Change the target folder
    Edit TARGET_DIR="..." near the top of the script and restart the service.
    
    Move instead of copy
    Replace the cp -r line with:
    
    mv -n "$outdir" "$TARGET_DIR"/
    
    (-n avoids overwriting; use with care if multiple archives share the same stem.)
    
    Auto-delete archives after extraction
    Uncomment the line at the end of extract_one():
    
    # rm -f -- "$f"

## Troubleshooting

Permission denied (203/EXEC)
Ensure the script is executable and has Unix line endings:

    sudo chmod 0755 /usr/local/bin/auto_extract_downloads.sh
    sudo sed -i 's/\r$//' /usr/local/bin/auto_extract_downloads.sh

noexec mount for /usr/local
Run via bash or move script to home:

    Edit unit:
    ExecStart=/bin/bash /usr/local/bin/auto_extract_downloads.sh

Or move:

    mkdir -p ~/.local/bin
    sudo cp /usr/local/bin/auto_extract_downloads.sh ~/.local/bin/
    sudo chown "$USER":"$USER" ~/.local/bin/auto_extract_downloads.sh
    chmod 0755 ~/.local/bin/auto_extract_downloads.sh
    # then: ExecStart=/bin/bash /home/<user>/.local/bin/auto_extract_downloads.sh

## Selinux (Enforcing)

getenforce
sudo restorecon -v /usr/local/bin/auto_extract_downloads.sh

Service status & logs

systemctl --user status auto-extract-downloads.service
journalctl --user -u auto-extract-downloads.service -f

Update script

    sudo nano /usr/local/bin/auto_extract_downloads.sh
    systemctl --user restart auto-extract-downloads.service

## Notes & Conventions

    Script filename uses underscores (auto_extract_downloads.sh); the service uses dashes (auto-extract-downloads.service) to match common Linux conventions.

    Extract folder equals the archive’s stem (e.g., album.tgz → album/).

    The watcher excludes files ending with .part, .crdownload, .tmp to avoid racing incomplete downloads.

    The script is conservative with overwrites: unzip -n and 7z ... -aos. If you want “always overwrite”, adjust tool flags accordingly.

## Uninstall

    systemctl --user disable --now auto-extract-downloads.service
    rm -f ~/.config/systemd/user/auto-extract-downloads.service
    systemctl --user daemon-reload
    sudo rm -f /usr/local/bin/auto_extract_downloads.sh

Last updated: 2025-08-03
If you change paths on a new host, prefer updating the unit’s Environment=WATCH_DIR=... over editing the script—keeps the script portable across machines.
