#!/bin/bash

file=$1
filename="${file%.*}"

ffmpeg -i $file -c:v copy -c:a pcm_s16le $filename.mov

echo done
