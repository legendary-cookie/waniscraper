#!/bin/bash
source lib/lib.sh

if [ -z "$1" ]; then
  sortFor "kanji" "level"
else
  sortFor "$1" "level"
fi
