#!/bin/bash

total_file_count=$(find . -mindepth 1 -maxdepth 1 -not -path '*/\.*')
num=1

for dir in *;do
  percent=$(echo "scale=4; $num / $total_file_count * 100" | bc | sed 's|00$||g')
  echo "## Removing $dir ($num of $total_file_count) ${percent}%"
  rm -Rf "./${dir}"
  (( num++ ))
done
