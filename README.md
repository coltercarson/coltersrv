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
- **iOS Apps:** ShelfPlayer, Plappa  
- **Android App:** Audiobookshelf  

_Contact me if you want anything added 🙂_

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



## Redeployment

A top-level reference to rebuild and deploy the server stack on new hardware.

1. **Pre‑rebuild preparation**

   * Inventory hardware, disks, and network settings.
   * Back up `/DATA/AppData` configs, media, and documents.
   * Export secrets and service credentials.
   * Save `.env` files and `docker-compose.yml`.

2. **Install operating system**

   * Install Ubuntu Server LTS (from USB boot disk -- prepare w Rufus)
   * Install CasaOS OS image --> `curl -fsSL https://get.casaos.io | sudo bash`
   * Create `colter5000` user (UID 1000), set timezone `Pacific/Auckland`.
   * Apply system updates.

3. **Mount and prepare data disk**

   * Format (if needed) and mount by UUID at `/DATA`.
   * Create required folders: `/DATA/AppData`, `/DATA/documents`, `/DATA/Gallery/immich`.

4. **Install base packages and services**

   * Install Docker, docker-compose-plugin, Tailscale, UFW, and optional tools (Cockpit, Netdata).

5. **Configure network and firewall**

   * Join Tailscale network.
   * Create Docker networks (`media`, `proxy`).
   * Set UFW rules.

6. **Restore backups**

   * Copy backed-up AppData, media, and documents into `/DATA`.
   * Restore any Docker volumes or database dumps.

7. **Deploy Docker stack**

   * Place `.env` and `docker-compose.yml` in `/DATA/AppData`.
   * Run `docker compose up -d`.

8. **Service configuration**

   * Verify each container’s paths, ports, and settings.
   * Confirm VPN routing for Gluetun-linked services.

9. **Post‑deployment checks**

   * Access and test all services (Jellyfin, Navidrome, Calibre-web, etc.).
   * Validate media libraries and database restores.

10. **Host tuning (optional)**

    * Set hostname, enable NTP, monitor disks, configure backups.

11. **Backup strategy**

    * Schedule local AppData snapshots.
    * Set up off-site backups over Tailscale.

12. **Update procedure**

    * Regularly update OS packages and container images.

13. **Validation checklist**

    * Confirm `/DATA` mount, Tailscale access, Gluetun health.
    * Validate backups and UFW configuration.

14. **Troubleshooting**

    * Resolve network mode or permission issues.
    * Monitor for slow scans or resource bottlenecks.








