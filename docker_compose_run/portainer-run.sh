# from: https://docs.portainer.io/start/install-ce/server/docker/linux

sudo docker run -d \
 -p 8000:8000 \
 -p 9443:9443 \
 --name portainer \
 --restart=always \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /home/colter5000/docker/portainer:/data \
 portainer/portainer-ce:lts

 # access portainer at https://192.168.20.50:9443