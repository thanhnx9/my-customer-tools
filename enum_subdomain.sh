#!/bin/bash
domain_file='domain.txt'
while read line; do
#read for each line
echo "Scan subdomain of " $line
gobuster dns -d $line -w /root/tools/SecLists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt --wildcard -o subdomain_$line.txt
curl -k -s "https://crt.sh/?q=$line&output=json" | jq -r '.[] | "\(.name_value)\n\(.common_name)"' | sort -u >crtsubdomain_$line.txt
assetfinder $line -subs-only | grep $line$ >> assetsubdomain_$line.txt
amass enum -d $line -o amasssubdomain_$line.txt
done < $domain_file
cat subdomain_* > gobuster_subdomain.txt
awk '{gsub("Found: ", "");print}' gobuster_subdomain.txt > gobuster_subdomain2.txt
rm -rf subdomain_*.txt
cat crtsubdomain* > crt_subdomain.txt
rm -rf crtsubdomain_*
cat assetsubdomain_* > asset_subdomain.txt
rm -rf assetsubdomain_*.txt
cat amasssubdomain_* > amass_subdomain.txt
rm -rf amasssubdomain_*.txt
subfinder -dL $domain_file -o subfinder_subdomain.txt
sort asset_subdomain.txt gobuster_subdomain2.txt crt_subdomain.txt subfinder_subdomain.txt amass_subdomain.txt | uniq >>all_subdomain.txt
