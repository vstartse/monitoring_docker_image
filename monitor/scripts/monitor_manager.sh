#!/bin/bash
# This script creates an interaction platform with Grafana, Prometheus and Loki
# Owner: Vlad S

# GLOBAL VARS
APP=$1
ACTION=$2

# GRAFANA VARS

GRAFANA_FLAGS="--config $K2_HOME/config/grafana/grafana.ini"

# PROMETHEUS VARS

PROMETHEUS_FLAGS="--config.file=$K2_HOME/config/prometheus/prometheus_default.yaml --web.listen-address='0.0.0.0:9090' --storage.tsdb.retention=7d --storage.tsdb.path=${K2_HOME}/storage/prome_data"

# LOKI VARS

LOKI_FLAGS="-config.file=$K2_HOME/config/loki/loki_default.yaml"

# COMMANDS
GRAFANA_START="nohup $K2_HOME/grafana/bin/grafana-server $GRAFANA_FLAGS &"
PROMETHEUS_START="nohup $K2_HOME/prometheus/prometheus $PROMETHEUS_FLAGS &"
LOKI_START="nohup $K2_HOME/loki/loki-linux-amd64 $LOKI_FLAGS &"

########## FUNCTIONS ##########

print_status () {
        echo "APP	STATUS" > status.txt
        echo "------	------" >> status.txt
        echo "Grafana	$GRAFANA_STATUS" >> status.txt
        echo "Prometheus	$PROMETHEUS_STATUS" >> status.txt
        echo "Loki	$LOKI_STATUS" >> status.txt
        cat status.txt | sed 's/\t/,|,/g' | column -s ',' -t
        rm status.txt
}

check_grafana () {
        if [[ $(pgrep grafana) ]]
        then
                GRAFANA_STATUS="UP"
        else
                GRAFANA_STATUS="DOWN"
        fi

}

check_prometheus () {
        if [[ $(pgrep prometheus) ]]
        then
                PROMETHEUS_STATUS="UP"
        else
                PROMETHEUS_STATUS="DOWN"
        fi

}

check_loki () {
        if [[ $(pgrep loki) ]]
        then
                LOKI_STATUS="UP"
        else
                LOKI_STATUS="DOWN"
        fi

}

##############################

# ACTIONS TO PERFORM
# Start/Stop/Status for Grafana/Prometheus/Loki
# Remove data for Prometheus/Loki


if [[ $# -lt 2 ]]
then
        echo "Usage: $0 [APP] [ACTION]"
        echo
        echo "Example: $0 grafana start"
        echo
        echo "APP: [grafana, prometheus, loki]"
        echo "ACTION: [start, stop, status, rmdata]"
fi
case $ACTION in
  status)
    case $APP in
      grafana | prometheus | loki)
        echo "$(ps -ef | grep $APP)"
        if [[ $(pgrep ${APP}) ]]
        then
          echo "$APP is RUNNING"
        else
          echo "$APP is NOT RUNNING"
        fi
        ;;
      all)
        check_grafana
        check_prometheus
        check_loki
        print_status
        ;;
      *)
        echo "Invalid APP name!"
        exit 1
        ;;
    esac
    ;;
  stop)
    if [[ $(pgrep ${APP}) ]]
    then
      echo "==> $APP PID: $(pgrep ${APP})"
      echo "==> Stopping $APP"
      kill $(pgrep ${APP})
      echo "==> $APP stopped"
    else
      echo "$APP is NOT running!"
      exit 1
    fi
    ;;
  start)
    if [[ $(pgrep ${APP}) ]]
    then
      echo "$APP is already running!"
      echo "==> $APP PID: $(pgrep ${APP})"
      exit 1
    else
      case $APP in
        grafana)
          echo "==> Starting ${APP}..."
          cd ~/grafana/bin && eval $GRAFANA_START
          sleep 2
          if [[ $(pgrep ${APP}) ]]
          then
            echo "==> $APP started successfully with PID $(pgrep ${APP})"
          else
            echo "==> $APP start FAILED"
            tail ~/grafana/data/log/grafana.log
            exit 1
          fi
          ;;
        prometheus)
          echo "==> Starting ${APP}..."
          cd ~/prometheus && eval $PROMETHEUS_START
          sleep 2
          if [[ $(pgrep ${APP}) ]]
          then
            echo "==> $APP started successfully with PID $(pgrep ${APP})"
          else
            echo "==> $APP start FAILED"
            tail ~/prometheus/prom.log
            exit 1
          fi
          ;;
        loki)
          echo "==> Starting ${APP}..."
          cd ~/loki && eval $LOKI_START
          sleep 2
          if [[ $(pgrep ${APP}) ]]
          then
            echo "==> $APP started successfully with PID $(pgrep ${APP})"
          else
            echo "==> $APP start FAILED"
            tail ~/loki/loki.log
            exit 1
          fi
          echo "==> $APP started successfully with PID $(pgrep ${APP})"
          ;;
        *)
          echo "Invalid APP name!"
          exit 1
          ;;
      esac
    fi
    ;;
  rmdata)
    echo "WARNING! This action will remove all the data from $APP!"
    read -p "Please confirm you want to proceed (y/n)" INPUT
    if [[ $INPUT = "n" ]]
    then
      echo "The action was NOT executed!"
      exit 1
    fi
    case $APP in
      prometheus)
        DATA_DIR="$K2_HOME/storage/prome_data"
      ;;
      loki)
        DATA_DIR="$K2_HOME/storage/loki_data"
      ;;

    esac
    echo "Removing data from $APP storage directory..."
    rm -rf $DATA_DIR/*
    ;;
esac
exit 0
