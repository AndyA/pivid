#!/bin/bash

set -x

raspivid -t 9999999 -b 2000000 -o live.h264 &

#sleep 5

tailpipe --wait=10 -t 10 live.h264 | ffmpeg -analyzeduration 5000 -f h264 -i - -c copy -f flv rtmp://igloo.fenkle/live/rune

# vim:ts=2:sw=2:sts=2:et:ft=sh

