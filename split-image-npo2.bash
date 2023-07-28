#!/bin/bash

# Open a bash-capable terminal in this directory and run
# `split-images-npo2.bash <0F.png> <1F.png> ...`
# In case it's not clear, 0F is the basement and 1F is the first floor.
# You can name these floors anything, just update them in `index.htm`.
# This script will print the JSON to use for whatever images you specify,
# but you may want to rename the floors before pasting it in.

CONVERT='convert'

_cut_and_resize_image() {
  local source_image=$1
  local size=$2
  local extent=$3
  local destination_size=$4
  local output_dir=$5
  local ext=$6

  mkdir -p "$output_dir"

  echo " - Splitting $output_dir with size ${size}..."
  $CONVERT "$source_image" \
      -background none -extent "$extent" \
      -crop "${size}x${size}" \
      -set filename:tile "%[fx:page.x/${size}]-%[fx:page.y/${size}]" \
      -resize "${destination_size}" "$output_dir/%[filename:tile].$ext"
}

function ceil() { awk "-vx=$1" 'BEGIN{ print int(x + (0 != x%1)) }'; }

GRAND_JSON=""
function _append_json() {
  GRAND_JSON="$(printf '%s\n%s' "$GRAND_JSON" "$@")"
}

function _split_image_octaves() {
  local source_image=$1
  local size=$2

  local dest_size="${size}x${size}"

  if [ ! -f "$source_image" ]; then
    echo "Error: Source image '$source_image' not found."
    return 1
  fi

  echo 'Getting image dimensions...'
  local image_size=$(identify -format "%w:%h" "$source_image")
  local w=${image_size%%:*}
  local h=${image_size#*:}

  local image_filename=${source_image#*/}
  local subfolder=${image_filename%%.*}
  local extension=${source_image#*.}

  local max_dimension=$(echo "if ($w > $h) $w else $h" | bc)
  num_octaves=$(ceil "$(echo "l($max_dimension/$size) / l(2)" | bc -l)")
  echo "Max dimension is $max_dimension, so use $num_octaves octaves"

  _append_json "      { `
      `label: '$subfolder', `
      `url: './floors/$subfolder/{z}/{x}-{y}.$extension', `
      `maxZoom: $num_octaves },"

  echo "Splitting ${w}×${h} image '$source_image' at $num_octaves octaves..."
  for octave in `seq 0 $num_octaves`; do
    local extent="$(((w + size - 1) / size * size))x$(((h + size - 1) / size * size))"
    _cut_and_resize_image "$source_image" "$size" "$extent" "$dest_size" \
        "floors/$subfolder/$((num_octaves - octave))" "$extension"
    size=$((size << 1))
  done
}

function split-images() {
  GRAND_JSON='    const FLOOR_DATA = ['

  if [ -d "floors" ]; then
    echo "Error: floors/ already exists; please delete or rename the directory " >&2
    echo "before calling this script to avoid clobbering data." >&2
    return 1
  fi

  for img in "$@"; do
    if [ -f "$img" ]; then
      _split_image_octaves "$img" 256
    else
      echo "File not found: $img.png"
    fi
  done
  
  _append_json '    ];'
  
  
  echo 'The operation completed. Assuming there were no major problems,'
  echo 'replace the JSON at the top of index.htm with the following:'
  echo ''
  echo "$GRAND_JSON"
  echo ''
  echo 'Feel free to be creative with the floor labels. More concise is better.'
}

split-images "$@"
