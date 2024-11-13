#!/bin/bash

directory=$1

mkdir $directory/Proxy
mv $directory/*.LRF $directory/Proxy/
cd $directory/Proxy

for file in *.LRF; do
	filename="${file%.*}"
	mv "$file" "$filename.MP4"
done

for file in *.MP4; do
	filename="${file%.*}"
	ffmpeg -i $file -c:v copy -c:a pcm_s16le $filename.mov
done

cd $directory
for file in *.MP4; do
	filename="${file%.*}"
	ffmpeg -i $file -c:v copy -c:a pcm_s16le $filename.mov
done

echo done
