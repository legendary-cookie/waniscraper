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
		if [[ $f == *radicals* ]]; then
			cat $f | pup 'ul.single-character-grid li a ul li text{}' | awk 'NF' >$1/$(basename $f)
		else
			local count="single"
			if [[ $f == *vocabulary* ]]; then count="multi"; fi
			cat $f | get-content $count >$1/$(basename $f)
		fi
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
	local data="$1"
	# General
	local level=$(echo $data | pup "header h1 a text{}")
	# Meaning
	local primary=$(echo $data | pup 'section#meaning div:nth-child(2) p text{}')
	local secondary=$(echo $data | pup 'section#meaning div:nth-child(3) p text{}')
	local mne="$(echo $data | pup 'section#meaning section.mnemonic-content.mnemonic-content--new p:nth-child(1) text{}' | tr -d "\n")"
	local hint="$(echo $data | pup 'section#meaning section.mnemonic-content.mnemonic-content--new p:nth-child(2) text{}' | tr -d "\n")"
	# Readings
	local onyomi="$(echo $data | pup "section#reading div.row div:nth-child(1) p text{}" | tr -d " " | awk 'NF')"
	local kunyomi="$(echo $data | pup "section#reading div.row div:nth-child(2) p text{}" | tr -d " " | awk 'NF')"
	local nanori="$(echo $data | pup "section#reading div.row div:nth-child(3) p text{}" | tr -d " " | awk 'NF')"
	local readmne="$(echo $data | pup 'section#reading section.mnemonic-content p:first-child text{}' | tr -d '\n')"
	local readhint="$(echo $data | pup 'section#reading section.mnemonic-content p:nth-child(2) text{}' | tr -d '\n')"
	# Print as JSON
	printf '{"level": %i, "meanings": {"primary": "%s", "secondary": "%s", "mnemonic": "%s", "hint": "%s"}, "readings": {"onyomi": "%s", "kunyomi": "%s", "nanori": "%s", "mnemonic": "%s", "hint": "%s"}}' \
		"$level" "$primary" "$secondary" "$mne" "$hint" "$onyomi" "$kunyomi" "$nanori" "$readmne" "$readhint"
)

function getradicaldata() (
	local data="$1"
	local level=$(echo $data | pup "header h1 a text{}")
	local radical=$(echo $data | pup "header h1 span text{}")
	local mne=$(echo $data | pup "section.mnemonic-content text{}" | awk NF | tr -d '\n')
	printf '{"level": %i, "radical": "%s", "mne": "%s"}' "$level" "$radical" "$mne"
)

function collect() {
	for f in $(find out/ -type f -iname kanji-\*); do
		local len="$(cat $f | wc -l)"
		echo "Processing file '$f' ..."
		for line in $(cat $f); do
			getkanjidata "$(curl -s -o - $rooturl/kanji/$line)" >data/kanji/$line.json
			echo -n X
		done | pv -p -t -e -s $len - >/dev/null
	done
	for f in $(find out/ -type f -iname radicals-\*); do
		local len="$(cat $f | wc -l)"
		echo "Processing file '$f' ..."
		for line in $(cat $f); do
			getradicaldata "$(curl -s -o - $rooturl/radicals/$line)" >data/radicals/$line.json
			echo -n X
		done | pv -p -t -e -s $len - >/dev/null
	done
}

# Output data from file formatted
# $1 = path to file
# $2 = kanji/radical/vocab
function outputFormattedData() {
	data="$(cat $1)"
	type="$2"
	level=$(echo $data | jq '.level')
	primary=$(echo $data | jq '.meanings.primary')
	on=$(echo $data | jq .readings.onyomi)
	kun=$(echo $data | jq .readings.kunyomi)
	case $type in
	kanji)
		echo "KANJI"
		echo "Level: $level"
		echo "Primary Meaning: $primary"
		echo "Readings:"
		printf " - On: %s\n" "$on"
		printf " - Kun: %s\n" "$kun"
		;;
	*)
		echo "no type given"
		;;
	esac
}

# Sort input data
# $1 = what to sort
# $2 = what to sort for
function sortFor() {
	case $2 in
	level)
		echo '{"levels": ['
		for level in $levels; do
			rg -l "\"level\": $level," "data/$1" | ./src/json_encode
			if [ $level = 60 ]; then continue; fi
			echo ","
		done
		echo "]}"
		;;
	*)
		echo "SORTING METHOD NOT FOUND"
		;;
	esac
}
