#!/bin/bash 

base="/var/www"
stamp=$( date +%Y%m%d-%H%M%S )
session="live-$stamp"
fifo="live.fifo.h264"

set -x

# bootstrap
for f in www/*; do
  d="$base/$( basename "$f" )"
  [ -e "$d" ] || cp "$f" "$d"
done

mkdir -p "$session"

rm -f "$base/live" "live"
ln -s "$PWD/$session" "live"
ln -s "$PWD/$session" "$base/live"

rm -f "$fifo"
mkfifo "$fifo"

raspivid \
  -w 1280 -h 720 -fps 25 -g 100 \
  -t 86400000 -b 3000000 -o - | psips > "$fifo" &

ffmpeg -y \
  -f h264 \
  -i "$fifo" \
  -c:v copy \
  -map 0:0 \
  -f segment \
  -segment_time 4 \
  -segment_format mpegts \
  -segment_list "$base/live.m3u8" \
  -segment_list_size 720 \
  -segment_list_flags live \
  -segment_list_type m3u8 \
  "live/%08d.ts" < /dev/null 

# vim:ts=2:sw=2:sts=2:et:ft=sh
