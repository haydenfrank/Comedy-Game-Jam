#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="./input"
OUTPUT_DIR="./output"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

shopt -s nullglob

for input in "$INPUT_DIR"/*.gif; do
    filename="$(basename "$input" .gif)"
    output="$OUTPUT_DIR/${filename}.ogv"

    if [[ -f "$output" ]]; then
        echo "Skipping (already exists): $output"
        continue
    fi

    echo "Converting: $input → $output"
    ffmpeg -i "$input" \
        -c:v libtheora -q:v 7 \
        -c:a libvorbis -q:a 7 \
        "$output"
done

echo "Done."
