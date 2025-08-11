## Access Instructions

### 🔐 Login Details  
I’ll set up a user account for you with your name and password = 'password' — just ask/remind me:  
- **Username:** `yourname` (e.g., `colter`)  
- **Password:** `password`  (change this once you've logged in)

Alternatively, you can use the visitor account:  
- **Username:** `visitor`  
- **Password:** `visitor`  

---

### 🎬 Films / TV Series  
- **Web:** [https://coltersrv.ghoul-elnath.ts.net/](https://coltersrv.ghoul-elnath.ts.net/)  
- **iOS Apps:** Jellyfin, Swiftfin, Infuse (paid), Streamyfin  
- **Android Apps:** Jellyfin, Findroid  

---

### 🎵 Music  
- **Web:** [https://coltersrv.ghoul-elnath.ts.net:10000/](https://coltersrv.ghoul-elnath.ts.net:10000/)  
- **iOS Apps:** Amperfy (many others available — search *"Navidrome"*)  
- **Android Apps:** Symfonium (paid, highly recommended), Tempo?  

---

### 📚 Audiobooks  
- **Web:** [https://coltersrv.ghoul-elnath.ts.net:8443/](https://coltersrv.ghoul-elnath.ts.net:8443/)  
- **iOS Apps:** ShelfPlayer ($4.99), [Plappa](https://plappa.me/) (paid for downloads)
- **Android App:** Audiobookshelf  

_Let me know if you want anything added 🙂_

---

## 🧰 Software / Apps

### 🖥️ Operating System
- **CasaOS**

### 🐳 Docker Containers
- **Portainer** — container management UI  
- **Gluetun** (with AirVPN) — VPN tunnel  
- **Nicotine+** (`sirjmann92/nicotineplus-proper`) — Soulseek client
- **Calibre-web** — Ebook library  
- **Navidrome** — music streaming server  
- **qBittorrent** — torrent client  
- **Jellyfin** — media server  
- **Audiobookshelf** — audiobook/podcast server  
- **Beets Flask** — web interface for Beets  
- **Focalboard** — self-hosted Trello/Notion alternative  
- **MusicBrainz Picard** (`mikenye/picard`) — music tagger  
- **Immich** — self-hosted photo and video backup  

### 🧱 Bare Metal (Installed on Host)
- **Tailscale** — remote access / mesh VPN  
- **Docker** — container runtime  
- **Netdata** — real-time monitoring dashboard
- **Cockpit** — System admin

---

## 📁 Files & Config

- **Container configs:** `/DATA/AppData/{container_name}`  
  *Note: Some containers use Docker volumes instead.*
- **Misc documents:** `/DATA/documents`
- **Immich media storage:** `/DATA/Gallery/immich`

---

## Redeployment

---

### 1) Pre‑rebuild preparation (definitive checklist)

**Inventory & topology**

* [ ] Record hardware: CPU, GPU (GTX 970), RAM, NICs, disks (model/size/serial), and intended roles (OS vs data).
* [ ] Note BIOS/SATA/NVMe controller modes (AHCI/RAID), Secure Boot state, and boot order.
* [ ] Capture current hostname and addressing plan (static IP or DHCP reservation) and any local DNS entries (e.g., `coltersrv`).

**Data & configs**

* [ ] Back up `/DATA/AppData/` (all container configs).
* [ ] Back up content trees you care about:

  * `/DATA/media/movies`, `/DATA/media/tv`, `/DATA/media/music`
  * `/DATA/audiobooks`, `/DATA/podcasts`, `/DATA/books`
  * `/DATA/Gallery/immich`, `/DATA/torrents`, `/DATA/soulseek`, `/DATA/documents`
* [ ] Export named Docker volumes you plan to keep (if any).
* [ ] Export Immich database via `pg_dump` (or snapshot volume).

**Secrets & access**

* [ ] Gluetun VPN creds: AirVPN/WireGuard keys (or OpenVPN username/password + .ovpn files).
* [ ] Admin passwords/API keys for Jellyfin, Navidrome, Immich, etc.
* [ ] Tailscale auth method (web login or ephemeral/auth key) + whether MagicDNS is enabled.

**Compose & environment**

* [ ] Copy your `docker-compose.yml` and all `.env` files from `/DATA/AppData/` or git repo.
* [ ] Decide image tags to pin (e.g., Immich `:release`, Jellyfin LinuxServer `:latest` or a specific digest).

**Risk controls**

* [ ] Confirm a tested restore of at least one critical service (e.g., restore Immich DB into a test container).
* [ ] Verify backup storage integrity (checksum a few large files with `sha256sum`).

Handy one‑liners:

```bash
# AppData snapshot (local)
sudo rsync -aHAXv --delete /DATA/AppData/ /mnt/backup/AppData/

# Immich media + docs
sudo rsync -aHAXv --delete /DATA/Gallery/immich/ /mnt/backup/Gallery/immich/
sudo rsync -aHAXv --delete /DATA/documents/ /mnt/backup/documents/

# List volumes
docker volume ls
```

---

### 2) Install the operating system

Choose **Ubuntu Server LTS (22.04/24.04)** or the **CasaOS OS image**. During install:

* Create user **`colter5000`** (UID 1000 if possible) and set timezone **`Pacific/Auckland`**.
* Minimal package set is fine.

After first boot:

```bash
sudo apt update && sudo apt -y upgrade
sudo reboot
```

> **CasaOS install**: use the official installer from the CasaOS docs (intentionally not hard‑coded here so you can follow the current method). Run it **after** base updates.

---

### 3) Disks: identify, format (if needed), and mount at `/DATA`

Identify disks and UUIDs:

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
sudo blkid
```

Create filesystem (only if the disk is new/empty):

```bash
# DANGER: double‑check the device path!
sudo mkfs.ext4 -L DATA /dev/sdX
```

Create mountpoint and persistent fstab entry:

```bash
sudo mkdir -p /DATA
# Find UUID from blkid, then:
echo 'UUID=<YOUR-UUID>  /DATA  ext4  defaults,noatime  0  2' | sudo tee -a /etc/fstab
sudo mount -a
```

Create expected tree and set ownership:

```bash
sudo mkdir -p /DATA/AppData /DATA/documents /DATA/Gallery/immich
sudo chown -R 1000:1000 /DATA
```

Optional: **Netplan static IP** (if not using DHCP reservation). Create `/etc/netplan/01-net.yaml` based on your NIC (e.g., `enp3s0`):

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [192.168.1.1, 1.1.1.1]
```

Apply with `sudo netplan apply`.

---

### 4) Base packages & host services

Install common tools and Docker:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg git htop unzip jq
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker  # reload group membership
```

Tailscale (remote access):

```bash
sudo apt install -y tailscale
# Option A: interactive auth in browser
sudo tailscale up
# Option B: with an auth key (from admin panel)
# sudo tailscale up --authkey tskey-xxxxxxxxxxxxxxxx
```

Cockpit (optional):

```bash
sudo apt install -y cockpit
sudo systemctl enable --now cockpit.socket
```

UFW firewall:

```bash
sudo apt install -y ufw
sudo ufw allow OpenSSH
sudo ufw allow 9090/tcp   # Cockpit (optional)
sudo ufw allow 19999/tcp  # Netdata (optional)
sudo ufw enable
```

> **NVIDIA (optional for Jellyfin NVENC)**: After a successful boot, install the recommended driver (`ubuntu-drivers autoinstall`), remove any temporary `nomodeset` entry from GRUB, and consider the NVIDIA Container Toolkit if you want NVENC in containers.

---

### 5) Docker networks & environment

Create networks (idempotent):

```bash
docker network create media || true
docker network create proxy || true
```

Create `/DATA/AppData/.env` (example):

```ini
TZ=Pacific/Auckland
PUID=1000
PGID=1000
DATA_ROOT=/DATA
APPDATA=/DATA/AppData
# Gluetun / AirVPN (fill these if using WireGuard)
WIREGUARD_PRIVATE_KEY=
WIREGUARD_ADDRESSES=10.64.0.2/32
SERVER_COUNTRIES=New Zealand,Australia
# Immich
IMMICH_DB_PASSWORD=choose_a_strong_password
# Nicotine+
NIC_LOGIN=
NIC_PASS=
```

---

### 6) Restore backups onto the new host

```bash
# AppData, documents, photos (adjust source paths as needed)
sudo rsync -aHAXv /mnt/backup/AppData/ /DATA/AppData/
sudo rsync -aHAXv /mnt/backup/documents/ /DATA/documents/
sudo rsync -aHAXv /mnt/backup/Gallery/immich/ /DATA/Gallery/immich/
```

Restore named volumes (if used):

```bash
VOL=my_volume
docker volume create $VOL
cat $VOL.tar | docker run --rm -i -v $VOL:/v alpine sh -c 'cd /v && tar -xf -'
```

Immich DB restore (if you created a `pg_dump`):

```bash
# After Immich Postgres is up (see section 7), import the dump
docker cp immich.pgdump immich-postgres:/tmp/
docker exec -it immich-postgres \
  pg_restore -U postgres -d immich -c -v /tmp/immich.pgdump
```

---

### 7) Compose file and deployment

Place your `docker-compose.yml` and `.env` in `/DATA/AppData/`. A trimmed example is below (keep your full version in git):

```yaml
version: "3.9"
services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add: [NET_ADMIN]
    networks: [media]
    environment:
      - TZ=${TZ}
      - VPN_SERVICE_PROVIDER=airvpn
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
      - SERVER_COUNTRIES=${SERVER_COUNTRIES}
    ports:
      - 8080:8080     # qBittorrent
      - 6565:6565     # Nicotine+ (optional)
    volumes:
      - ${APPDATA}/gluetun:/gluetun
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080
    volumes:
      - ${APPDATA}/qbittorrent:/config
      - ${DATA_ROOT}/torrents:/data
    restart: unless-stopped

  nicotine:
    image: sirjmann92/nicotineplus-proper:latest
    container_name: nicotine
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - TZ=${TZ}
      - LANG=C.UTF-8
      - PUID=${PUID}
      - PGID=${PGID}
      - LOGIN=${NIC_LOGIN}
      - PASSW=${NIC_PASS}
      - DARKMODE=True
      - AUTO_CONNECT=True
    volumes:
      - ${APPDATA}/nicotine:/config
      - ${DATA_ROOT}/soulseek:/soulseek
    restart: unless-stopped

  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    networks: [media]
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    # devices:
    #   - /dev/dri:/dev/dri       # Intel VAAPI (if present)
    #   - /dev/nvidia0:/dev/nvidia0  # NVIDIA NVENC (requires nvidia-toolkit)
    volumes:
      - ${APPDATA}/jellyfin:/config
      - ${DATA_ROOT}/media/movies:/data/movies
      - ${DATA_ROOT}/media/tv:/data/tv
      - ${DATA_ROOT}/media/music:/data/music
    ports:
      - 8096:8096
    restart: unless-stopped

  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    networks: [media]
    environment:
      - ND_SCANSCHEDULE=1h
      - ND_LOGLEVEL=info
      - TZ=${TZ}
    volumes:
      - ${APPDATA}/navidrome:/data
      - ${DATA_ROOT}/media/music:/music:ro
    ports:
      - 4533:4533
    restart: unless-stopped

  calibre-web:
    image: lscr.io/linuxserver/calibre-web:latest
    container_name: calibre-web
    networks: [media]
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${APPDATA}/calibre-web:/config
      - ${DATA_ROOT}/books:/books
    ports:
      - 8083:8083
    restart: unless-stopped

  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    container_name: audiobookshelf
    networks: [media]
    environment:
      - TZ=${TZ}
    volumes:
      - ${APPDATA}/audiobookshelf:/config
      - ${DATA_ROOT}/audiobooks:/audiobooks
      - ${DATA_ROOT}/podcasts:/podcasts
    ports:
      - 13378:80
    restart: unless-stopped

  beets-flask:
    image: ghcr.io/sampsyo/beets:latest
    container_name: beets
    networks: [media]
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${APPDATA}/beets:/config
      - ${DATA_ROOT}/media/music:/music
    restart: unless-stopped

  picard:
    image: mikenye/picard:latest
    container_name: picard
    networks: [media]
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${APPDATA}/picard:/config
      - ${DATA_ROOT}/media/music:/music
    ports:
      - 5800:5800
    restart: unless-stopped

  focalboard:
    image: mattermost/focalboard:latest
    container_name: focalboard
    networks: [media]
    volumes:
      - ${APPDATA}/focalboard:/data
    ports:
      - 8000:8000
    restart: unless-stopped

  immich-server:
    image: ghcr.io/immich-app/immich-server:release
    container_name: immich-server
    networks: [media]
    depends_on: [immich-postgres, immich-redis]
    environment:
      - TZ=${TZ}
    volumes:
      - ${DATA_ROOT}/Gallery/immich:/usr/src/app/upload
    ports:
      - 2283:2283
    restart: unless-stopped

  immich-ml:
    image: ghcr.io/immich-app/immich-machine-learning:release
    container_name: immich-ml
    networks: [media]
    restart: unless-stopped

  immich-redis:
    image: redis:alpine
    container_name: immich-redis
    networks: [media]
    restart: unless-stopped

  immich-postgres:
    image: tensorchord/pgvecto-rs:pg14
    container_name: immich-postgres
    networks: [media]
    environment:
      - POSTGRES_PASSWORD=${IMMICH_DB_PASSWORD}
      - POSTGRES_USER=postgres
      - POSTGRES_DB=immich
    volumes:
      - ${APPDATA}/immich/postgres:/var/lib/postgresql/data
    restart: unless-stopped

networks:
  media: {}
  proxy: {}
```

Deploy:

```bash
cd /DATA/AppData
docker compose --env-file .env up -d
```

---

### 8) Service configuration & common gotchas

* **Gluetun**: `docker logs gluetun -f` until “VPN gateway” lines appear. Verify outbound IP with a quick curl in a temporary container attached to the same network (or from qBittorrent Web UI).
* **qBittorrent**: set **Downloads** base to `/data` in settings. Disable uTP if you see rate instability over VPN.
* **Nicotine+**: confirm login; set shared/downloads to `/soulseek`.
* **Jellyfin**: add libraries and test playback; for HW transcode, enable in Admin > Playback. If NVIDIA, ensure driver + container device mappings.
* **Navidrome**: confirm `/music` points to the read‑only mount; set scan interval if library is large.
* **Calibre‑web**: point to library directory or db file; configure OAuth if desired.
* **Audiobookshelf**: create Audiobooks/Podcasts libraries; enable metadata provider(s).
* **Immich**: run first‑time onboarding, then verify ML jobs (object detection/face). DB migration logs are visible in container logs.

---

## 9) Post‑deployment verification

Quick checks:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sort

# Container health logs (spot check)
docker logs --tail=100 gluetun
docker logs --tail=100 jellyfin

# Network presence
tailscale status
hostnamectl && timedatectl
```

Functional checks (browser):

* Jellyfin `:8096` (scan completes; playback OK; transcode test succeeds if enabled).
* Navidrome `:4533` (login; scan runs; albums visible).
* Calibre‑web `:8083` (can open a book entry).
* Audiobookshelf `:13378` (library populated).
* Immich `:2283` (albums visible; ML processing starts).

---

### 10) Host tuning (optional, recommended)

* **Hostname**: `sudo hostnamectl hostname coltersrv`.
* **Time sync**: `timedatectl status` shows `System clock synchronized: yes`.
* **SMART monitoring**: `sudo apt install -y smartmontools && sudo smartctl -H /dev/sdX`.
* **Automatic security updates**: `sudo apt install -y unattended-upgrades`.
* **Logs**: rotate large logs under `/DATA/AppData/*` if any service grows rapidly.

NVIDIA boot issue (GTX 970) resolution:

```bash
# If you used nomodeset to install, now install drivers and remove it
sudo apt purge -y 'nvidia-*'
sudo ubuntu-drivers list
sudo ubuntu-drivers autoinstall
sudo sed -i 's/ nomodeset//g' /etc/default/grub
sudo update-grub && sudo reboot
```

---

### 11) Backup strategy (automated)

**AppData nightly snapshot** (`/usr/local/bin/backup_appdata.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail
SRC=/DATA/AppData
DST=/DATA/backups/appdata-$(date +%F).tar.zst
mkdir -p /DATA/backups
sudo tar -I "zstd -19" -cf "$DST" -C "$SRC" .
find /DATA/backups -type f -name 'appdata-*.tar.zst' -mtime +14 -delete
```

Make it executable: `sudo chmod +x /usr/local/bin/backup_appdata.sh`.

**Systemd timer**
Create `/etc/systemd/system/backup-appdata.service`:

```ini
[Unit]
Description=Backup AppData to compressed archive

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup_appdata.sh
```

Create `/etc/systemd/system/backup-appdata.timer`:

```ini
[Unit]
Description=Run AppData backup nightly

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable: `sudo systemctl enable --now backup-appdata.timer`.

**Weekly off‑site** (rsync over Tailscale):

```bash
rsync -aHAXv --delete /DATA/AppData/ friendbox:/srv/backup/colter/AppData/
rsync -aHAXv --delete /DATA/documents/ friendbox:/srv/backup/colter/documents/
rsync -aHAXv --delete /DATA/Gallery/immich/ friendbox:/srv/backup/colter/Gallery/immich/
```

> Consider `restic` for deduplicated, encrypted backups to a remote repository.

---

### 12) Updates & rollbacks

Host updates:

```bash
sudo apt update && sudo apt -y upgrade
```

Container updates (all):

```bash
cd /DATA/AppData
docker compose pull && docker compose up -d
```

Rollback a single service:

```bash
# Pin a previous image tag or digest in docker-compose.yml, then
docker compose up -d <service>
```

---

### 13) Validation checklist (with commands)

**Host & storage**

* [ ] `/DATA` mounted by UUID and owned by `1000:1000`.

  * `findmnt /DATA && ls -ld /DATA`
* [ ] NTP synced; timezone correct.

  * `timedatectl`
* [ ] SMART passes on all disks.

  * `sudo smartctl -H /dev/sdX`
* [ ] UFW allows only required ports.

  * `sudo ufw status numbered`

**Network & access**

* [ ] Tailscale online; MagicDNS resolves `coltersrv`.

  * `tailscale status`
* [ ] LAN access to service ports works from another device.

**VPN & downloaders**

* [ ] Gluetun healthy; outbound IP is VPN.

  * `docker logs gluetun | tail -n +1 | head -n 50`
* [ ] qBittorrent reachable at `:8080` and saving to `/data`.
* [ ] Nicotine+ logs in and uses `/soulseek`.

**Media apps**

* [ ] Jellyfin scans libraries; playback (and optional HW transcode) OK.
* [ ] Navidrome scan completes; admin login OK.
* [ ] Calibre‑web opens library; user auth OK.
* [ ] Audiobookshelf libraries intact; metadata present.

**Photos & productivity**

* [ ] Immich login OK; ML jobs running; albums visible.
* [ ] Focalboard workspace loads and persists data.

**Ops**

* [ ] Cockpit (9090) / Netdata (19999) reachable (if enabled).
* [ ] Backups: a restore test of one file/db succeeded.

---

## 14) Troubleshooting quick reference

* **Gluetun dependent containers can’t reach the internet**: ensure they use `network_mode: service:gluetun` (or the same Docker network) and Gluetun is healthy; remove conflicting `networks:` entries on those services when using `network_mode`.
* **Permissions issues**: fix ownership

  ```bash
  sudo chown -R 1000:1000 /DATA/AppData /DATA/media /DATA/books /DATA/audiobooks /DATA/podcasts /DATA/Gallery
  ```
* **Jellyfin transcode fails**: confirm drivers and device mappings; test `vainfo` (Intel) or `nvidia-smi` (NVIDIA) on host.
* **Immich DB migrations pending**: check `immich-postgres` logs; re‑run `pg_restore` if needed; ensure `IMMICH_DB_PASSWORD` matches.
* **Ports already in use**: `sudo lsof -i -P -n | grep LISTEN` and remap conflicting services in compose.
* **CasaOS vs compose conflicts**: manage a given app with **one** tool (CasaOS *or* docker‑compose), not both.

---

### 15) TL;DR quick deploy

```bash
# Base
sudo apt update && sudo apt -y upgrade
sudo apt install -y docker.io docker-compose-plugin tailscale ufw
sudo tailscale up

# Storage
sudo mkdir -p /DATA && sudo chown -R 1000:1000 /DATA
# (Add UUID entry to /etc/fstab, then)
sudo mount -a

# Networks and env
docker network create media || true
cd /DATA/AppData && nano .env && nano docker-compose.yml

docker compose --env-file .env up -d
```











