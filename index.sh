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
  count)
    i=0;
    for level in {0..60}
    do
      i=$(($i + $(cat data/index/kanji.json | jq -c ".levels[$level]" | tr -d '[],"' | wc -m)))
    done; 
    echo "KANJI: $i"
    exit
    ;;
  *)
    echo "This subcommand does not exist."
    echo "Valid subcommands are [update; level; count]"
    exit
    ;;
esac
