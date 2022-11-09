#!/bin/bash

cd $K2_HOME

#### GRAFANA CONFIGURATION ####

tar -zxvf grafana-enterprise*.tar.gz
rm grafana-enterprise*.tar.gz
ln -s grafana* grafana
cp grafana/conf/defaults.ini config/grafana/grafana.ini
cp grafana/conf/provisioning/datasources/sample.yaml grafana/conf/provisioning/datasources/sample.yaml.bk
cp install/datasources.yaml grafana/conf/provisioning/datasources/
cp grafana/conf/provisioning/dashboards/sample.yaml grafana/conf/provisioning/dashboards/sample.yaml.bk
cp install/dashboards.yaml grafana/conf/provisioning/dashboards/

#### PROMETHEUS CONFIGURATION ####

tar -zxvf prometheus*.tar.gz
rm prometheus-*linux-amd64.tar.gz
ln -s prometheus* prometheus
cp install/prometheus_default.yaml config/prometheus/

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

#### LOKI CONFIGURATION ####

unzip loki-*.zip
rm loki-*.zip
mkdir loki
mv loki-linux-amd64 loki
cp install/loki_default.yaml config/loki/

#### LOKI CONFIGURATION ####

tar -zxvf node_exporter*.tar.gz
rm node_exporter*.tar.gz
ln -s node_exporter* node_exporter


#### START SERVICES ####

sh $K2_HOME/scripts/monitor_manager.sh loki start

sh $K2_HOME/scripts/monitor_manager.sh prometheus start

sh $K2_HOME/scripts/monitor_manager.sh grafana start

nohup node_exporter/node_exporter >/dev/null 2>&1 &

sleep infinity