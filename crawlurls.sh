#!/bin/bash

# Check input
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Please provide a domain list file and target filename."
  echo "Usage: $0 <domain_file> <target_file>"
  exit 1
fi

# Variables for domain_file and target_file
domain_file="$1"
target="$2"

# Check if the domain_file exists
if [ ! -f "$domain_file" ]; then
  echo "File $domain_file not found!"
  exit 1
fi

# Create new folder
folder="output_urls"
if [ ! -d "$folder" ]; then
    mkdir "$folder"
    echo "Folder $folder created"
else
    echo "Folder $folder already exists!"
    echo "Starting the crawling process..."
fi

# Run waybackurls
echo "Running waybackurls..."
cat "$domain_file" | waybackurls -no-subs > "$folder/url_waybackurls.txt"

# Add https:// and http:// prefixes to each domain and write to target
echo "Adding https:// and http:// prefixes to each domain..."
> "$folder/$target"  # Clear target file content if it exists
while IFS= read -r domain; do
  echo "https://$domain" >> "$folder/$target"
  echo "http://$domain" >> "$folder/$target"
done < "$domain_file"

# Remove duplicates in the target file
echo "Removing duplicate URLs in $target..."
cat "$target" >> "$folder/$target
cat "$folder/$target" | sort | uniq > "$folder/temp_target.txt"
mv "$folder/temp_target.txt" "$folder/$target"

# Run hakrawler
echo "Running hakrawler..."
cat "$folder/$target" | hakrawler -subs > "$folder/url_hakrawler.txt"

# Run waymore
echo "Running waymore..."
waymore -i "$folder/$target" -oU "$folder/url_waymore.txt"

# Consolidate URLs and remove duplicates
echo "Consolidating URLs and removing duplicates..."
cat "$folder/url_"* | uro > "$folder/all_urls.txt"

echo "Done!!"
