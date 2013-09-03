#!/bin/bash 

stamp=$( date +%Y%m%d-%H%M%S )
session="live-$stamp"
fifo="live.fifo.h264"

set -x

mkdir -p "$session"

rm -f "live"
ln -s "$PWD/$session" "live"

rm -f "$fifo"
mkfifo "$fifo"

raspivid \
  -w 1920 -h 1080 -fps 25 -g 100 \
  -t 0 -b 4000000 -o - | psips > "$fifo" &

ffmpeg -y \
  -f h264 \
  -i "$fifo" \
  -c:v copy \
  -map 0:0 \
  -f segment \
  -segment_time 4 \
  -segment_format mpegts \
  -segment_list_type m3u8 \
  "live/%08d.ts" < /dev/null 

# vim:ts=2:sw=2:sts=2:et:ft=sh
