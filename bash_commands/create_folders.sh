# Run this in a dir to create folders and sub-folders

for dir in \
1001 beatport common_grass edits juno_download kollektivx private_share \
radiooooo soulseek nicotineplus dtv qbittorrent vinyl_rips cd_rips deemix bandcamp; do
  mkdir -p "$dir/beets-flask-inbox" "$dir/beets-inbox"
done

for dir in \
1001 beatport common_grass edits juno_download kollektivx private_share \
radiooooo soulseek nicotineplus dtv qbittorrent vinyl_rips cd_rips deemix bandcamp; do
  mkdir -p "$dir/beets-clean"
done
