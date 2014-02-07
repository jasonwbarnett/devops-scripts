#!/bin/bash

total_file_count=$(ls -1 | wc -l)
num=1

for dir in `ls -1`;do
  percent=$(echo "scale=4; $num / $total_file_count * 100" | bc | sed 's|00$||g')
  echo "## Removing $dir ($num of $total_file_count) ${percent}%"
  rm -Rf ./$dir
  num=$(( $num + 1 ))
done
