#!/bin/bash

IPS=$1
APP=$2

get_ips () {
    local i=1
    IFS="," read -a ips_array <<< $IPS
    for ip in ${ips_array[@]}
    do
        echo "${APP}_IP_$i=$ip" >> $K2_HOME/config/monitor_config
        ((i=i+1))
    done
}

get_ips