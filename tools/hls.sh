#!/bin/bash

base="/var/www"

set -x

rm -rf live live.h264 "$base/live"
mkdir -p live

for f in www/*; do
  d="$base/$( basename "$f" )"
  [ -e "$d" ] || cp "$f" "$d"
done

ln -s "$PWD/live" "$base/live"

mkfifo live.h264

raspivid \
  -w 1280 -h 720 -fps 25 -hf \
  -t 86400000 -b 1800000 -o - | psips > live.h264 &

sleep 4

ffmpeg -y \
  -i live.h264 \
  -c:v copy \
  -map 0:0 \
  -f segment \
  -segment_time 8 \
  -segment_format mpegts \
  -segment_list "$base/live.m3u8" \
  -segment_list_size 720 \
  -segment_list_flags live \
  -segment_list_type m3u8 \
  "live/%08d.ts" < /dev/null 

# vim:ts=2:sw=2:sts=2:et:ft=sh
