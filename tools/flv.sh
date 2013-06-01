#!/bin/bash

me="$( hostname -s )"
url="rtmp://localhost/live/$me"
fifo="live.fifo.h264"

rm -f "$fifo"
mkfifo "$fifo"

raspivid \
  -w 1280 -h 720 -fps 25 -g 100 \
  -t 0 -b 3000000 -o - | psips > "$fifo" &

ffmpeg -y \
  -f h264 \
  -i "$fifo" \
  -c:v copy \
  -map 0:0 \
  -f flv "$url"

# vim:ts=2:sw=2:sts=2:et:ft=sh
