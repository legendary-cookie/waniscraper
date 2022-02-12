#!/bin/bash
rooturl="https://www.wanikani.com"
scrapeurl="$rooturl/%s?difficulty=%s"
difficulties="pleasent painful death hell paradise reality"
types="radicals kanji vocabulary"
levels="$(echo {1..60})"

function get-content() {
	pup "ul.$1-character-grid span.character text{}" |
		awk 'NF' |
		tr -d " "
}

function convert() {
	local outdir=$1
	for f in $(find in/ -type f); do
		local count="single"
		if [[ $f == *vocabulary* ]]; then count="multi"; fi
		cat $f | get-content $count >$1/$(echo "$f" | sd 'in/' '')
	done
}

function dwnload() {
	local indir=$1
	for type in $types; do
		for diff in $difficulties; do
			local downurl="$(printf "$scrapeurl" "$type" "$diff")"
			curl -sSL -o "$1/$type-$diff" "$downurl"
		done
	done
}

function getkanjidata() (
	data="$1"
	# General
	level=$(echo $data | pup "header h1 a text{}")
	# Meaning
	primary=$(echo $data | pup 'section#meaning div:nth-child(2) p text{}')
	secondary=$(echo $data | pup 'section#meaning div:nth-child(3) p text{}')
	mne="$(echo $data | pup 'section#meaning section.mnemonic-content.mnemonic-content--new p:nth-child(1) text{}' | tr -d "\n")"
        hint="$(echo $data | pup 'section#meaning section.mnemonic-content.mnemonic-content--new p:nth-child(2) text{}' | tr -d "\n")"
	# Readings
	onyomi="$(echo $data | pup "section#reading div.row div:nth-child(1) p text{}" | tr -d " " | awk 'NF')"
	kunyomi="$(echo $data | pup "section#reading div.row div:nth-child(2) p text{}" | tr -d " " | awk 'NF')"
	nanori="$(echo $data | pup "section#reading div.row div:nth-child(3) p text{}" | tr -d " " | awk 'NF')"
        readmne="$(echo $data | pup 'section#reading section.mnemonic-content p:first-child text{}' | tr -d '\n')"
        readhint="$( echo $data | pup 'section#reading section.mnemonic-content p:nth-child(2) text{}' | tr -d '\n')"
        # Print as JSON
	printf '{"level": %i, "meanings": {"primary": "%s", "secondary": "%s", "mnemonic": "%s", "hint": "%s"}, "readings": {"onyomi": "%s", "kunyomi": "%s", "nanori": "%s", "mnemonic": "%s", "hint": "%s"}}' \
		"$level" "$primary" "$secondary" "$mne" "$hint" "$onyomi" "$kunyomi" "$nanori" "$readmne" "$readhint"
)

function collect() {
	for f in $(find out/ -type f); do
              	for line in $(cat $f); do
			if [[ $f == out/kanji-* ]]; then
                          getkanjidata "$(curl -s -o - $rooturl/kanji/$line)" > data/kanji/$line.json &
                        fi
      	        done
                wait
	done
}
