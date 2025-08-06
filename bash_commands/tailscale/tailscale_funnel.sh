# Tailscale Funnel Configuration Script
# Three available ports for each machine on tailnet: 443, 8443, and 10000
# --bg flag runs the command in the background

# Jellyfin -- run then access at https://coltersrv.ghoul-elnath.ts.net/ (https://<machine_id>.<tailnet_name>.ts.net/)
sudo tailscale funnel --bg --https=443 8097

# Audiobookshelf -- run then access at https://coltersrv.ghoul-elnath.ts.net:8443/ (https://<machine_id>.<tailnet_name>.ts.net/)
sudo tailscale funnel --bg --https=8443 8282

# Navidrome -- run then access at https://coltersrv.ghoul-elnath.ts.net:10000/ (https://<machine_id>.<tailnet_name>.ts.net/)
sudo tailscale funnel --bg --https=10000 4533


# To disable the funnels, run the following commands:
sudo tailscale funnel --https=443 off
sudo tailscale funnel --bg --https=8443 off
sudo tailscale funnel --bg --https=10000 off



# To make this persistent across reboots, you can add the commands to a startup script or use a systemd service.

# Create a script to run the commands at startup
sudo nano /usr/local/bin/tailscale-funnel-setup.sh

# Paste the following content into the script without the quotes:
"""
#!/bin/bash
# Tailscale Funnel Configuration Script

# Jellyfin
tailscale funnel --bg --https=443 8097

# Audiobookshelf
tailscale funnel --bg --https=8443 8282

# Navidrome
tailscale funnel --bg --https=10000 4533
"""

# Make the script executable
sudo chmod +x /usr/local/bin/tailscale-funnel-setup.sh

# Create a systemd service to run the script at startup
sudo nano /etc/systemd/system/tailscale-funnel.service

"""
[Unit]
Description=Set up Tailscale Funnel routes
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/tailscale-funnel-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
"""

# Enable the service to run at startup
sudo systemctl enable tailscale-funnel.service
