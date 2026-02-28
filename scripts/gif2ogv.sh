#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="./input"
OUTPUT_DIR="./output"

mkdir -p "$OUTPUT_DIR"
shopt -s nullglob

# Target aspect ratio
ASPECT_W=46
ASPECT_H=39

for input in "$INPUT_DIR"/*.gif; do
    filename="$(basename "$input" .gif)"
    output="$OUTPUT_DIR/${filename}.ogv"

    if [[ -f "$output" ]]; then
        echo "Skipping (already exists): $output"
        continue
    fi

    echo "Converting: $input → $output"

    ffmpeg -i "$input" \
        -vf "scale='if(gt(a,$ASPECT_W/$ASPECT_H),trunc(ih*$ASPECT_W/$ASPECT_H/2)*2,trunc(iw/2)*2)':'if(gt(a,$ASPECT_W/$ASPECT_H),trunc(ih/2)*2,trunc(iw*$ASPECT_H/$ASPECT_W/2)*2)',setsar=1" \
        -c:v libtheora -q:v 7 \
        -c:a libvorbis -q:a 7 \
        "$output"
done

echo "Done."
