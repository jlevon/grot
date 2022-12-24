#!/bin/bash

# given a k3b file, extract it, rename all mp3 files in the given order, then
# create everything else. Expects "cover.png". After processing need to recreate
# the k3b file from the mp3s again.


indir=$(pwd)
outdir=/tmp/p.$$
mkdir $outdir
cp AudioCD0.k3b $outdir/
cd $outdir
unzip *.k3b
declare -a urls
declare -a titles
declare -a artists

cat maindata.xml | xmlstarlet sel -t -v "/k3b_audio_project/contents/track/sources/file/@url"  | mapfile -t urls
cat /etc/hosts | mapfile -t urls
mapfile -t urls < <(cat maindata.xml | xmlstarlet sel -t -v "/k3b_audio_project/contents/track/sources/file/@url")
mapfile -t titles < <(cat maindata.xml | xmlstarlet sel -t -v "/k3b_audio_project/contents/track/cd-text/title")
mapfile -t artists < <(cat maindata.xml | xmlstarlet sel -t -v "/k3b_audio_project/contents/track/cd-text/artist")

date=$(date +%Y.%m)
m3u=$indir/$date.m3u

cat >$m3u <<EOF
#EXTM3U
#EXTALB:jlevon $date
EOF

# FIXME: can't add this - breaks shitty safari
#EXTIMG: frontcover
# https://movementarian.org/$date/cover.png

cat >$indir/.htaccess <<EOF
AddType application/x-mpegURL .m3u
DirectoryIndex index.html
EOF

cat >$outdir/index.html <<EOF
<title>$date</title>

<h1>$date</h1>

<img src="https://movementarian.org/$date/cover.png"></img>

<p>

<a href="$date.m3u">m3u playlist</a>

<p>

<ol>
EOF

echo
echo

nr=1

for i in ${!urls[@]}; do
	path=$(echo ${urls[$i]} | recode html..ascii)
	file=$(basename "$path" | recode html..ascii)
	dir=$(dirname "$path")
	artist="${artists[$i]}"
	title="${titles[$i]}"
	length=$(mp3info -p "%S" "$path")
	track=$(printf "%02d" $nr)
	echo "#EXTINF:$length,$artist - $title" >>$m3u
	newfile="$track.$artist.$title.mp3"
	mv "$path" "$dir/$newfile" 2>/dev/null
	id3v2 -A "jlevon $date" $dir/$newfile
	uri="$(echo -n "$newfile" | jq -sRr @uri)"
	echo "https://movementarian.org/$date/$uri" >>$m3u
	echo "<li><a href=\"https://movementarian.org/$date/$uri\">$track $artist - $title</li>" >>$outdir/index.html

	echo -n "/ $track $artist - $title "
	nr=$(( $nr + 1 ))
done

echo "</ol></html>" >>$outdir/index.html
echo
echo

rsync --delete -avz $indir/ movement@ssh.movementarian.org:movementarian.org/$date
