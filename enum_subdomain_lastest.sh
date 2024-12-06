#!/bin/bash

# Check if the user has provided an input file
if [ -z "$1" ]; then
  echo "Input list domain:"
  echo "Usage: $0 <domain_file>"
  exit 1
fi

# Assign the first command line argument to domain_file variable
domain_file="$1"

# Check if the input file exists
if [ ! -f "$domain_file" ]; then
  echo "File $domain_file not found!"
  exit 1
fi

# Check if http_proxy is set
if [ -z "$http_proxy" ]; then
  proxy_option=""
else
  proxy_option="-x $http_proxy"
fi

# Function to perform FFUF fuzzing
fuzz_ffuf() {
  local line="$1"
  echo "Fuzzing subdomains for $line"

  # Fuzzing for different environments
  ffuf -u https://FUZZ-preprod.$line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -o out_preprod_$line.txt $proxy_option &
  ffuf -u https://FUZZ-dev.$line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -o out_dev_$line.txt $proxy_option &
  ffuf -u https://FUZZ-staging.$line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -o out_staging_$line.txt $proxy_option &
  
  wait
}

# Function to perform CRT.sh lookup
crt_check() {
  local line="$1"
  echo "Checking CRT.sh for $line"

  curl -k -s "https://crt.sh/?q=$line&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u > crtsubdomain_$line.txt &
}

# Function to use assetfinder and subfinder
assetfinder_subfinder() {
  local line="$1"
  echo "Running Assetfinder and Subfinder for $line"

  assetfinder $line -subs-only | grep $line$ >> assetsubdomain_$line.txt &
  subfinder -d $line -o subfinder_$line.txt &
}

# Function to perform Amass enumeration
amass_enum() {
  local line="$1"
  echo "Running Amass enumeration for $line"

  amass enum -passive -norecursive -noalts -d $line -o amass_subdomin_$line.txt &
  amass enum -passive -norecursive -noalts -df amass_subdomin_$line.txt -o amass_subdomain_$line.txt &
}

# Function to run Subdominator enumeration
subdominator_enum() {
  local line="$1"
  echo "Running Subdominator enumeration for $line"

  subdominator -d $line -o subdominatorsubdomain_$line.txt &
}

# Function to run all tasks except FFUF
run_all_except_ffuf() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    crt_check "$line"
    amass_enum "$line"
    assetfinder_subfinder "$line"
    subdominator_enum "$line"
  done < "$domain_file"
  wait
}

# Function to run all tasks including FFUF
run_all() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    fuzz_ffuf "$line"
    crt_check "$line"
    amass_enum "$line"
    assetfinder_subfinder "$line"
    subdominator_enum "$line"
  done < "$domain_file"
  wait
}

# Function to combine and clean up results
combine_results() {
  # Combine FFUF subdomain files
  if [ -f "ffufsubdomain_*" ]; then
    cat ffufsubdomain_* > ffufsubdomain.txt
    rm -f ffufsubdomain_*.txt
    rm -f out_*
  fi

  # Combine crt.sh subdomain files
  cat crtsubdomain* > crt_subdomain.txt
  rm -f crtsubdomain_*

  # Combine assetfinder subdomain files
  cat assetsubdomain_* > asset_subdomain.txt
  rm -f assetsubdomain_*.txt

  # Combine Amass subdomain files
  cat amass_subdomin_* > amass_subdomin.txt
  rm -f amass_subdomin_*.txt
  cat amass_subdomain_* > amass_subdomain.txt
  rm -f amass_subdomain_*.txt

  # Combine Subdominator subdomain files
  cat subdominatorsubdomain_* > subdominator.txt
  rm -f subdominatorsubdomain_*.txt

  # Create a list of the subdomain files that exist
  files=""
  for file in "ffufsubdomain.txt" "crt_subdomain.txt" "asset_subdomain.txt" "subfinder_subdomain.txt" "amass_subdomain.txt" "amass_subdomin.txt" "subdominator.txt"; do
    if [[ -f "$file" ]]; then
      files="$files $file"
    fi
  done
  
  # If any files exist, combine and sort them
  if [[ -n "$files" ]]; then
    echo "Combining and sorting the final subdomain list"
    sort $files | uniq > all_subdomain.txt
  else
    echo "No subdomain files found, skipping combining step."
  fi
}

# Menu to select options
echo "Choose an option:"
echo "1) Fuzzing with FFUF"
echo "2) Amass enumeration"
echo "3) CRT check"
echo "4) Assetfinder + Subfinder"
echo "5) Scan all"
echo "6) Scan all except FFUF"
echo "7) Subdominator enumeration"
read -p "Enter your choice: " option

# Run the appropriate function based on user input
case $option in
  1)
    while IFS= read -r line || [[ -n "$line" ]]; do
      fuzz_ffuf "$line"
    done < "$domain_file"
    ;;
  2)
    while IFS= read -r line || [[ -n "$line" ]]; do
      amass_enum "$line"
    done < "$domain_file"
    ;;
  3)
    while IFS= read -r line || [[ -n "$line" ]]; do
      crt_check "$line"
    done < "$domain_file"
    ;;
  4)
    while IFS= read -r line || [[ -n "$line" ]]; do
      assetfinder_subfinder "$line"
    done < "$domain_file"
    ;;
  5)
    run_all
    ;;
  6)
    run_all_except_ffuf
    ;;
  7)
    while IFS= read -r line || [[ -n "$line" ]]; do
      subdominator_enum "$line"
    done < "$domain_file"
    ;;
  *)
    echo "Invalid option. Please choose between 1 and 7."
    exit 1
    ;;
esac

# Combine and sort the results
combine_results
