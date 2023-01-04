#!/bin/bash

if [ $UID -ne 0 ]; then
echo "[-]Superuser permission Required"
exit 0
fi

python3 Interface.py

read -p "[+]Enter Index of Interface: " iface_index

clear
echo -e "\t\tInterface Ip: " `python3 -c "import scapy.all as scapy;print(scapy.get_if_addr(scapy.conf.ifaces.dev_from_index($iface_index)));"`
echo -e "\t\tInterface MAC: " `python3 -c "import scapy.all as scapy;print(scapy.get_if_hwaddr(scapy.conf.ifaces.dev_from_index($iface_index)));"`
echo -e "\t\tRouter Ip: " `python3 -c "import scapy.all as scapy;print(scapy.conf.route.route('0.0.0.0')[2]);"`


loop=1
is_back=0


host_list=()
mode=3

while [ $loop -eq 1 ]; do

echo "1.Scan For Host"
echo "2.Perform Arp Spoof"
echo "3.Exit"
echo "4.Enable/Disable Ip Forwarding"

read -p "[+]Enter option: " op

case $op in 
	
	1)
		host_list=("Select Target" "Select Router" "Start Arpspoof" "Back")
		count=4
		 #python3 NetDiscovery.py -n `python3 -c "import scapy.all as scapy;print(scapy.get_if_addr(scapy.conf.ifaces.dev_from_index($iface_index)));"`/24 -i $iface_index | 
		while read line
		do
		 host_list[$count]="$line"
		 let count++
		 echo $line
		done <<< `python3 NetDiscovery.py -n $(python3 -c "import scapy.all as scapy;print(scapy.get_if_addr(scapy.conf.ifaces.dev_from_index($iface_index)));")/24 -i $iface_index`
		#done < "arp.txt"
		
		
	;;
	
	2) 
		select host in "${host_list[@]}"
		do
		 [ $REPLY -eq 1 ] && { mode=0; echo "[!]Target Selection Mode"; }
		 [ $REPLY -eq 2 ] && { mode=1; echo "[!]Router Selection Mode"; }
		 [ $REPLY -eq 3 ] && { break; }
		 [ $REPLY -eq 4 ] && { is_back=1;break; }
		 
		 if [ $mode -eq 0 ] && [ $REPLY -gt 4 ]; then
		  echo "[+] '$host' is Selected As Target"
		  target=$host
		 fi
		 
		 if [ $mode -eq 1 ] && [ $REPLY -gt 4 ]; then
		  echo "[+] '$host' is Selected As Router"
		  router=$host
		 fi
		 
		done
		
		if [ $is_back -ne 1 ]; then
		
			if [ "$target" != "$router" ]; then 
			 target=$(echo $target | awk '{print " -t " $1 " -T " $2}')
			 router=$(echo $router | awk '{print " -r " $1 " -R " $2}')
			 echo "[!]Executing \"python3 ArpSpoof.py $target $router -i $iface_index\""
			 python3 ArpSpoof.py $target $router -i $iface_index
			else
			 echo "[-]Router And Target is Same"
			fi
		fi
		echo
		target=""
		router=""
		is_back=0
		
	;;
	
	3)
		exit 0
	;;
	
		 
	4)
		
		if [ `cat /proc/sys/net/ipv4/ip_forward` -eq 0 ]; then
			echo "1" > /proc/sys/net/ipv4/ip_forward
 			echo "[+]Ip Forwarding is activated" 
 		elif [ `cat /proc/sys/net/ipv4/ip_forward` -eq 1 ]; then
 		
			echo "0" > /proc/sys/net/ipv4/ip_forward
 			echo "[+]Ip Forwarding is Deactivated"
 		fi
	;;
	
		
	*)
		echo "Unknown Option"
	;;
	
esac
echo
echo

done
