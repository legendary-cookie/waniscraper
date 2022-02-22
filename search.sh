#!/bin/bash
source lib/lib.sh
found=($(fd --type=file "$1" data))

if [ ${#found[@]} = '1' ]; then
	type="$(basename "$(dirname "$found")")"
	outputFormattedData "$found" "$type"
        exit
else
        PS3='Choose: '
	select choice in "${found[@]}"; do
		case $choice in
		"Quit")

			echo "User requested exit"
			exit
			;;
		*)
			type="$(basename "$(dirname "$choice")")"
			outputFormattedData "$choice" "$type"
			exit
			;;
		esac
	done

fi
