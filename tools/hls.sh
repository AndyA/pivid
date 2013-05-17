#!/bin/bash

set -x

rm -rf live
mkdir -p live
raspivid -w 1280 -h 720 -fps 25 -hf -t 120000 -b 3000000 -o - \
  | ffmpeg -analyzeduration 5000 -y -f h264 -i - -c copy \
      -f segment -segment_time 8 -segment_format mpegts \
      "live/%08d.ts" < /dev/null 

# vim:ts=2:sw=2:sts=2:et:ft=sh

