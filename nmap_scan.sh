#!/bin/bash

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo "nmap is not installed. Please install it."
    exit 1
fi

# Function to scan a single target
scan_single_target() {
    target="$1"
    echo "Scanning common ports on $target..."
    nmap -sS -T4 -A -Pn $target -o fastscan_$target.nmap
    echo "Scanning all 65535 ports on $target..."
    nmap -Pn -p- $target -o fullscan_$target.nmap
}

# Function to scan multiple targets from a file
scan_multiple_targets() {
    file="$1"
    while IFS= read -r target; do
        scan_single_target "$target"
    done < "$file"
}

# Check if an IP address or hostname is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <target>"
    echo "       $0 -f <target_file>"
    echo "Example (single target): $0 example.com"
    echo "Example (multiple targets from a file): $0 -f targets.txt"
    exit 1
fi

# Check if the -f option is used to specify a target file
if [ "$1" == "-f" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 -f <target_file>"
        exit 1
    fi
    target_file="$2"
    scan_multiple_targets "$target_file"
else
    target="$1"
    scan_single_target "$target"
fi

echo "Port scanning completed."
