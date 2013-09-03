#!/bin/bash 

#url=rtmp://newstream.hexten.net:1935/throne/tc1
url=rtmp://emit.fenkle:1935/throne/tc1
fifo="live.fifo.h264"
bitrate="1800000"
gop="200"

set -x

rm -f "$fifo"
mkfifo "$fifo"

raspivid \
  -w 1280 -h 720 -fps 25 -g $gop \
  -hf -vf \
  -t 0 -b $bitrate -o - | psips > "$fifo" &

ffmpeg -y \
  -f alsa -ac 2 -r:a 44100 -i hw:1,0 \
  -f h264 -i "$fifo" \
  -strict experimental \
  -c:a libfaac -b:a 128k -r:a 44100 \
  -c:v copy \
  -f flv "$url"

# vim:ts=2:sw=2:sts=2:et:ft=sh
