#!/bin/bash

#IP=$(cat $K2_HOME/config/monitor_config | grep FABRIC_IP_1 | cut -d'=' -f2)

#timeout 1 telnet $IP 7170 | tee -a output >/dev/null 2>&1
#timeout 0.5 telnet $ip $2 | tee -a output &>/dev/null

get_ip_list () {
        cat $K2_HOME/config/monitor_config | grep $1_IP* | cut -d'=' -f2 > ip_list.txt
}

check_ports () {
	get_ip_list $1
	for ip in $(cat ip_list.txt)
	do
		timeout 0.5 telnet $ip $2 | tee -a output &>/dev/null
		if [ $(cat output |grep "Connected to $ip" |wc -l) == 1 ]
		then
			curl $ip:$2/metrics > metrics
			if [ -s metrics ]
			then
				echo "$1	$ip	$2	Connected	yes" >> status.txt
			else
				echo "$1	$ip	$2	Connected	no" >> status.txt
			fi
			rm output metrics
		else
			echo "$1	$ip	$2	Refused	no" >> status.txt
		fi
	done
	rm ip_list.txt
}


echo "APP	IP	PORT	STATUS	METRICS" > status.txt
echo "------	------	------	------	------" >> status.txt

check_ports FABRIC 9100
check_ports FABRIC 7170
check_ports FABRIC 7270

check_ports CASS 9100
check_ports CASS 7070

check_ports KAFKA 9100
check_ports KAFKA 7370

cat status.txt | sed 's/\t/,|,/g' | column -s ',' -t
rm status.txt
