# unmount:
sudo umount /media/devmon/COLTER_T7

# mount:
sudo mount -t vfat -o uid=0,gid=0,umask=0000,utf8 /dev/sdb1 /mnt/COLTER_T7

# edit fstab:
sudo nano /etc/fstab
