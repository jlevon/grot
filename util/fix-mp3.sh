#!/bin/bash

set -e

for i in "$@"; do
	echo xx${i}xx
	ffmpeg -i "$i" "$i".wav
	rm "$i"
	ffmpeg -i "$i".wav "$i"
done
