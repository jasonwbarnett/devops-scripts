#!/bin/bash

files=$(find . -mindepth 1 -maxdepth 1 -not -path '*/\.*')
total_file_count=$(echo "${files}" | wc -l)
num=1

while IFS= read -r dir; do
  percent=$(echo "scale=4; $num / $total_file_count * 100" | bc | sed 's|00$||g')
  echo "## Removing $dir ($num of $total_file_count) ${percent}%"
  rm -Rf "./${dir}"
  (( num++ ))
done < <(echo "${files}")
