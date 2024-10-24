#!/bin/bash

# check input
if [ -z "$1" ]; then
  echo "Input domain.txt list file."
  echo "Usage: $0 <domain_file>"
  exit 1
fi

# var domain_file
domain_file="$1"

# Check file
if [ ! -f "$domain_file" ]; then
  echo "File $domain_file not found!"
  exit 1
fi

# create new folder
folder="output_urls"
if [ ! -d "$folder" ]; then
    mkdir "$folder"
    echo "Create $folder"
else
    echo "$folder already exists!!"
    echo "Start to crawl......"
fi

# Running waybackurls
echo "Waybackurls running..."
cat "$domain_file" | waybackurls -no-subs > "$folder/url_waybackurls.txt"

# Running httprobe
echo "Httprobe running..."
cat "$domain_file" | httprobe -p xlarge > "$folder/target.txt"

# Running hakrawler
echo "Hakrawler running..."
cat "$folder/target.txt" | hakrawler -subs > "$folder/url_hakrawler.txt"

# Running waymore
echo "Waymore running..."
waymore -i $folder/target.txt -oU $folder/url_waymore.txt

cat "$folder/url_"* | uro > "$folder/all_urls.txt"
echo "Finished!!"
