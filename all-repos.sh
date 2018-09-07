#!/bin/bash

for repo in . projects/illumos-joyent projects/illumos-extra projects/local/* ;
do
	(cd $repo && echo $repo && "$@")
done
