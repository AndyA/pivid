#!/bin/bash

ffmpeg_opt="-y -f yuv4mpegpipe -i - -map 0:0 -c:v libx264 -b:v 3000k -r:v 25"

tailpipe -i -t 120 live/00000000.ts | \
  ffmpeg -f mpegts -i - -f yuv4mpegpipe - | \
  timewarp timewarp.json | tee >( \
    timewarp timewarp.json | tee >( \
      timewarp timewarp.json | ffmpeg $ffmpeg_opt live1000.ts \
    ) | ffmpeg $ffmpeg_opt live100.ts \
  ) | ffmpeg $ffmpeg_opt live10.ts

# vim:ts=2:sw=2:sts=2:et:ft=sh

