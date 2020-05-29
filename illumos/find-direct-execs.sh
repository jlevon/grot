#!/bin/bash

# all builds that seem to not do a .o build first, and hence skip the
# shadow run

for dir in $*;  do
	for file in $dir/*; do
		if [[ -f $file.c && ! -f $file.o ]]; then
			echo $file
		fi
	done
done
