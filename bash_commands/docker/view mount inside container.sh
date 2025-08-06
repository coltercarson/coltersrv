# view mount inside container
sudo docker exec qbittorrent ls -ld /downloads

#example:
# colter5000@coltersrv:~$ sudo docker exec qbittorrent ls -ld /tv_series
# drwxrwxrwx 1 300 1001 8192 Jun 26 08:12 /tv_series

# breakdown:
# d — It’s a directory.

# rwxrwxrwx — Permissions:
# Everyone (owner, group, others) has read, write, and execute permissions.
# This is the most open permission set — full access for all.

# 1 — Number of links (just one in this case).

# 300 — Owner user ID (UID) inside the container (instead of a username, it shows a number).

# 1001 — Owner group ID (GID) inside the container.

# 8192 — Directory size in bytes.

# Jun 26 08:12 — Last modification date/time.

# /tv_series — Directory path inside the container.