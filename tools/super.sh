#!/bin/bash

tailpipe -i -t 120 live/00000000.ts | ffmpeg -f mpegts -i - -c:v bmp -f image2pipe - | \
  ./merge 1440 | \
  ffmpeg -y -f image2pipe -c:v bmp -i - -pix_fmt yuv420p -c:v libx264 -b:v 3000k -r:v 25 super.ts &

# vim:ts=2:sw=2:sts=2:et:ft=sh

