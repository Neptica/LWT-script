#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 output language URL"
    echo "Additional information: Output destination must exclude file extension and lang must be two character code -- (en, de, fr)"
    exit 1
fi

current_dir=$(pwd)

output_file="$current_dir/$1"
lang="$2"
url="$3"

temp_file="$current_dir/temp1234567890.vtt"

# set -e
yt-dlp --write-auto-subs --sub-langs "$lang" --skip-download -o "$output_file" "$url"

touch "$temp_file"
output_file="$output_file.$lang.vtt"

sed -E '
    /^WEBVTT$/d;
    /^Kind:/d;
    /^Language:/d;
    s/<[0-9:.]+>//g;
    s/<\/?c>//g;
    /^[0]/d;

    /^[[:space:]]*$/d;

' "$output_file" > "$temp_file"

python3 rdupes.py "$temp_file" "$output_file"

rm -rf "$tempfile"

echo "Clean script saved at the following destination: $output_file"
