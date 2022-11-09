#!/bin/bash
# Owner: Vlad S
# This script creates a JSON configuration file for Prometheus sd_configs directory
# The arguments for the script should be:
# ==> monitor_config file
# ==> Project name
# ==> App name (fabric/cassandra/kafka)

########## VARS ###########

PROJECT_NAME=$(cat $K2_HOME/config/monitor_config | grep PROJECT_NAME | cut -d'=' -f2)
ENV=$(cat $K2_HOME/config/monitor_config | grep ENV | cut -d'=' -f2)
APP=$1

########## FUNCTIONS ###########

get_ip_list () {
        cat $K2_HOME/config/monitor_config | grep $1_IP* | cut -d'=' -f2 > ip_list.txt
}

print_usage () {
        echo "Usage: $0 [APP_NAME]"
        echo "Example: ./create_sd_configs.sh fabric"
}

if [[ $# = 0 ]]
then
        print_usage
        exit 1
fi

########## SCRIPT ###########

case $APP in
        fabric)
                APP_NAME="fn"
                JMX_PORT="7170"
		JMX_PORT2="7270"
                get_ip_list "FABRIC"
                ;;
        cassandra)
                APP_NAME="cn"
                JMX_PORT="7070"
                get_ip_list "CASSANDRA"
                ;;
        kafka)
                APP_NAME="kn"
                JMX_PORT="7370"
		get_ip_list "KAFKA"
                ;;
        *)
                echo "App name is not valid! Please provide one of the following:"
                echo "fabric/cassandra/kafka/"
                exit 1
                ;;
esac

COUNT=$(cat ip_list.txt | wc -l)

echo "[" > config.json
i=1
for ip in $(cat ip_list.txt)
do
        echo "  {" >> config.json
	if [ $APP == "fabric" ]
	then
		echo "    \"targets\": [\"$ip:$JMX_PORT\",\"$ip:$JMX_PORT2\",\"$ip:9100\"]," >> config.json
	else
        	echo "    \"targets\": [\"$ip:$JMX_PORT\",\"$ip:9100\"]," >> config.json
	fi
        echo "    \"labels\": {" >> config.json
        echo "      \"node\": \"${APP_NAME}_$i\"," >> config.json
        echo "      \"env\": \"$ENV\"," >> config.json
        echo "      \"project\": \"$PROJECT_NAME\"" >> config.json
        echo "    }" >> config.json
        if [[ $i != $COUNT ]]
        then
                echo "  }," >> config.json
        else
                echo "  }" >> config.json
        fi
        ((i+=1))
done
echo "]" >> config.json
rm ip_list.txt
echo "JSON created for $3 application!"
mv config.json $K2_HOME/config/prometheus/sd_configs/${PROJECT_NAME}_$APP.json
exit 0
