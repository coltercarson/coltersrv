# copy files/dirs
sudo cp -rv "/media/devmon/COLTER_T7/DJ MUSIC" /media/devmon/COLTER_FILMS/music

# copy and exit ssh
screen
rsync -avh --progress "/media/devmon/COLTER_T7/DJ MUSIC" /media/devmon/COLTER_FILMS/music
# """ then press Ctrl+A then D to detach the screen session """
# """ to reattach the screen session, use: screen -r """