#!/bin/bash
#
# sokdr
#
tput clear
trap ctrl_c INT

function ctrl_c() {
        echo "**You pressed Ctrl+C...Exiting"
        exit 0;
}
#
echo -e "###############################################"
echo -e "###############################################"
echo -e "###############################################"
echo "_    _                 _          _ _ _   "
echo "| |  (_)_ _ _  ___ __  /_\ _  _ __| (_) |_ "
echo "| |__| |   \ || \ \ / / _ \ || / _  | |  _|"
echo "|____|_|_||_\_ _/_\_\/_/ \_\_ _\__ _|_|\__|"
echo
echo "###############################################"
echo "Welcome to security audit of your linux machine:"
echo "###############################################"
echo
echo "Script will automatically gather the required info:"
echo "The checklist can help you in the process of hardening your system:"
echo "Note: it has been tested for Debian Linux Distro:"
echo
sleep 3
echo
while true; do
	read -p "Would you like to save the output? [Y/N] " output
	case ${output:0:1} in
        	y|Y)
			echo "File will be saved on $path/LinuxAudit.txt "
			echo
			read -p "Please denote the path for the file to save the output: " path
			echo
                	touch $path/LinuxAudit.txt
		{            
    			echo "###############################################"
                	echo
                	echo
                	sleep 3
                	echo
                	echo "Script Starts ;)"
                	START=$(date +%s)
                	echo
                	echo -e "1. Linux Kernel Information//////"
                	echo
                	uname -a
                	echo
                	echo "###############################################"
                	echo
                	echo -e "2. Current User and ID information//////"
                	echo
                	whoami
                	echo
                	id
                	echo
                	echo "###############################################"
                	echo
                	echo -e "3.  Linux Distribution Information/////"
                	echo
                	lsb_release -a
                	echo
                	echo "###############################################"
                	echo
                	echo -e "4. List Current Logged In Users/////"
                	echo
                	w
                	echo
                	echo "###############################################"
                	echo
                	echo -e "5. $HOSTNAME Uptime Information/////"
                	echo
                	uptime
                	echo
                	echo "###############################################"
                	echo
                	echo -e "6. Running Services/////"
                	echo
                	service --status-all |grep "+"
                	echo
                	echo "###############################################"
                	echo
                	echo -e "7. Active Internet Connections and Open Ports/////"
                	echo
                	netstat -natp
                	echo
                	echo "###############################################"
                	echo
                	echo -e "8. Check Available Space/////"
                	echo
                	df -h
                	echo
                	echo "###############################################"
                	echo
                	echo -e "9. Check Memory/////"
                	echo
                	free -h
                	echo
                	echo "###############################################"
                	echo
                	echo -e "10. History (Commands)/////"
                	echo
                	history
                	echo
                	echo "###############################################"
                	echo
                	echo -e "11. Network Interfaces/////"
                	echo
                	ifconfig -a
                	echo
                	echo "###############################################"
                	echo
                	echo -e "12. IPtable Information/////"
                	echo
                	iptables -L -n -v
                	echo
                	echo "###############################################"
               		echo
               		echo -e "13. Check Running Processes/////"
                	echo
                	ps -a
                	echo
                	echo "###############################################"
                	echo
                	echo -e "14. Check SSH Configuration/////"
                	echo
                	cat /etc/ssh/sshd_config
                	echo
                	echo "###############################################"
                	echo -e "15. List All Packages Installed/////"
                	#apt-cache pkgnames
                	echo
                	echo "###############################################"
                	echo
                	echo -e "16. Network Parameters/////"
                	echo
                	cat /etc/sysctl.conf
                	echo
                	echo "###############################################"
                	echo
                	echo -e "17. Password Policies/////"
                	echo
                	cat /etc/pam.d/common-password
                	echo
                	echo "###############################################"
                	echo
                	echo -e "18. Check your Source List File/////"
                	echo
                	cat /etc/apt/sources.list
                	echo
                	echo "###############################################"
                	echo
                	echo -e "19. Check for Broken Dependencies/////"
                	echo
                	apt-get check
                	echo
                	echo "###############################################"
                	echo
                	echo -e "20. MOTD Banner Message/////"
                	echo
                	cat /etc/motd
                	echo
                	echo "###############################################"
                	echo
                	echo -e "21. List User Names/////"
                	echo
                	cut -d: -f1 /etc/passwd
                	echo
                	echo "###############################################"
                	echo
                	echo -e "22. Check for Null Passwords/////"
                	echo
                	users="$(cut -d: -f 1 /etc/passwd)"
                	for x in $users
                	do
                	passwd -S $x |grep "NP"
                	done
                	echo
                	echo "###############################################"
                	echo
                	echo -e "23. IP Routing Table/////"
                	echo
                	route
                	echo
               		echo "###############################################"
                	echo
                	echo -e "24. Kernel Messages/////"
                	echo
                	dmesg
                	echo
                	echo "###############################################"
                	echo
                	echo -e "25. Check Upgradable Packages/////"
                	echo
                	#apt list --upgradeable
                	#apt list --upgradeable
                	echo
                	echo "###############################################"
                	echo
                	echo -e "26. CPU/System Information/////"
                	echo
                	cat /proc/cpuinfo
                	echo
                	echo "###############################################"
                	echo
                	echo -e "27. TCP wrappers/////"
                	echo
                	cat /etc/hosts.allow
                	echo "///////////////////////////////////////"
                	echo
                	cat /etc/hosts.deny
                	echo
                	echo "###############################################"
                	echo
                	echo -e "28. Failed login attempts/////"
                	echo
                	grep --color "failure" /var/log/auth.log
               		echo
                	echo "###############################################"
                	echo
                	END=$(date +%s)
                	DIFF=$(( $END - $START ))
                	echo Script completed in $DIFF seconds :
                	echo
                	echo Executed on :
                	date
                	echo

                	exit 0;
        } >  $path/LinuxAudit.txt
	break
        ;;
        n|N)
         echo "OK no file."
	break
        ;;
	*)
	echo "Exiting Please enter y or n. "
	;;
    esac
done
echo "###############################################"
echo
echo "OK....$HOSTNAME..lets move on...wait for it to finish:"
echo
sleep 3
echo
echo "Script Starts ;)"
START=$(date +%s)
echo
echo -e "1. Linux Kernel Information//////"
echo
uname -a
echo
echo "###############################################"
echo
echo -e "2. Current User and ID information//////"
echo
whoami
echo
id
echo
echo "###############################################"
echo
echo -e "3.  Linux Distribution Information/////"
echo
lsb_release -a
echo
echo "###############################################"
echo
echo -e "4. List Current Logged In Users/////"
echo
w
echo
echo "###############################################"
echo
echo -e "5. $HOSTNAME Uptime Information/////"
echo
uptime
echo
echo "###############################################"
echo
echo -e "6. Running Services/////"
echo
service --status-all |grep "+"
echo
echo "###############################################"
echo
echo -e "7. Active Internet Connections and Open Ports/////"
echo
netstat -natp
echo
echo "###############################################"
echo
echo -e "8. Check Available Space/////"
echo
df -h
echo
echo "###############################################"
echo
echo -e "9. Check Memory/////"
echo
free -h
echo
echo "###############################################"
echo
echo -e "10. History (Commands)/////"
echo
history
echo
echo "###############################################"
echo
echo -e "11. Network Interfaces/////"
echo
ifconfig -a
echo
echo "###############################################"
echo
echo -e "12. IPtable Information/////"
echo
iptables -L -n -v
echo
echo "###############################################"
echo
echo -e "13. Check Running Processes/////"
echo
ps -a
echo
echo "###############################################"
echo
echo -e "14. Check SSH Configuration/////"
echo
cat /etc/ssh/sshd_config
echo
echo "###############################################"
echo -e "15. List All Packages Installed/////"
apt-cache pkgnames
echo
echo "###############################################"
echo
echo -e "16. Network Parameters/////"
echo
cat /etc/sysctl.conf
echo
echo "###############################################"
echo
echo -e "17. Password Policies/////"
echo
cat /etc/pam.d/common-password
echo
echo "###############################################"
echo
echo -e "18. Check your Source List File/////"
echo
cat /etc/apt/sources.list
echo
echo "###############################################"
echo
echo -e "19. Check for Broken Dependencies/////"
echo
apt-get check
echo
echo "###############################################"
echo
echo -e "20. MOTD Banner Message/////"
echo
cat /etc/motd
echo
echo "###############################################"
echo
echo -e "21. List User Names/////"
echo
cut -d: -f1 /etc/passwd
echo
echo "###############################################"
echo
echo -e "22. Check for Null Passwords/////"
echo
users="$(cut -d: -f 1 /etc/passwd)"
for x in $users
do
passwd -S $x |grep "NP"
done
echo
echo "###############################################"
echo
echo -e "23. IP Routing Table/////"
echo
route
echo
echo "###############################################"
echo
echo -e "24. Kernel Messages/////"
echo
dmesg
echo
echo "###############################################"
echo
echo -e "25. Check Upgradable Packages/////"
echo
apt list --upgradeable
echo
echo "###############################################"
echo
echo -e "26. CPU/System Information/////"
echo
cat /proc/cpuinfo
echo
echo "###############################################"
echo
echo -e "27. TCP wrappers/////"
echo
cat /etc/hosts.allow
echo "///////////////////////////////////////"
echo
cat /etc/hosts.deny
echo
echo "###############################################"
echo
echo -e "28. Failed login attempts/////"
echo
grep --color "failure" /var/log/auth.log
echo
echo "###############################################"
echo
END=$(date +%s)
DIFF=$(( $END - $START ))
echo Script completed in $DIFF seconds :
echo
echo Executed on :
date
echo

exit 0;