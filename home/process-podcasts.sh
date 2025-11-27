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
	fixed="${i%.mp3.[0-9]*}"
	if [ "$i" != "$fixed" ]; then
		echo mv "$i" "$fixed.$RANDOM.mp3"
		mv "$i" "$fixed.$RANDOM.mp3"
	fi
done

for i in *.mp3; do
	if echo $i | grep -q MSR; then
		mid3v2 -a "Milk Street Radio" -A "Milk Street Radio" "$i"
	fi
	if echo $i | grep -q _SS_; then
		mid3v2 -a "Serious Eats" -A "Serious Eats" "$i"
	fi
	set -x
	if echo $i | grep -q 'Club Fish'; then
		mid3v2 -a "No Such Thing As A Fish" -A "No Such Thing As A Fish" "$i"
	fi
	set +x
	if echo $i | grep -q 'OUTTAKES'; then
		mid3v2 -a "No Such Thing As A Fish" -A "No Such Thing As A Fish" "$i"
	fi
	if echo $i | grep -q '^202.* SS '; then
		if ! mid3v2 -l "$i" | grep -a '^TALB'>/dev/null; then
			mid3v2 -a "Serious Eats" -A "Serious Eats" "$i"
		fi
	fi
	if mid3v2 -l "$i" | grep -a 'TCOP=.*iHeart'>/dev/null; then
		mid3v2 --delete-frames TCOP "$i"
	fi
	if mid3v2 -l "$i" | grep -a 'TPE1=.*iHeart'>/dev/null; then
		mid3v2 -a "$(mid3v2 -l "$i" | grep -a ^TALB | cut -f2 -d=)" "$i"
	fi
	if mid3v2 -l "$i" | grep -a 'TPE2=.*iHeart'>/dev/null; then
		mid3v2 --delete-frames TPE2 "$i"
	fi
	if mid3v2 -l "$i" | grep -a 'TCOP=.*Lava Productions'>/dev/null; then
		mid3v2 --delete-frames TCOP "$i"
	fi
	if mid3v2 -l "$i" | grep -a 'TPE1=.*Lava Productions'>/dev/null; then
		mid3v2 -a "$(mid3v2 -l "$i" | grep -a ^TALB | cut -f2 -d=)" "$i"
	fi
	if mid3v2 -l "$i" | grep -a 'TPE2=.*Lava Productions'>/dev/null; then
		mid3v2 --delete-frames TPE2 "$i"
	fi
	if ! mid3v2 -l "$i" | grep -a '^TIT2'>/dev/null; then
		mid3v2 -t "${i%\.mp3}.$RANDOM" "$i"
	fi
	if ! mid3v2 -l "$i" | grep -a '^TALB'>/dev/null; then
		mid3v2 -A "$(mid3v2 -l "$i" | grep -a ^TPE1 | cut -f2 -d=)" "$i"
	fi
	if ! mid3v2 -l "$i" | grep -a '^TCON.*186'>/dev/null; then
		mid3v2 -g 186 "$i"
	fi
	if mid3v2 -l "$i" | grep -a '^COMM'>/dev/null; then
		mid3v2 -c "" "$i"
	fi

done
