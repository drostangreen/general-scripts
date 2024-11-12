#!/bin/bash

directory=$1

mkdir $direcotry/Proxy
mv *.lrf $directory/Proxy/

for file in *.mp4; do
	filename="${file%.*}"
	ffmpeg -i $file -c:v copy -c:a pcm_s16le $filename.mov
done

echo done
