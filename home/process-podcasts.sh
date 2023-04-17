#!/bin/bash

cd $1

for i in *; do
	fixed="${i%\?*}"
	if [ "$i" != "$fixed" ]; then
		echo mv "$i" "$RANDOM.$fixed"
		mv "$i" "$RANDOM.$fixed"
	fi
	fixed="${i%\%3f*}"
	if [ "$i" != "$fixed" ]; then
		echo mv "$i" "$RANDOM.$fixed"
		mv "$i" "$RANDOM.$fixed"
	fi
	if [[ "$i" = "SoundCloud%20Download" ]]; then
		mv $i $i.$RANDOM.mp3
	fi
done

for i in *.mp3; do
	if ! mid3v2 -l "$i" | grep '^TIT2'>/dev/null; then
		mid3v2 -t "${i%\.mp3}.$RANDOM" "$i"
	fi
	if ! mid3v2 -l "$i" | grep '^TALB'>/dev/null; then
		mid3v2 -A "$(mid3v2 -l "$i" | grep ^TPE1 | cut -f2 -d:)" "$i"
	fi
	if ! mid3v2 -l "$i" | grep '^TCON.*186'>/dev/null; then
		mid3v2 -g 186 "$i"
	fi
	if mid3v2 -l "$i" | grep '^COMM'>/dev/null; then
		mid3v2 -c "" "$i"
	fi

done
