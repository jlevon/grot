#!/bin/bash

cd $1

for i in *; do
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
	nr=$(echo $i | sed 's+MSR++;s+_Podcast.mp3++')
	id3v2 -a "Milk Street Radio" -A "Milk Street Radio" -g 186 -t "$nr" $i
done

for i in *.mp3; do
	if ! id3v2 -l "$i" | grep '^TCON.*186'>/dev/null; then
		id3v2 -g 186 "$i"
	fi
done
