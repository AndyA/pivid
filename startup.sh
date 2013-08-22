#!/bin/bash

while true; do
  ./tools/rtmp-low.sh
  printf '\n\n\nRestarting\n\n\n'
  sleep 3
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

