#!/bin/bash

cd $K2_HOME

if [ ! -z ${FABRIC_IPS+x} ]
then
    sh $K2_HOME/parse_ips.sh $FABRIC_IPS FABRIC
    sh $K2_HOME/scripts/create_sd_configs.sh fabric
fi
if [ ! -z ${CASSANDRA_IPS+x} ]
then
    sh $K2_HOME/parse_ips.sh $CASSANDRA_IPS CASSANDRA
    sh $K2_HOME/scripts/create_sd_configs.sh cassandra
fi
if [ ! -z ${KAFKA_IPS+x} ]
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