#!/bin/bash

cd $K2_HOME

if [ $FABRIC_IPS ]
then
    sh $K2_HOME/parse_ips.sh $FABRIC_IPS FABRIC
    sh $K2_HOME/scripts/create_sd_configs.sh fabric
fi
if [ $CASSANDRA_IPS ]
then
    sh $K2_HOME/parse_ips.sh $CASSANDRA_IPS CASSANDRA
    sh $K2_HOME/scripts/create_sd_configs.sh cassandra
fi
if [ $KAFKA_IPS ]
then
    sh $K2_HOME/parse_ips.sh $KAFKA_IPS KAFKA
    sh $K2_HOME/scripts/create_sd_configs.sh kafka
fi


#### START SERVICES ####

sh $K2_HOME/scripts/monitor_manager.sh loki start

sh $K2_HOME/scripts/monitor_manager.sh prometheus start

sh $K2_HOME/scripts/monitor_manager.sh grafana start

nohup node_exporter/node_exporter >/dev/null 2>&1 &

sleep infinity