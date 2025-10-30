#!/bin/bash

set -e

mkdir -p ./Proxy
mv *.LRF ./Proxy
cd ./Proxy
for file in *.LRF; do
	mv "$file" "${file%.LRF}.MP4"
done
