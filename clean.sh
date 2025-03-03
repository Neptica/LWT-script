#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 input.vtt output.vtt"
    exit 1
fi

input_file="$1"
output_file="$2"
temp_file="temp.vtt"

touch "$temp_file"

sed -E '
    /^WEBVTT$/d;
    /^Kind:/d;
    /^Language:/d;
    /\<[^>]+\>/d;
    /^[0]/d;

    /^[[:space:]]*$/d;

' "$input_file" > "$temp_file"

sed 'n;s/.*/ /' "$temp_file" > "$output_file"

rm -rf "$temp_file"

echo "Cleaned subtitles saved to $output_file"
