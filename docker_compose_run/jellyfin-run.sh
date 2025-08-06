sudo mkdir /home/colter5000/docker/jellyfin/config
sudo mkdir /home/colter5000/docker/jellyfin/cache

sudo docker run -d \
 --name jellyfin \
 --user 1000:1000 \
 --net=host \
 --volume /home/colter5000/docker/jellyfin/config:/config \
 --volume /home/colter5000/docker/jellyfin/cache:/cache \
 --mount type=bind,source="/media/devmon/COLTER T5/Contents",target=/music \
 --mount type=bind,source=/media/devmon/COLTER_FILMS/MOVIES,target=/movies \
 --mount type=bind,source="/media/devmon/COLTER_FILMS/TV SERIES",target=/tv_servies \
 --restart=unless-stopped \
 jellyfin/jellyfin