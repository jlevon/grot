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
