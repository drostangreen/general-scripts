#!/bin/bash

total="$(find . -maxdepth 1 -type f ! -name ".*" -iname "*.MP4" | wc -l)"
counter=0

shopt -s nullglob

mkdir -p original
echo "Total number of files found: $total"

for file in *.MP4 *.mp4; do
	((counter++))
	echo "Converting $file"
	echo "$counter of $total"
	ffmpeg -i "$file" -c:v copy -c:a pcm_s16le "${file%.*}.mov" &>> ffmpeg.log
	mv "$file" original
done

read -p "Would you like to delete the folder that holds the originals? (Y/n)"
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Originals are kept in ./originals"
    echo "Convervion complete"
else
    rm -r original
    echo "Originals removed."
    echo "Conversion complete."
fi
