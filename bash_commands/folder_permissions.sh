# folder permissions
# sudo chown -R UID:GID <path>

sudo chown -R 1000:1000 /media/devmon/COLTER_FILMS/MOVIES
sudo chown -R 1000:1000 "/media/devmon/COLTER_FILMS/TV SERIES"
sudo chown -R 1000:1000 /DATA/downloads/nicotine/complete
sudo chown -R 1000:1000 /DATA/downloads/nicotine/incomplete
sudo chown -R 1000:1000 /DATA/downloads/nicotine/uploads
sudo chown -R 1000:1000 /DATA/downloads/nicotine/logs
sudo chown -R 1000:1000 "/media/devmon/COLTER_T7/DJ MUSIC/SOULSEEK_MASTER/incomplete"
sudo chown -R 1000:1000 "/media/devmon/COLTER_T7/DJ MUSIC/SOULSEEK_MASTER/complete"
sudo chown -R 1000:1000 "/mnt/COLTER_T7/DJ MUSIC/SOULSEEK_MASTER/incomplete"
sudo chown -R 1000:1000 "/mnt/COLTER_T7/DJ MUSIC/SOULSEEK_MASTER/complete"

# fstab update to remount with new permissions
sudo nano /etc/fstab
UUID=1B0E-185E  /mnt/COLTER_T7  vfat  uid=0,gid=0,umask=0000,utf8  0  0

# view folder permissions
ls -l /media/devmon/COLTER_FILMS/MOVIES

# view file permissions
