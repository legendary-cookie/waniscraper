#!/bin/bash
source lib/lib.sh
mkdir -p data/ in/ out/ data/index data/kanji data/radicals data/vocabulary

if [[ "$(ls -1 in/ | wc -l)" != "18" ]]; then
	echo "Downloading html ..."
	sleep 0.2
	dwnload in/
fi
if [[ "$(ls -1 out/ | wc -l)" != "18" ]]; then
	echo "Scraping information from downloaded html ..."
	sleep 0.2
	convert out/
fi
echo "Collecting information to each character/vocab/radical ..."
sleep 0.2
collect
