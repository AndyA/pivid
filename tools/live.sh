#!/bin/bash

tailpipe -i -t 120 live/00000000.ts | ffmpeg -f mpegts -i - -c:v bmp -f image2pipe - | ./merge 10 | \
  tee >( ./merge   3  |  ffmpeg -y -f image2pipe -c:v bmp -i - -pix_fmt yuv420p -c:v libx264 -b:v 3000k -r:v 25 l30.ts ) | \
  tee >( ./merge  20  |  ffmpeg -y -f image2pipe -c:v bmp -i - -pix_fmt yuv420p -c:v libx264 -b:v 3000k -r:v 25 live.ts ) | \
  tee >( ./merge  60  |  ffmpeg -y -f image2pipe -c:v bmp -i - -pix_fmt yuv420p -c:v libx264 -b:v 3000k -r:v 25 l600.ts ) | \
  tee >( ./merge 144  |  ffmpeg -y -f image2pipe -c:v bmp -i - -pix_fmt yuv420p -c:v libx264 -b:v 3000k -r:v 25 l1440.ts ) > /dev/null

# vim:ts=2:sw=2:sts=2:et:ft=sh

