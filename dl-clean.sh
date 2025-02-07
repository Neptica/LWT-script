#!/bin/bash

underline() { echo -e "\033[1m$1\033[0m"; }

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 output language URL"
    underline "Additional information:"
    echo "Output destination must exclude file extension"
    echo "Language must be two character code (en, de, fr)"
    exit 1
fi

current_dir=$(pwd)

output_file="$current_dir/$1"
lang="$2"
url="$3"

temp_file="$current_dir/temp1234567890.vtt"

# set -e


echo "Checking available subtitles in $lang..."
response=$(yt-dlp --write-subs --sub-langs "$lang" --skip-download -o "$output_file" "$url" 2>&1)  # Capture command output, including errors

if [[ $response == *"[info] There are no subtitles for the requested languages"* ]]; then
    echo "No subtitles found. Downloading auto generated subtitles..."

    response=$( yt-dlp --write-auto-subs --sub-langs "$lang" --skip-download -o "$output_file" "$url" 2>&1) 
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
else
    echo "Subtitles found! Processing file..."

    touch "$temp_file"
    output_file="$output_file.$lang.vtt"

    sed -E '
    /^WEBVTT$/d;
    /^Kind:/d;
    /^Language:/d;
    /^[0]/d;

    ' "$output_file" > "$temp_file"

    python3 strip-native.py "$temp_file" "$output_file"
fi


rm -rf "$temp_file"

echo "File saved to: $output_file"
