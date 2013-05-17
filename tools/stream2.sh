#!/bin/bash

set -x

raspivid -w 1280 -h 720 -fps 30 -hf -t 9999999 -b 2000000 -o - \
  | ffmpeg -analyzeduration 5000 -r 30 -f h264 -i - -c copy -f flv rtmp://igloo.fenkle/live/rune

# vim:ts=2:sw=2:sts=2:et:ft=sh

