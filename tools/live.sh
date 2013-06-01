#!/bin/bash 

base="/var/www"
me="$( hostname -s )"
url="rtmp://localhost/live/$me"
stamp="$( date +%Y%m%d-%H%M%S )"
session="live-$stamp"
fifo1="live.fifo.hls.h264"
fifo2="live.fifo.flv.h264"

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

rm -f "$fifo1" "$fifo2"
mkfifo "$fifo1" "$fifo2"

# cleanup
{
  while sleep 60; do
    find "$session" -type f -name '*.ts' -mmin +240 -print0 | xargs -r -0 rm
  done
} &

raspivid \
  -w 1280 -h 720 -fps 25 -g 100 \
  -t 0 -b 3000000 -o - | psips | fatcat "$fifo1" "$fifo2" &

ffmpeg -y \
  -f h264 \
  -i "$fifo1" \
  -c:v copy \
  -map 0:0 \
  -f segment \
  -segment_time 4 \
  -segment_format mpegts \
  -segment_list "$base/live.m3u8" \
  -segment_list_size 1800 \
  -segment_list_flags live \
  -segment_list_type m3u8 \
  "live/%08d.ts" < /dev/null &

ffmpeg -y \
  -f h264 \
  -i "$fifo2" \
  -c:v copy \
  -map 0:0 \
  -f flv "$url" < /dev/null &

wait

# vim:ts=2:sw=2:sts=2:et:ft=sh
