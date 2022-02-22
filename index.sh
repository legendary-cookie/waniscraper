#!/bin/bash

case "$1" in 
  update)
    ./sort.sh  | jq | sed 's/.json//g;s/data\/.*\///g' | jq -c > data/index/kanji.json
    exit
    ;;
  level)
    level="$2"
    cat data/index/kanji.json | jq ".levels[$level]"
    exit
    ;;
  *)
    echo "This subcommand does not exist."
    echo "Valid subcommands are [update; level]"
    exit
    ;;
esac
