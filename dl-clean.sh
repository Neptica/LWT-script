#!/bin/bash

underline() { echo -e "\033[4m\033[31m$1\033[0m\033[0m"; }
bold() { echo -e "\033[1m\033[4m$1\033[0m\033[0m"; }

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 -opt output language URL"
  bold "Additional information:"
  echo "Option -a for the inclusion of audio and -o to download without audio"
  echo "Output destination must exclude file extension"
  echo "Language must be two character code (en, de, fr)"
  underline "Notice: the file will be downloaded to your current working directory"
  exit 1
fi

dlSubs() {
  echo "Checking available subtitles in $lang..."
  response=$(yt-dlp --write-subs --sub-langs "$lang" --skip-download -o "$output_file" "$url" 2>&1)  # Capture command output, including errors
  echo "Download options: $download"

  if [[ $response == *"[info] There are no subtitles for the requested languages"* ]]; then
    echo "No subtitles found. Downloading auto generated subtitles..."

    yt-dlp --write-auto-subs --sub-langs "$lang" --skip-download -o "$output_file" "$url" 2>&1 
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

    python3 ~/bin/rdupes.py "$temp_file" "$output_file"
  else
    echo "Subs found"
    touch "$temp_file"
    output_file="$output_file.$lang.vtt"

    sed -E '
    /^WEBVTT$/d;
    /^Kind:/d;
    /^Language:/d;
    /^[0]/d;

    ' "$output_file" > "$temp_file"

    python3 ~/bin/strip-native.py "$temp_file" "$output_file"
  fi


  rm -rf "$temp_file"

  echo "File saved to: $output_file"
}

current_dir=$(pwd)

output_file="$current_dir/$2"
lang="$3"
url="$4"
declare download

temp_file="$current_dir/temp1234567890.vtt"


while getopts ":a:o" option; do
  case $option in
    a) 
       echo "Downloading Audio and Script"; yt-dlp -x --audio-format mp3 $url; dlSubs;;
    o) echo "Downloading Script"; dlSubs;;
    ?) echo "Error: Invalid option -$OPTARG"; exit 1;;
  esac
done
