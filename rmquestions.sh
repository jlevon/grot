#!/bin/bash

for i in "$@"; do
	fixed="${i%\?*}"
	if [ "$i" != "$fixed" ]; then
		echo mv "$i" "$fixed"
		mv "$i" "$fixed"
	fi
	fixed="${i%\%3f*}"
	if [ "$i" != "$fixed" ]; then
		echo mv "$i" "$fixed"
		mv "$i" "$fixed"
	fi
done

for i in MSR*; do
set -x
	nr=$(echo $i | sed 's+MSR++;s+_Podcast.mp3++')
	id3v2 -a "Milk Street Radio" -A "Milk Street Radio" -g 186 -t "$nr" $i
done
