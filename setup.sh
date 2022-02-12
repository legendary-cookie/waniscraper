#!/bin/bash
source lib/lib.sh
mkdir -p data/ in/ out/ data/kanji data/radicals data/vocabulary
echo "Downloading html ..."
sleep 0.2
dwnload in/
echo "Scraping information from downloaded html ..."
sleep 0.2
convert out/
echo "Collecting information to each character/vocab/radical ..."
sleep 0.2
collect
