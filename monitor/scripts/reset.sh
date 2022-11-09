#!/bin/bash

if [[ $(pgrep grafana) || $(pgrep prometheus) || $(pgrep loki) ]]
then
	echo "One or more apps are still running!"
	echo "Please terminate grafana, prometheus and loki and try again!"
	exit 1
else
	rm $K2_HOME/grafana $K2_HOME/prometheus
	rm -rf grafana-* prometheus-* loki
	rm $K2_HOME/config/grafana/* $K2_HOME/config/prometheus/prometheus* $K2_HOME/config/prometheus/sd_configs/* $K2_HOME/config/loki/*

	rm -rf $K2_HOME/storage/prome_data/* $K2_HOME/storage/loki_data/*

	mv $K2_HOME/install/*.tar.gz $K2_HOME/
	mv $K2_HOME/install/*.zip $K2_HOME/
fi
