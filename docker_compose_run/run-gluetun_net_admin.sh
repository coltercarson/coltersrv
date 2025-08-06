# adapted from: https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/airvpn.md

sudo docker run -it --rm --cap-add=NET_ADMIN --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=airvpn \
  -e VPN_TYPE=wireguard \
  -e WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY} \
  -e WIREGUARD_PRESHARED_KEY=XEirBqS/dDGOcc3aj4dbl/19Jii1ddyTxm98K7Gk5hU= \
  -e WIREGUARD_ADDRESSES=10.163.120.44/32 \
  qmcgaw/gluetun