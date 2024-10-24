#!/bin/bash

# Check if the user has provided an input file
if [ -z "$1" ]; then
  echo "Input list domain:"
  echo "Usage: $0 <domain_file>"
  exit 1
fi

# Assign the first command line argument to the domain_file variable
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

# Function for fuzzing with FFUF
fuzz_ffuf() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi
    
    echo "Fuzzing subdomains for $line"
    
    # Fuzzing subdomain with FFUF for preprod
    ffuf -u https://FUZZ-preprod.$line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -o out_preprod_$line.txt $proxy_option
    cat out_preprod_$line.txt | awk -F, '{print $1}' | grep -v "URL" | sed "s/$/-preprod.$line/" | sed '1d' > ffufsubdomain_preprod_$line.txt

    # Fuzzing subdomain with FFUF for dev
    ffuf -u https://FUZZ-dev.$line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -o out_dev_$line.txt $proxy_option
    cat out_dev_$line.txt | awk -F, '{print $1}' | grep -v "URL" | sed "s/$/-dev.$line/" | sed '1d' > ffufsubdomain_dev_$line.txt

    # Fuzzing subdomain with FFUF for staging
    ffuf -u https://FUZZ-staging.$line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -o out_staging_$line.txt $proxy_option
    cat out_staging_$line.txt | awk -F, '{print $1}' | grep -v "URL" | sed "s/$/-staging.$line/" | sed '1d' > ffufsubdomain_staging_$line.txt

  done < "$domain_file"

  # Combine FFUF subdomain files
  cat ffufsubdomain_* > ffufsubdomain.txt
  rm -f ffufsubdomain_*.txt
  rm -f out_*
}

# Function for Amass subdomain enumeration
amass_enum() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi

    echo "Running Amass enumeration for $line"

    # Amass for active and passive enumeration
    amass enum -d $line -o amass_subdomin_$line.txt
    amass enum -passive -norecursive -noalts -df amass_subdomin_$line.txt -o amass_subdomain_$line.txt
  done < "$domain_file"

  # Combine Amass subdomain files
  cat amass_subdomin_* > amass_subdomin.txt
  rm -f amass_subdomin_*.txt

  cat amass_subdomain_* > amass_subdomain.txt
  rm -f amass_subdomain_*.txt
}

# Function for CRT.sh subdomain check
crt_check() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi

    echo "Checking CRT.sh for $line"

    # Get subdomains from crt.sh
    curl -k -s "https://crt.sh/?q=$line&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u > crtsubdomain_$line.txt

  done < "$domain_file"

  # Combine crt.sh subdomain files
  cat crtsubdomain* > crt_subdomain.txt
  rm -f crtsubdomain_*
}

# Function for Assetfinder + Subfinder
assetfinder_subfinder() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi

    echo "Running Assetfinder and Subfinder for $line"

    # Using Assetfinder
    assetfinder $line -subs-only | grep $line$ >> assetsubdomain_$line.txt

  done < "$domain_file"

  # Combine Assetfinder subdomain files
  cat assetsubdomain_* > asset_subdomain.txt
  rm -f assetsubdomain_*.txt

  # Run Subfinder
  subfinder -dL "$domain_file" -o subfinder_subdomain.txt
}

# Function to run all tasks except FFUF
run_all_except_ffuf() {
  crt_check
  amass_enum
  assetfinder_subfinder
}

# Function to run all tasks
run_all() {
  fuzz_ffuf
  crt_check
  amass_enum
  assetfinder_subfinder
}

# Display menu to the user
echo "Choose an option:"
echo "1) Fuzzing with FFUF"
echo "2) Amass enumeration"
echo "3) CRT check"
echo "4) Assetfinder + Subfinder"
echo "5) Scan all"
echo "6) Scan all except FFUF"
read -p "Enter your choice: " option

# Main logic to select the option
case $option in
  1)
    fuzz_ffuf
    ;;
  2)
    amass_enum
    ;;
  3)
    crt_check
    ;;
  4)
    assetfinder_subfinder
    ;;
  5)
    run_all
    ;;
  6)
    run_all_except_ffuf
    ;;
  *)
    echo "Invalid option. Please choose between 1, 2, 3, 4, 5, or 6."
    exit 1
    ;;
esac

# Combine and sort the results (if applicable)
if [[ -f "ffufsubdomain.txt" || -f "crt_subdomain.txt" || -f "asset_subdomain.txt" || -f "subfinder_subdomain.txt" || -f "amass_subdomain.txt" || -f "amass_subdomin.txt" ]]; then
  echo "Combining and sorting the final subdomain list"
  sort asset_subdomain.txt ffufsubdomain.txt crt_subdomain.txt subfinder_subdomain.txt amass_subdomain.txt amass_subdomin.txt 2>/dev/null | uniq > all_subdomain.txt
fi
