#!/bin/bash

set -e

file=$1
filename="${file%.*}"

ffmpeg -i $file -c:v copy -c:a flac $filename-flac.mp4

read -p "Remove original file? (Y/n)"
if [[ $REPLY =~ ^[Nn]$ ]]; then
	echo done
else
	rm $1
	echo done
fi

